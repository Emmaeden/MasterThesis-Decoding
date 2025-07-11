
close all; clear all; clc;
%% Load Results and Prepare Data

resPath = '/disco/emma/MC01res/psvr_resultsm/res_pSVR_mc01m/wVisual_Cortex_Mask';
addpath(resPath);
files = dir(fullfile(resPath, '*.mat'));
res = NaN(36,28,16,8); % subjects, FIRS,trials and runs

% Load and reshape data
for ii = 1:numel(files)
    ld = load(fullfile(resPath, files(ii).name));
    for fir=1:28
        reshapedData = reshape(ld.D.angle_diff{fir}, [16 8]); % (subject x trials x runs)
        res(ii,fir, :, :) = reshapedData; 
    end
end

% convert to degrees for better interpetation
dres = rad2deg(res);
dres = abs(dres);

%% Compute Early and Late Runs
chance_level =90;
% Across sessions
early_runs = mean(dres(:, 1:23,:, 1:4), [3,4]) ; % subject X time 1s-27s
late_runs = mean(dres(:, 1:23,:, 5:8), [3,4]) ;
% Within sessions
% early_runs = mean(dres(:, :,:, [1 2 5 6]), [3,4]) ; % subject X time
% late_runs = mean(dres(:, :,:, [3 4 7 8]), [3,4]) ;
SemEarly = std(early_runs,1)/sqrt(36);
SemLate =  std(late_runs,1)/sqrt(36);

%% Pair ttest across subjects 1xFIRs
early_means = mean(early_runs,2);
late_means = mean(late_runs,2) ;
% pair ttest
[h ,p, stat] = ttest(early_means-late_means);
fprintf('Pair t-test Across Subjects in the VC  EarlySess - LateSess: h = %d, p = %.5f\n',h,p);

%% Time vrctors for delays
PercepDelay = 1:10; %1s-12s
WMdelay = 11:23; %13s-27s

%% avrg across delay
[ he pe] = ttest(mean(early_runs(:,PercepDelay),2)-mean(late_runs(:,PercepDelay),2));
fprintf('t-test results Early Delay: h = %d, p = %.5f\n',he,pe);
[ hl pl] = ttest(mean(early_runs(:,WMdelay),2)-mean(late_runs(:,WMdelay),2));
fprintf('t-test results Late Delay: h = %d, p = %.5f\n',hl,pl);

%% Visualization
% invert 
EarlyRuns = chance_level -mean(early_runs,1);
LateRuns = chance_level - mean(late_runs,1);

%% Plotting Early vs late 
T = -2:1:20;
color1 = [0.800 0.450 0.050]; % green
color2= [0.200 0.500 0.100 ]; % orange 

figure(1);
hold on;

%Add shaded background for Delays 
% fill([3 9 9 3], [0 0 20 20], [0.9 1 0.9], 'FaceAlpha', 0.4, 'EdgeColor', 'none');
% fill([11 20 20 11], [0 0 20 20], [0.9 0.9 1], 'FaceAlpha', 0.4, 'EdgeColor', 'none');

fill([T fliplr(T)],[EarlyRuns + SemEarly fliplr(EarlyRuns - SemEarly)],...
    color1,'FaceAlpha',0.2,'EdgeColor','none');
h1=plot(T,EarlyRuns,'LineWidth',2, 'Color',color1);
fill([T fliplr(T)],[LateRuns + SemLate fliplr(LateRuns - SemLate)],...
    color2,'FaceAlpha',0.2,'EdgeColor','none');
h2=plot(T,LateRuns,'LineWidth',2,'Color',color2);

%Labels and title
xlabel('Time', 'FontSize', 15, 'FontWeight', 'bold');
ylabel('Average angular deviation - Below chance', 'FontSize', 15, 'FontWeight', 'bold');
title('Fedility Across Sessions Visual Cortex', 'FontSize', 14, 'FontWeight', 'bold');
legend([h1 h2],{'Early Runs', 'Late Runs'}, 'Location', 'northeast', 'FontSize', 10);
% Horizontal reference line at y = 0
yline(0, 'k--','Chance level', 'LineWidth', 1.5);
% Adjust axes limits and grid
xlim([min(T), max(T)]);
ylim([-2, 30]);
% Aesthetic adjustments
set(gca, 'FontSize', 10, 'LineWidth', 1, 'Box', 'off');
hold off;

%% Bar Plot 
% Average across each delay periods for Early & Later phases
earlyPerc = chance_level - mean(early_runs(:,PercepDelay),2);
latePerc = chance_level - mean(late_runs(:,PercepDelay),2);
earlyWm = chance_level - mean(early_runs(:,WMdelay),2);
lateWm = chance_level - mean(late_runs(:,WMdelay),2);

data = [earlyPerc,latePerc,earlyWm,lateWm]; % 23x4
means = mean(data);
sems = std(data)./sqrt(38);

% paired t-test
[~,p_perc]= ttest(data(:,1) - data(:,2));
[~,p_wm]= ttest(data(:,3) -  data(:,4));

alpha= 0.05;
alpha_bonf = alpha/3; % for each ROI
sig_perc = p_perc <alpha_bonf;
sig_wm = p_wm<alpha_bonf;

clrEarly = [0.3 0.6 0.3];
clrLate = [0.6 0.3 0.1];
barColors = [clrEarly;clrLate;clrEarly;clrLate];

figure; hold on;
b=bar(1:4,means,0.6,'FaceColor','flat');
b.CData = barColors;
errorbar(1:4,means,sems,'k','LineStyle','none','LineWidth',1.2);

if sig_perc
    y = max(means(1:2)+sems(1:2))+0.5;
    text(mean([1,2]),y,"**",'HorizontalAlignment','center','FontSize',14);
end
if sig_wm
    y = max(means(3:4)+sems(3:4))+0.5;
    text(mean([3,4]),y,"**",'HorizontalAlignment','center','FontSize',14);
end


xticks(1:4);
xticklabels({'Perc Early','Perc Late','Wm Early','Wm Late'});
ylabel('Decoding Fidelity (°)');
title(' Decoding Fidelity by Session and Delays');
xlim([0.5 4.5]);
ylim([0, max(means+sems)+2]);

box off; 
set(gca,'FontSize',12);

%% checking for Linear Trend

% Average deviations across trials for each run (1-8)
MeanPerRun = -chance_level- squeeze(mean(dres, 3)); % Subject x FIRs x Runs
MeanPerRunPlot = squeeze(mean(MeanPerRun,[1 2]));
stdPerRunPlot = squeeze(std(MeanPerRun, [], [1 2]) / sqrt(size(MeanPerRun, 1)));

x = (1:8)';
y = MeanPerRunPlot' ;
mdl = fitlm(x,y);
disp(mdl);

slope = mdl.Coefficients.Estimate(2);
pValue =  mdl.Coefficients.pValue(2);

fprintf('Slope: %.4f, p-value: %.4f\n',slope,pValue);

figure(3);
hold on;
scatter(x,y,'r','filled');
plot(x,predict(mdl,x),'g','LineWidth',2);
xlabel('Run number');
ylabel('Mean Angle Difference');
title('Linear Trend Of Angle Difference Across Runs Visual Cortex');
grid on;
hold on;






