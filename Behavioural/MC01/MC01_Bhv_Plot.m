close all; clear all;clc

%% Load the data
load('MC01-Bhv-WithinSessions.mat'); 

% Extract data from the structure in presentage
early_accuracies = res.early_accuracies .* 100;
late_accuracies = res.late_accuracies .* 100;

early_Rt = res.early_rt_avg_subjects/1000;
late_Rt = res.late_rt_avg_subjects/1000;

% pair ttest
[h p stat] = ttest(early_accuracies-late_accuracies)
[hrt prt statrt] = ttest(early_Rt-late_Rt)

%  (SEM) for early and late accuracies
early_mean = mean(early_accuracies);
late_mean = mean(late_accuracies);
early_sem = std(early_accuracies) / sqrt(36);
late_sem = std(late_accuracies) / sqrt(36);

%  (SEM) for early and late RT
early_meanRT = mean(early_Rt);
late_meanRT = mean(late_Rt);
early_semRT = std(early_Rt) / sqrt(36);
late_semRT = std(late_Rt) / sqrt(36);


% Define colors for bars
color_early = [0.800 0.450 0.050]; 
color_late = [0.200 0.500 0.100]; 

% Mean and SEM
 meanAcc = [early_mean,late_mean];
 semAcc = [early_sem,late_sem];

 meanRT = [early_meanRT,late_meanRT];
 semRT = [early_semRT,late_semRT];

 figure; 
 subplot(1,2,1);
 b= bar(meanAcc);
 b.FaceColor='flat';
 b.CData=[0.800 0.450 0.050;0.200 0.500 0.100];
 hold on;
 x=1:2;
 errorbar(x,meanAcc,semAcc,'k.','LineWidth',1.2);

 set(gca,'XTickLabel',{'Early','Late'});
 ylabel('Accuracy (%)');
 ylim([50 100]);
 y = max(meanAcc)+5;
 line([1 2],[y y],'Color','k','LineWidth',1.2);
 text(1.5,y+1,getSigSymbol(p),'HorizontalAlignment','center','Fontsize',14);
 title('Accuracy: Early vs Late Across Sessions ');

 subplot(1,2,2)
 b= bar(meanRT);
 b.FaceColor='flat';
 b.CData=[0.800 0.450 0.050;0.200 0.500 0.100];
 hold on;
 x=1:2;
 errorbar(x,meanRT,semRT,'k.','LineWidth',1.2);
 set(gca,'XTickLabel',{'Early','Late'});
 ylabel('RT Time (s)');
 ylim([1 5]);
 y = max(meanRT)+0.2;
 line([1 2],[y y],'Color','k','LineWidth',1.2);
 text(1.5,y + 0.1, getSigSymbol(prt),'HorizontalAlignment','center','Fontsize',14);
 title('RT: Early vs Late Across Runs ');
 

