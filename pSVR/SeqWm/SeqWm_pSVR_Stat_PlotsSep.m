
close all; clear all; clc;
%% Load Results and Prepare Data

resPath = '/disco/emma/SeqWmResNew/psvr_results_Sep/resR_pSVR_SeqWm_New/wV1-V3_Mask';
addpath(resPath);
files = dir(fullfile(resPath, '*Sep.mat'));
resEarly = NaN(23,25,48,8); %36 subjects, 16 trials, 8 runs
resLate = NaN(23,25,48,8);

% Load and reshape data
for ii = 1:numel(files)
    ld = load(fullfile(resPath, files(ii).name));
    for fir=1:25
        reshapedDataEarly = reshape(ld.D.early.angle_diff{fir}, [48 8]); % (subject x trials x runs)
        resEarly(ii,fir, :, :) = reshapedDataEarly; 
        reshapedDataLate = reshape(ld.D.late.angle_diff{fir}, [48 8]); % (subject x trials x runs)
        resLate(ii,fir, :, :) = reshapedDataLate; 
    end
end

 dresEarly =rad2deg(resEarly);
 dresEarly = abs(dresEarly);
 dresLate =rad2deg(resLate);
 dresLate = abs(dresLate);

%% Compute Early and Late Runs
% Average deviations across trial for early and late
chance_level =90;

early_runs =  mean(dresEarly, [3,4]) ; % subject X time
late_runs =  mean(dresLate, [3,4]) ;

SemEarly = std(early_runs,1)/sqrt(23);
SemLate =  std(late_runs,1)/sqrt(23);

%% Pair ttest across subjects 1xFIRs
early_means = chance_level - mean(early_runs,2);
late_means = chance_level - mean(late_runs,2) ;

% pair ttest
[h ,p, stat] = ttest(early_means-late_means);
fprintf('Pair t-test Across Subjects in the VC  EarlySess - LateSess: h = %d, p =  stat %.5f\n',h,p);

%% Time vrctors for delays
PercepDelay = 3:10; % FIRs 0:10 Perception 
WMdelay = 14:23;  % FIRs 11:end Working Memory 
 
%% avrg across delay
[ he pe state] = ttest(mean(early_runs(:,PercepDelay),2)-mean(late_runs(:,PercepDelay),2));
fprintf('t-test results Percep: h = %d, p = %.5f\n',he,pe);
[ hl pl statl] = ttest(mean(early_runs(:,WMdelay),2)-mean(late_runs(:,WMdelay),2));
fprintf('t-test results WM Delay: h = %d, p = %.5f\n',hl,pl);

%% Visualization
% invert 
EarlyRuns = chance_level - mean(early_runs,1);
LateRuns =  chance_level - mean(late_runs,1);

%% Plotting Early vs late 
T = -2:1:22;
color1 = [0.800 0.450 0.050]; % green
color2= [0.200 0.500 0.100 ]; % orange 

figure(1);
hold on;

%Add shaded background for Delays : Perception(6:12), and WM(14:22)
% fill([0 10 10 0], [0 0 20 20], [0.9 1 0.9], 'FaceAlpha', 0.4, 'EdgeColor', 'none');
% fill([11 22 22 11], [0 0 20 20], [0.9 0.9 1], 'FaceAlpha', 0.4, 'EdgeColor', 'none');

% errorbar(T,invEarlyRuns,SemEarly,'-o','LineWidth',1,'MarkerSize',4,'Color',color1);
% errorbar(T,invLateRuns,SemLate,'-o','LineWidth',1,'MarkerSize',4,'Color',color2);

fill([T fliplr(T)],[EarlyRuns + SemEarly fliplr(EarlyRuns - SemEarly)],...
    color2,'FaceAlpha',0.2,'EdgeColor','none');
h1=plot(T,EarlyRuns,'LineWidth',2, 'Color',color2);
fill([T fliplr(T)],[LateRuns + SemLate fliplr(LateRuns - SemLate)],...
    color1,'FaceAlpha',0.2,'EdgeColor','none');
h2=plot(T,LateRuns,'LineWidth',2,'Color',color1);



%Labels and title
xlabel('Time', 'FontSize', 15, 'FontWeight', 'bold');
ylabel('Above chance Decoding', 'FontSize', 15, 'FontWeight', 'bold');
title('Fedility Across Time For V1-V3', 'FontSize', 14, 'FontWeight', 'bold');

% Legend
legend([h1 h2],{'Early Runs', 'Late Runs'}, 'Location', 'northeast', 'FontSize', 10);

% Horizontal reference line at y = 0
yline(0, 'k--','Chance level', 'LineWidth', 1.5);

% Adjust axes limits and grid
   xlim([min(T), max(T)]);
   ylim([-2 15]);

% Aesthetic adjustments
set(gca, 'FontSize', 10, 'LineWidth', 1, 'Box', 'off');
hold off;

%% Bar Plot 

% Average across each delay periods for Early& Late Sessions
earlyPerc =  chance_level - mean(early_runs(:,PercepDelay),2);
latePerc =  chance_level - mean(late_runs(:,PercepDelay),2);
earlyWm =  chance_level - mean(early_runs(:,WMdelay),2);
lateWm =  chance_level - mean(late_runs(:,WMdelay),2);

data = [earlyPerc,latePerc,earlyWm,lateWm]; % 23x4
means = mean(data);
sems = std(data)./sqrt(23);

% paired t-test
[~,p_perc]= ttest(data(:,1) - data(:,2));
[~,p_wm]= ttest(data(:,3) -  data(:,4));

alpha= 0.05;
alpha_bonf = alpha; % for each ROI
sig_perc = p_perc <alpha_bonf;
sig_wm = p_wm<alpha;

clrEarly = [0.3 0.6 0.3];
clrLate = [0.6 0.3 0.1];
barColors = [clrEarly;clrLate;clrEarly;clrLate];

figure; hold on;
b=bar(1:4,means,0.6,'FaceColor','flat');
b.CData = barColors;

errorbar(1:4,means,sems,'k','LineStyle','none','LineWidth',1.2);

% lines for percp

if sig_perc
    y = max(means(1:2)+sems(1:2))+0.01;
    text(mean([1,2]),y,"*",'HorizontalAlignment','center','FontSize',14);
end
if sig_wm
    y = max(means(3:4)+sems(3:4))+0.01;
    text(mean([3,4]),y,"*",'HorizontalAlignment','center','FontSize',14);
end


xticks(1:4);
xticklabels({'Perc Early','Perc Late','Wm Early','Wm Late'});
ylabel('Decoding Fidelity (°)');
title(' Decoding Fidelity in Perception vs WM Delay phases in sPCS');
xlim([0.5 4.5]);
ylim([0, max(means+sems)+2]);

box off; 
set(gca,'FontSize',12);

%% checking for Linear Trend

% Average deviations across trials for each run (1-8)
dresAll = cat(4,dresEarly,dresLate);% Subject x FIRs x Runs
MeanPerRun = squeeze(mean(dresAll,[2 3])) - chance_level;

MeanPerRunPlot = squeeze(mean(MeanPerRun,1));
stdPerRunPlot = squeeze(std(MeanPerRun, [], 1) / sqrt(size(MeanPerRun, 1)));



x = (1:16)';
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
ylabel('Mean Angle Difference - below Chance');
title('Linear Trend Of Angle Difference Across Learning Phases in sPCS');
grid on;
hold on;

%% 
ROI_list = {'wV1-V3_Mask','wIPS_Mask','wsPCS_Mask'};
root_path= '/disco/emma/SeqWmResNew/psvr_results_Sep/resR_pSVR_SeqWm_New';



