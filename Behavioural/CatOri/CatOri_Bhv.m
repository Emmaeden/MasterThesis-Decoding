close all; clear all; clc;
%% Dir of Logs
DatalogDir          = '/disco/joana/CategOri_MRI/CategOri_MRIdata/02_data/logs';
n_runs           = 8;
allSubjects = 1:45; allSubjects([14 15 20 25 36]) = []; 

%% Loop through Subjects
 AccuracyRuns = cell(length(allSubjects),8);
 RTRuns = cell(length(allSubjects),8);

for sub = allSubjects
    substr = ['sub' num2str(sub, '%02d')];
    folder = fullfile(DatalogDir, substr);

     logfile = dir(fullfile(folder, '*-orientation-*.mat'));
     [~, sortIdx] = sort({logfile.name});
     logfile = logfile(sortIdx);

    %% Loop through the 8 runs inside logData
    for runIdx = 1:8 
        logDataSub= load(fullfile(logfile(runIdx).folder,logfile(runIdx).name));
        %disp(['Processing Subject: ' substr ', Run: ' num2str(runIdx)]);
        % Extract relevant run data 
        Subsample = logDataSub.log.design.sample;
        Subresponse = logDataSub.log.behaviour.response;
        SubRT = logDataSub.log.behaviour.rt;
        SubValidTrials = ~isnan(Subsample) & ~isnan(Subresponse);  

        clean_response = Subresponse(SubValidTrials);
        clean_sample = Subsample(SubValidTrials);
        clean_rt = SubRT(SubValidTrials);  % RT only for valid trials

        % Compute circular absolute error
        abserror = abs(mod(clean_response - clean_sample + 180, 360) - 180);
        
        % Compute accuracy (trials within 15° threshold)
        correctTrials = abserror <= 10;
        accuracyPercentage = mean(correctTrials) * 100;

        AccuracyRuns{sub,runIdx} = accuracyPercentage;
        RTRuns{sub,runIdx}=mean(clean_rt(correctTrials));
        
    end
end

% Compare Early vs Late Runs 
[h1 p1 ] = ttest(mean(cell2mat(AccuracyRuns(:,1:4)))- mean(cell2mat(AccuracyRuns(:,5:8))));
[h2 p2 ] = ttest(mean(cell2mat(AccuracyRuns(:,[1 2 5 6])))- mean(cell2mat(AccuracyRuns(:,[3 4 7 8]))));
fprintf('Accuracy early vs late Across sessions p = %.4f\n',p1);
fprintf('Accuracy early vs late Within sessions p = %.4f\n',p2);

earlyRT =  mean(cell2mat(RTRuns(:,1:4))); %mean(cell2mat(RTRuns(:,[1 2 5 6 ])));
lateRT =   mean(cell2mat(RTRuns(:,5:8))); %mean(cell2mat(RTRuns(:,[3 4 7 8 ])));
[p3 h3 ] = signrank(earlyRT , lateRT)
%fprintf('RT early vs late Across sessions p = %.4f\n',p3);

%% Bar plot 
 accMat = cell2mat(AccuracyRuns);
 rtMat = cell2mat(RTRuns);

 earlyAcc = mean(accMat(:,1:4),2);
 lateAcc = mean(accMat(:,5:8),2);

 earlyRT = mean(rtMat(:,1:4),2);
 lateRT = mean(rtMat(:,5:8),2);

 %Within Session : early runs 1:8 late runs 9:16
%  earlyAcc = mean(accMat(:,[1 2 5 6]),2);
%  lateAcc = mean(accMat(:,[3 4 7 8]),2);
% 
%  earlyRT = mean(rtMat(:,[1 2 5 6]),2);
%  lateRT = mean(rtMat(:,[3 4 7 8]),2);

 % Mean and SEM
 meanAcc = [mean(earlyAcc),mean(lateAcc)];
 semAcc = [std(earlyAcc)/sqrt(39),std(lateAcc)/sqrt(39)];

 meanRT = [mean(earlyRT),mean(lateRT)];
 semRT = [std(earlyRT)/sqrt(39),std(lateRT)/sqrt(39)];

  figure; 
 subplot(1,2,1);
 b= bar(meanAcc);
 b.FaceColor='flat';
 b.CData=[0.800 0.450 0.050;0.200 0.500 0.100];
 hold on;

if p2 < 0.05
    y_star = max(meanAcc+semAcc)+2;
    plot([1 2], [y_star y_star],'k-','LineWidth',1.2);
    if p2 < 0.001
        sig_label ='***';
    elseif p2 < 0.01
        sig_label ='**';
    else 
        sig_label ='*';
    end
    text(1.5,y_star+0.001,sig_label,'FontSize',20,'HorizontalAlignment','center');
end

 
 errorbar(meanAcc,semAcc,'k.','LineWidth',1.2);
 set(gca,'XTickLabel',{'Early','Late'});
 ylabel('Accuracy (%)');
 ylim([50 100]);
 title('Accuracy Across Sessions ');

 subplot(1,2,2)
 
 b= bar(meanRT);
 b.FaceColor='flat';
 b.CData=[0.800 0.450 0.050;0.200 0.500 0.100];
 hold on;

if p3 < 0.05
    y_star = max(meanRT+semRT)+0.5;
    plot([1 2], [y_star y_star],'k-','LineWidth',1.2);
    if p3 < 0.001
        sig_label ='***';
    elseif p3 < 0.01
        sig_label ='**';
    else 
        sig_label ='*';
    end
    text(1.5,y_star+0.001,sig_label,'FontSize',20,'HorizontalAlignment','center');
end

 

 errorbar(meanRT,semRT,'k.','LineWidth',1.2);
 set(gca,'XTickLabel',{'Early','Late'});
 ylabel('RT Time (s)');
 ylim([1 5]);
 title('RT Across Sessions ');


