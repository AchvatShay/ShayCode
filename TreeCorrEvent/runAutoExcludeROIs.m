function roisToExcludeByAuto = runAutoExcludeROIs(roiActivity, selectedROISplitDepth1, allEventsTable, outputPath)
    classesROIs = unique(selectedROISplitDepth1);
    roisToExcludeByAuto = [];

    indextoCompare = 1:size(roiActivity, 1);
    
    for i = 1:length(classesROIs)
        corrMatrix = ones(sum(selectedROISplitDepth1 == classesROIs(i)), sum(selectedROISplitDepth1 == classesROIs(i)));
        currentIndexing  = find(selectedROISplitDepth1 == classesROIs(i));
        
        for j = 1:length(currentIndexing)
            for k = (j+1):length(currentIndexing)
                if ~isempty(allEventsTable)
                    if isfile([outputPath, '\savedPearsonCorrelation.mat'])
                        load([outputPath, '\savedPearsonCorrelation.mat'], 'roiActivityDistanceMatrixByH');
                        currP(1,2) =  roiActivityDistanceMatrixByH(currentIndexing(j), currentIndexing(k));
                    else
                        indextoCompare = [];
                        for eventsIndex = 1:size(allEventsTable, 1)
                            roisActivebyEvent = allEventsTable.roisEvent{eventsIndex};
                            if roisActivebyEvent(currentIndexing(j)) == 1 || ...
                                    roisActivebyEvent(currentIndexing(k)) == 1
                                currIndexToAdd = allEventsTable.start(eventsIndex):allEventsTable.pks(eventsIndex);
                                indextoCompare(end+1:end+length(currIndexToAdd)) = currIndexToAdd;
                            end
                        end
                        
                        if isempty(indextoCompare)
                            currP(1,2) = nan;
                        else
                            currP = corr([roiActivity(indextoCompare, currentIndexing(j)), roiActivity(indextoCompare, currentIndexing(k))]);
                        end
                    end   
                else
                    currP = corr([roiActivity(indextoCompare, currentIndexing(j)), roiActivity(indextoCompare, currentIndexing(k))]);
                end
                
                corrMatrix(j, k) = currP(1,2);
                corrMatrix(k, j) = currP(1,2);
            end      
        end
        
        thresholdSum = sum(corrMatrix < 0.15, 'omitnan');
        thresholdPercentage = thresholdSum ./ length(currentIndexing);
        roisTobeExcluded = thresholdPercentage > 0.70;
        
        roisToExcludeByAuto(end+1:end+sum(roisTobeExcluded ~= 0)) = currentIndexing(roisTobeExcluded);
        
    end
end