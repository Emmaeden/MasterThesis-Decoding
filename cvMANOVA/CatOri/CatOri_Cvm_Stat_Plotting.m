close all; clear all; clc;
%% load results 


load CatOri_AcrossSessions_CVM.mat
DsEarly = cat(3, Results_Early{:});
DsEarly = reshape([DsEarly{:}], size(DsEarly));
DsEarly = permute(DsEarly, [3, 1, 2]);

% load CatOri_WithinSessions_Late.mat
DsLate = cat(3, Results_Late{:});
DsLate = reshape([DsLate{:}], size(DsLate));
DsLate = permute(DsLate, [3, 1, 2]);

%% ttest across Time
MeanSubEarly = mean(DsEarly(:,:,1),2); % whole delay 1-16 s
MeanSubLate = mean(DsLate(:,:,1),2);
[hsub ,psub] = ttest(MeanSubEarly-MeanSubLate);
fprintf('t-test results Across Time : h = %d, p = %.5f\n',hsub,psub);

%%
percDelay = 1:10; % 1-8 s
WmDelay = 11:20;  % 9-16 s
%% ttest
[ he pe] = ttest(mean(DsEarly(:,percDelay,1),2)-mean(DsLate(:,percDelay,1),2));
fprintf('t-test results Early Delay: h = %d, p = %.5f\n',he,pe);
[ hl pl] = ttest(mean(DsEarly(:,WmDelay,1),2)-mean(DsLate(:,WmDelay,1),2));
fprintf('t-test results Late Delay: h = %d, p = %.5f\n',hl,pl);

%% Sem
SemEarly = std(DsEarly(:,:,3),[],1)/sqrt(39);
SemLate =  std(DsLate(:,:,3),[],1)/sqrt(39);



%% Plotting 
T = -2:1:23;
EarlyT_sec = [0 10];
LateT_sec = [11 23];
color1 = [0.800 0.450 0.050]; % green
color2= [0.200 0.500 0.100 ]; % orange 

meanEarly = squeeze(mean(DsEarly(:,:,3),1));
meanLate =  squeeze(mean(DsLate(:,:,3),1));




figure(1);
hold on;


fill([T, fliplr(T)], [meanEarly + SemEarly, fliplr(meanEarly - SemEarly)],...
    color1,'FaceAlpha',0.2,'EdgeColor','none');
fill([T, fliplr(T)], [meanLate + SemLate, fliplr(meanLate - SemLate)],...
    color1,'FaceAlpha',0.2,'EdgeColor','none');

h1 =plot(T,mean(DsEarly(:,:,3),1),'LineWidth',2, 'Color',color1);
h2 =plot(T,mean(DsLate(:,:,3),1),'LineWidth',2,'Color',color2);

%Add shaded background for specific intervals 

fill([EarlyT_sec fliplr(EarlyT_sec)], [repmat(-0.01,1,2) repmat(0.5,1,2)],...
    [0.7 0.7 0.9], 'FaceAlpha',0.15,'EdgeColor','none');
% shaded region for late delay
fill([LateT_sec fliplr(LateT_sec)], [repmat(-0.01,1,2) repmat(0.5,1,2)],...
    [0.9 0.8 0.7], 'FaceAlpha',0.15,'EdgeColor','none');

%Labels and title
xlabel('Time (s)', 'FontSize', 15, 'FontWeight', 'bold');
ylabel('Pattern Distinctness', 'FontSize', 15, 'FontWeight', 'bold');
title('Average Pattern Distinctness over Time - V1-V3', 'FontSize', 14, 'FontWeight', 'bold');

% Legend
legend([h1 h2],{'Early Runs', 'Late Runs'}, 'Location', 'northeast', 'FontSize', 10);

% Horizontal reference line at y = 0
yline(0, 'k--', 'LineWidth', 1);

% Adjust axes limits and grid
xlim([min(T), max(T)]);
ylim([-0.01, 0.5]);
grid on;

% Aesthetic adjustments
set(gca, 'FontSize', 10, 'LineWidth', 1, 'Box', 'off');


hold off;

%% Bar plot mean and error bar 
numROIs = size(DsEarly,3);
meanEarly = zeros(1,numROIs);
meanLate = zeros(1,numROIs);
semEarlybar = zeros(1,numROIs);
semLatebar =zeros(1,numROIs);
p_values = zeros(1,numROIs);

for roi = 1:numROIs

    meanEarly(roi)= mean(DsEarly(:,:,roi),'all');
    meanLate(roi)=  mean(DsLate(:,:,roi),'all');

    semEarlybar(roi)= std(mean(DsEarly(:,:,roi),2),[],1)/sqrt(size(DsEarly,1));
    semLatebar(roi)=  std(mean(DsLate(:,:,roi),2),[],1)/sqrt(size(DsLate,1));

    [he,p_values(roi)]= ttest(mean(DsEarly(:,:,roi),2)-mean(DsLate(:,:,roi),2));
    fprintf('ROI %d: t-test result: p= %.5f\n', roi, p_values(roi))
end

% Bonferroni Correction
p_bonf = 0.05; %min(p_values*numROIs,1);
disp('Bonferroni correction p-values: ');
disp(p_bonf);

barData = [meanEarly;meanLate]'; % transpose
semData = [semEarlybar; semLatebar]';

figure;
b= bar(barData,'grouped');
hold on;
b(1).FaceColor=[0.9290 0.6940 0.1250]; %Early
b(2).FaceColor=[0.4660 0.6740 0.1880]; %Late

xPos = nan(size(barData));
for i =1:numel(b)
    xPos(:,i)= b(i).XEndPoints(:);
end

disp(size(b));
disp(size(barData));
disp(size(semData));


errorbar(xPos,barData,semData,'k','LineStyle','none','LineWidth',1.5);
for r=1:numROIs
    y_max = max(barData(r,:)) + max(semData(r,:))+0.0001;
    x_center = mean(xPos(r,:)); % to center between early and late bars
    if p_values(r)<0.001
       text(x_center, y_max, '***', 'HorizontalAlignment','center','FontSize',11);
    elseif p_values(r)<0.01
        text(x_center, y_max, '**', 'HorizontalAlignment','center','FontSize',11);
    elseif p_values(r)<0.05
        text(x_center, y_max, '*', 'HorizontalAlignment','center','FontSize',11);
    else
        text(x_center, y_max, 'n.s.', 'HorizontalAlignment','center','FontSize',11);
    end
end

xticks(1:size(barData,1));
xticklabels({'Visual Cortex','IPS','sPCS'});
ylabel('Pattern Distinctness per ROI');
ylim([0 0.15])
legend({'Early','Later'},'Location','northeast');

title('Early Learning phase vs Later learning phase Across Sessions ')

hold off;

%% Bar Plot for perception interval and WM interval for each ROIs

numROIs = size(DsEarly, 3);
numSubjects = size(DsEarly, 1);

% conditions: percEarly, percLate, wmEarly, wmLate
meanVals  = zeros(4, numROIs);
semVals   = zeros(4, numROIs);
p_vals    = zeros(2, numROIs);  % row 1 = perc, row 2 = wm

for roi = 1:numROIs
    
    e = squeeze(DsEarly(:,:,roi)); % [subjects × FIRs]
    l = squeeze(DsLate(:,:,roi));

    % Average per subject across FIRs
    percEarly = mean(e(:, percDelay), 2);   % [23×1]
    percLate  = mean(l(:, percDelay), 2);
    WmEarly   = mean(e(:, WmDelay), 2);
    WmLate    = mean(l(:, WmDelay), 2);

    % Store means and SEMs
    meanVals(:,roi) = [mean(percEarly); mean(percLate); mean(WmEarly); mean(WmLate)];
    semVals(:,roi)  = [std(percEarly)/sqrt(numSubjects); std(percLate)/sqrt(numSubjects);
                       std(WmEarly)/sqrt(numSubjects);   std(WmLate)/sqrt(numSubjects)];

    % Paired t-tests
    [~, p_vals(1,roi)] = ttest(percEarly - percLate);
    [~, p_vals(2,roi)] = ttest(WmEarly - WmLate);
end

% Bonferroni correction
p_bonf =   p_vals ; %min(p_vals * numROIs, 1);

% Plotting 
figure;
barHandle = bar(meanVals', 'grouped'); hold on;

% Set bar colors
colors = [0.2 0.6 0.3; 0.8 0.4 0.1];  % green, orange
for i = 1:2
    barHandle(i).FaceColor = colors(i,:);
end
for i = 3:4
    barHandle(i).FaceColor = colors(i-2,:)*0.6;
end

% Error bars
numConditions = 4;
groupWidth = min(0.8, numConditions/(numConditions + 1.5));
for i = 1:numConditions
    x = (1:numROIs) - groupWidth/2 + (2*i-1) * groupWidth / (2*numConditions);
    errorbar(x, meanVals(i,:), semVals(i,:), 'k', 'linestyle', 'none', 'LineWidth', 1.5);
end

% Significance markers
for roi = 1:numROIs
    % perception
    if p_bonf(1,roi) < 0.05
        x = mean([barHandle(1).XEndPoints(roi), barHandle(2).XEndPoints(roi)]);
        y = max(meanVals(1:2,roi)) + max(semVals(1:2,roi)) + 0.001;
        text(x, y, '*', 'FontSize', 14, 'HorizontalAlignment', 'center');
    end
    % wm
    if p_bonf(2,roi) < 0.05
        x = mean([barHandle(3).XEndPoints(roi), barHandle(4).XEndPoints(roi)]);
        y = max(meanVals(3:4,roi)) + max(semVals(3:4,roi)) + 0.001;
        text(x, y, '*', 'FontSize', 14, 'HorizontalAlignment', 'center');
    end
end

% Labels
xticks(1:numROIs);
xticklabels({'V1-V3','IPS','sPCS'});
legend({'Perc Early','Perc Late','WM Early','WM Late'}, 'Location','northeast');
ylabel('Decoding Fidelity (°)');
title('Decoding Fidelity Across Sessions per ROI');
set(gca, 'FontSize', 12);




