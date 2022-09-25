function GLMRoisActivityExplainedByAllOtherROIsInDiffGroupPerExperiment(outputpath, roiActivity_comb, allEventsTable, selectedROISplitDepth1)
    classesRoi = unique(selectedROISplitDepth1);

    numberOfROIsInDepth = nan(1, length(classesRoi));
    for i = 1: length(classesRoi)
        numberOfROIsInDepth(i) = sum(selectedROISplitDepth1==classesRoi(i));
    end

    if any(numberOfROIsInDepth < 8)
        errormesage = 'we need at least 8 minimum rois in each group to continue';
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
    boxplot([RsquareCompareDifferentGroups', RsquareCompareSameGroups'], 'Labels',{'ContraLateral','IpsiLateral'});
    ylim([0,1]);
    ylabel('Rsquare Linear Regression');
    ylabel('Rsquare');
    title('Linear Regression Rois Activity Explained By All OtherROIs In Contra\Ipsi Group');
    mysave(f, fullfile(outputpath, 'GLMRoisActivityExplainedByAllOtherROIsInDiffGroupPlot'));

    save(fullfile(outputpath, 'GLMRoisActivityExplainedByAllOtherROIsInDiffGroupResults.mat'), 'RsquareCompareSameGroups', 'RsquareCompareDifferentGroups', 'selectedROISplitDepth1');
end
