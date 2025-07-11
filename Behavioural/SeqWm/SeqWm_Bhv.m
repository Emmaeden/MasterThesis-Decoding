close all; clear all; clc;
%% Dir of Logs
DatalogDir          = '/disco/vivien/SeqWM/02_data/A_RAW';
allSubjects = 1:24; 
allSubjects(9) = [];  % Remove subject 9 if needed

%% Loop through Subjects
 AccuracyRuns = cell(length(allSubjects),16);
 RTRuns = cell(length(allSubjects),16);

%% Loop through Subjects
for sub = allSubjects
    substr = ['sub' num2str(sub, '%02d')];
    folder = fullfile(DatalogDir, substr, 'behav');
  
    logFilePath = fullfile(folder, ['sub' num2str(sub, '%02d') '-allDat.mat']);
    logData = load(logFilePath);  % Load the struct with all runs

    %% Loop through the 16 runs inside logData
    for runIdx = 1:16  % Assuming 16 runs per subject
        %disp(['Processing Subject: ' substr ', Run: ' num2str(runIdx)]);
        % Extract relevant run data
        runData = logData.Value(runIdx);  % Get the specific run's data
        Subcue = runData.design.cue;
        Subsample = runData.design.target;
        
        Subsample(Subsample < 0) = Subsample(Subsample < 0) + 180;
        Subsample = round(Subsample);

        SubRT = runData.behaviour.rt;
        Subresponse =runData.behaviour.response;

        SubValidTrials = ~isnan(Subsample) & ~isnan(Subresponse);  

        clean_response = Subresponse(SubValidTrials);
        clean_sample = Subsample(SubValidTrials);
        clean_rt = SubRT(SubValidTrials);  % RT only for valid trials

        % Compute circular absolute error
        abserror = min(min(clean_response-(clean_sample-180), clean_response-(clean_sample+180),"ComparisonMethod","abs"),clean_response-(clean_sample),"comparisonMethod","abs");
        
        % Compute accuracy 
        correctTrials = abs(abserror);
        accuracyPercentage = mean(correctTrials);

        AccuracyRuns{sub,runIdx} = accuracyPercentage;
        RTRuns{sub,runIdx}=mean(clean_rt);
        
    end
end

% Compare Early vs Late Runs 
% Pair ttest
[h_acc p1 stat_acc] = ttest(mean(cell2mat(AccuracyRuns(:,1:8)))- mean(cell2mat(AccuracyRuns(:,9:16))));
[h2 p2 stat2] = ttest(mean(cell2mat(AccuracyRuns(:,[1 2 5 6 9 10 13 14])))- mean(cell2mat(AccuracyRuns(:,[3 4 7 8 11 12 15 16]))));
fprintf('Accuracy early vs late Across sessions p = %.4f\n',p1);
fprintf('Accuracy early vs late Within sessions p = %.4f\n',p2);
earlyRT = mean(cell2mat(RTRuns(:,1:8))); % mean(cell2mat(RTRuns(:,[1 2 5 6 9 10 13 14])));
lateRT = mean(cell2mat(RTRuns(:,9:16))); % mean(cell2mat(RTRuns(:,[3 4 7 8 11 12 15 16])))
[p3 h3] = signrank(earlyRT , lateRT);
fprintf('RT early vs late Across sessions p = %.4f\n',p3);


%% Bar plot 
 accMat = cell2mat(AccuracyRuns);
 rtMat = cell2mat(RTRuns);

 AcrossSessionsEarly = 1:8; AcrossSessionsLate = 9:16;
 %AcrossSessionsEarly = [1 2 5 6 9 10 13 14]; AcrossSessionsLate = [5 6 7 8 13 14 15 16];
 
 earlyAcc = mean(accMat(:,AcrossSessionsEarly),2);
 lateAcc = mean(accMat(:,AcrossSessionsLate),2);

 earlyRT = mean(rtMat(:,AcrossSessionsEarly),2);
 lateRT = mean(rtMat(:,AcrossSessionsLate),2);


 % Mean and SEM
 meanAcc = [mean(earlyAcc),mean(lateAcc)];
 semAcc = [std(earlyAcc)/sqrt(size(accMat,1)),std(lateAcc)/sqrt(size(accMat,1))];

 meanRT = [mean(earlyRT),mean(lateRT)];
 semRT = [std(earlyRT)/sqrt(size(rtMat,1)),std(lateRT)/sqrt(size(rtMat,1))];

 figure; 
 subplot(1,2,1);
 b= bar(meanAcc);
 b.FaceColor='flat';
 b.CData=[0.800 0.450 0.050;0.200 0.500 0.100];
 hold on;

if p1 < 0.05
    y_star = max(meanAcc+semAcc)+2;
    plot([1 2], [y_star y_star],'k-','LineWidth',1.2);
    if p1 < 0.001
        sig_label ='***';
    elseif p1 < 0.01
        sig_label ='**';
    else 
        sig_label ='*';
    end
    text(1.5,y_star+0.001,sig_label,'FontSize',20,'HorizontalAlignment','center');
end

 
 errorbar(meanAcc,semAcc,'k.','LineWidth',1.2);
 set(gca,'XTickLabel',{'Early','Late'});
 ylabel('Recall Error');
 ylim([0 30]);
 title('Recall Error ');

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
 title('Reation Time ');


