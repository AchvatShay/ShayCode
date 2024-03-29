function [roiActivityDistanceMatrixByH, roiActivityDistanceMatrixByPrecantage, roiActivityDistanceMatrixByPrecantageTh] = calcROIDistanceInActivity_WindowEventPearson_V3(roiActivity, roiActivityNames, selectedROI, all_event_table, typeCom, clusterNum, clusterCount)    
   
    for index = 1:length(selectedROI)
        activitylocation = strcmpi(roiActivityNames, selectedROI{index});
        
        for secIndex = (index):length(selectedROI)
            activitySeclocation = strcmp(roiActivityNames, selectedROI{secIndex});
           
            if secIndex == index
                 roiActivityDistanceMatrixByH(index, index, :) = [1, 0];
                 roiActivityDistanceMatrixByPrecantage(index, index, :) = [1, 0];
                 roiActivityDistanceMatrixByPrecantageTh(index, index, :) = [1, 0];
                continue;
            end
            
            locationToCompareByH = getLocTocompare(typeCom, clusterNum, all_event_table,(all_event_table.clusterByH), activitylocation, activitySeclocation, clusterCount);
            locationToCompareByPrecantage = getLocTocompare(typeCom, clusterNum, all_event_table,(all_event_table.clusterByRoiPrecantage), activitylocation, activitySeclocation, clusterCount);
            locationToCompareByPrecantageT = getLocTocompare(typeCom, clusterNum, all_event_table,(all_event_table.clusterByThresholdRoiPrecantage), activitylocation, activitySeclocation, max(all_event_table.clusterByThresholdRoiPrecantage));
            
            currentROIActivityByH = roiActivity(locationToCompareByH, activitylocation);
            secROIActivityByH = roiActivity(locationToCompareByH, activitySeclocation);
            
            currentROIActivityByP = roiActivity(locationToCompareByPrecantage, activitylocation);
            secROIActivityByP = roiActivity(locationToCompareByPrecantage, activitySeclocation);
            
            currentROIActivityByPT = roiActivity(locationToCompareByPrecantageT, activitylocation);
            secROIActivityByPT = roiActivity(locationToCompareByPrecantageT, activitySeclocation);
            
            if isempty(locationToCompareByH)
                roiActivityDistanceMatrixByH(index, secIndex, :) = [nan, nan];                
                roiActivityDistanceMatrixByH(secIndex, index, :) = [nan, nan];
            else   
                [corrEventsPeaksROIByH, pvalEventsPeaksROIByH] = corr([currentROIActivityByH, secROIActivityByH], 'type', 'Pearson');
                roiActivityDistanceMatrixByH(index, secIndex, :) = [corrEventsPeaksROIByH(1, 2), pvalEventsPeaksROIByH(1,2)];
                roiActivityDistanceMatrixByH(secIndex, index, :) = [corrEventsPeaksROIByH(1, 2), pvalEventsPeaksROIByH(1,2)];
            end         
            
            if isempty(locationToCompareByPrecantage)
                roiActivityDistanceMatrixByPrecantage(index, secIndex, :) = [nan, nan];
                roiActivityDistanceMatrixByPrecantage(secIndex, index, :) = [nan, nan];
            else   
                [corrEventsPeaksROIByP, pvalEventsPeaksROIByP] = corr([currentROIActivityByP, secROIActivityByP], 'type', 'Pearson');                
                roiActivityDistanceMatrixByPrecantage(index, secIndex, :) = [corrEventsPeaksROIByP(1, 2), pvalEventsPeaksROIByP(1,2)];
                roiActivityDistanceMatrixByPrecantage(secIndex, index, :) = [corrEventsPeaksROIByP(1, 2), pvalEventsPeaksROIByP(1,2)];
            end
            
            if isempty(locationToCompareByPrecantageT)
                roiActivityDistanceMatrixByPrecantageTh(index, secIndex, :) = [nan, nan];
                roiActivityDistanceMatrixByPrecantageTh(secIndex, index, :) = [nan, nan];
            else   
                [corrEventsPeaksROIByPT, pvalEventsPeaksROIByPT] = corr([currentROIActivityByPT, secROIActivityByPT], 'type', 'Pearson');                
                roiActivityDistanceMatrixByPrecantageTh(index, secIndex, :) = [corrEventsPeaksROIByPT(1, 2), pvalEventsPeaksROIByPT(1,2)];
                roiActivityDistanceMatrixByPrecantageTh(secIndex, index, :) = [corrEventsPeaksROIByPT(1, 2), pvalEventsPeaksROIByPT(1,2)];
            end
        end
    end
end

function locationToCompare = getLocTocompare(typeCom, clusterNum, all_event_table, indexByCluster, activitylocation, activitySeclocation, clusterCount)
    eventsIncluded = zeros(1, size(all_event_table, 1));
    for indexEvent = 1:size(all_event_table, 1)
        currentEventROIIndex = all_event_table.roisEvent{indexEvent};
        if sum(activitylocation & currentEventROIIndex') > 0 || sum(activitySeclocation & currentEventROIIndex') > 0
            eventsIncluded(indexEvent) = 1;
        end
    end

    eventsLocation = eventsIncluded == 1;
    indexByCluster = indexByCluster(eventsLocation);
    
    switch typeCom
        case 'FULL'
            startEventList = all_event_table.start(eventsLocation);            
            endEventList = all_event_table.event_end(eventsLocation);
        case 'ToPeak'
            startEventList = all_event_table.start(eventsLocation);            
            endEventList = all_event_table.pks(eventsLocation);
        case 'Peaks'
            startEventList = all_event_table.pks(eventsLocation);            
            endEventList = all_event_table.pks(eventsLocation);
    end
    
    if clusterNum == 0
        startEventListBycluster = startEventList;
        endEventListBycluster = endEventList;
    elseif clusterNum == -1
        startEventListBycluster = startEventList(indexByCluster ~= clusterCount);
        endEventListBycluster = endEventList(indexByCluster ~= clusterCount);
    else
        startEventListBycluster = startEventList(indexByCluster == clusterNum);
        endEventListBycluster = endEventList(indexByCluster == clusterNum);
    end
    
    locationToCompare = [];
    
    for i = 1:length(startEventListBycluster)
        locationToCompare = [locationToCompare, startEventListBycluster(i):endEventListBycluster(i)];
    end
end