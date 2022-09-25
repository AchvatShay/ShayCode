function PermutationTestForWithinBetweenComparisonHemiTreePerExperimentPostA()
    MainFolder = '\\192.114.20.109\e\Maisan\2ph experiments\Analysis';
    AnimalName = 'CT67';
    DateAnimal = '22_08_26 HR tuft control';
    neuronNumberName = 'N1';
    RunnerDate = '31.3.22';
    RunnerNumber = 'Run3';
    RunnerType = {'WithoutAutoExcludeROIs', 'WithAutoExcludeROIs'};
   
    for runnerTypeIndex = 1:length(RunnerType)
        outputpath = fullfile(MainFolder, AnimalName, ...
        DateAnimal, 'Analysis', neuronNumberName, 'Structural_VS_Functional',...
        RunnerDate,RunnerNumber, RunnerType{runnerTypeIndex});

        experimentData = load(fullfile(outputpath, 'roiActivityRawData.mat'));
        correlationData = load(fullfile(outputpath, 'savedPearsonCorrelation.mat'));

        withinBetweenLabels = [];
        correlationValues = [];    
        for i = 1:size(correlationData.roiActivityDistanceMatrixByH, 1)
            for j = (i+1):size(correlationData.roiActivityDistanceMatrixByH, 1)
                % 1 == Between , 0 == within
                withinBetweenLabels(end+1) = experimentData.selectedROISplitDepth1(i) ~= experimentData.selectedROISplitDepth1(j); 
                correlationValues(end+1) = correlationData.roiActivityDistanceMatrixByH(i, j);
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

        f = figure; hold on;
        hist = histogram(permutationMeanbetweenHemitree);
        ylabel('Count');
        xlabel('Mean Correlation(within - between)');
        title('Permutation Test For Correlation of Within vs Between Hemitree');
        plot([realMeanbetweenHemitree, realMeanbetweenHemitree], [0, max(hist.Values)], '--k')
        mysave(f, fullfile(outputpath, 'PermutationTestForWithinBetweenComparisonHemiTreePlot'))

        pValueForTest = sum(permutationMeanbetweenHemitree > realMeanbetweenHemitree)./permCount;

        zscoreForTest = (realMeanbetweenHemitree - mean(permutationMeanbetweenHemitree)) ./ std(permutationMeanbetweenHemitree);
        SummaryZResults = zscoreForTest;
        SummaryPvResults = pValueForTest;
        SummaryPermValueResults = permutationMeanbetweenHemitree;
        SummaryRealValueResults = realMeanbetweenHemitree;

        save(fullfile(outputpath, 'PermutationTestForWithinBetweenComparisonHemiTree.mat'), 'zscoreForTest', 'SummaryZResults','SummaryPvResults', 'SummaryPermValueResults', 'SummaryRealValueResults');
    end
end