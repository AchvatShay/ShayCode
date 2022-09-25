function GLMRoisActivityExplainedByAllOtherROIsInDiffGroupPerExperimentPostA()
    MainFolder = '\\192.114.20.109\e\Maisan\2ph experiments\Analysis';
    AnimalName = 'CT67';
    DateAnimal = '22_08_26 HR tuft control';
    neuronNumberName = 'N1';
    RunnerDate = '31.3.22';
    RunnerNumber = 'Run3';
    minimumNumberOfROIsInDepth = 8;
    RunnerType = {'WithoutAutoExcludeROIs', 'WithAutoExcludeROIs'};
   
    for runnerTypeIndex = 1:length(RunnerType)
        outputpath = fullfile(MainFolder, AnimalName, ...
        DateAnimal, 'Analysis', neuronNumberName, 'Structural_VS_Functional',...
        RunnerDate,RunnerNumber, RunnerType{runnerTypeIndex});
        
        eventsDetectionFolder = fullfile(MainFolder, AnimalName, ...
        DateAnimal, 'Analysis', neuronNumberName, 'Structural_VS_Functional',...
        RunnerDate, RunnerNumber, 'EventsDetection');
    
        load([outputpath, '\roiActivityRawData.mat'], 'selectedROISplitDepth1');
        load([eventsDetectionFolder, '\roiActivity_comb.mat'], 'allEventsTable', 'roiActivity_comb');
    
        classesRoi = unique(selectedROISplitDepth1);
        
        numberOfROIsInDepth = nan(1, length(classesRoi));
        for i = 1: length(classesRoi)
            numberOfROIsInDepth(i) = sum(selectedROISplitDepth1==classesRoi(i));
        end
        
        if any(numberOfROIsInDepth < minimumNumberOfROIsInDepth)
            errormesage = 'we need at least minimum rois in each group to continue';
            error(errormesage);
        end
        
        eventsIndexLocation = [];
        for j = 1:size(allEventsTable, 1)
            eventsIndexLocation(end+1:end+(allEventsTable.pks(j)-allEventsTable.start(j))+1) = allEventsTable.start(j):allEventsTable.pks(j);
        end
        
        RsquareCompareDifferentGroups = nan(1, length(selectedROISplitDepth1));
        RsquareCompareSameGroups = nan(1, length(selectedROISplitDepth1));
        
        for j = 1:length(selectedROISplitDepth1)
            otherBranch = selectedROISplitDepth1 ~= selectedROISplitDepth1(j);
            mdlTest = fitglm(roiActivity_comb(eventsIndexLocation, otherBranch), roiActivity_comb(eventsIndexLocation, j));
            RsquareCompareDifferentGroups(j) = mdlTest.Rsquared.Adjusted;           
            
            sameBranch = ~(otherBranch);
            sameBranch(j) = 0;
            mdlTestSame = fitglm(roiActivity_comb(eventsIndexLocation, sameBranch), roiActivity_comb(eventsIndexLocation, j));
            RsquareCompareSameGroups(j) = mdlTestSame.Rsquared.Adjusted;           
        end
        
        
        f = figure; hold on;
        boxplot([RsquareCompareDifferentGroups', RsquareCompareSameGroups'], 'Labels',{'Diff group','Same group'});
        ylim([0,1]);
        ylabel('Rsquare GLM fit');
        ylabel('Rsquare');
        title('GLM Rois Activity Explained By All OtherROIs In Diff\Same Group');
        mysave(f, fullfile(outputpath, 'GLMRoisActivityExplainedByAllOtherROIsInDiffGroupPlot'));
        
        save(fullfile(outputpath, 'GLMRoisActivityExplainedByAllOtherROIsInDiffGroupResults.mat'), 'RsquareCompareSameGroups', 'RsquareCompareDifferentGroups', 'selectedROISplitDepth1');
    end
end