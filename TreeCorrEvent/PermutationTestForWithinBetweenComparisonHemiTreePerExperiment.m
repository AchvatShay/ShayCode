function PermutationTestForWithinBetweenComparisonHemiTreePerExperiment(outputpath, roiActivityDistanceMatrix, selectedROISplitDepth1)
        withinBetweenLabels = [];
        correlationValues = [];    
        for i = 1:size(roiActivityDistanceMatrix, 1)
            for j = (i+1):size(roiActivityDistanceMatrix, 1)
                % 1 == Between , 0 == within
                withinBetweenLabels(end+1) = selectedROISplitDepth1(i) ~= selectedROISplitDepth1(j); 
                correlationValues(end+1) = roiActivityDistanceMatrix(i, j);
            end
        end

        nanValuesIndex = find(isnan(correlationValues));

        correlationValues(nanValuesIndex) = [];
        withinBetweenLabels(nanValuesIndex) = [];

        realMeanbetweenHemitree = mean(correlationValues(withinBetweenLabels==0)) - mean(correlationValues(withinBetweenLabels==1));

        permCount = 1000;
        permutationMeanbetweenHemitree = nan(1, permCount);
        for j = 1:permCount
            indexP1 = randperm(length(correlationValues));
            permutationMeanbetweenHemitree(j) = mean(correlationValues(withinBetweenLabels(indexP1)==0)) - mean(correlationValues(withinBetweenLabels(indexP1)==1));
        end

        
        pValueForTest = sum(permutationMeanbetweenHemitree > realMeanbetweenHemitree)./permCount;

        zscoreForTest = (realMeanbetweenHemitree - mean(permutationMeanbetweenHemitree)) ./ std(permutationMeanbetweenHemitree);
        SummaryZResults = zscoreForTest;
        SummaryPvResults = pValueForTest;
        SummaryPermValueResults = permutationMeanbetweenHemitree;
        SummaryRealValueResults = realMeanbetweenHemitree;

        
        f = figure; hold on;
        hist = histogram(permutationMeanbetweenHemitree);
        ylabel('Count');
        xlabel('Mean Correlation(within - between)');
        title(sprintf('Permutation Test For Correlation of Within vs Between Hemitree, Zscore %03f', zscoreForTest));
        plot([realMeanbetweenHemitree, realMeanbetweenHemitree], [0, max(hist.Values)], '--k')
        mysave(f, fullfile(outputpath, 'PermutationTestForWithinBetweenComparisonHemiTreePlot'))

        
        save(fullfile(outputpath, 'PermutationTestForWithinBetweenComparisonHemiTree.mat'), 'zscoreForTest', 'SummaryZResults','SummaryPvResults', 'SummaryPermValueResults', 'SummaryRealValueResults');
end