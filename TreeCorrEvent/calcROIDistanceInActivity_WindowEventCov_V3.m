function [roiActivityDistanceMatrixByH, roiActivityDistanceMatrixByPrecantage, roiActivityDistanceMatrixByPrecantageTh] = calcROIDistanceInActivity_WindowEventCov_V3(roiActivity, roiActivityNames, selectedROI, all_event_table, typeCom, clusterNum, clusterCount)
    
    roiActivityDistanceMatrixByH(:,:, 1) = ones(length(selectedROI), length(selectedROI));
    roiActivityDistanceMatrixByPrecantage(:,:,1) = ones(length(selectedROI), length(selectedROI));
    roiActivityDistanceMatrixByPrecantageTh(:,:,1) = ones(length(selectedROI), length(selectedROI));
    
    roiActivityDistanceMatrixByH(:,:, 2) = 0;
    roiActivityDistanceMatrixByPrecantage(:,:,2) = 0;
    roiActivityDistanceMatrixByPrecantageTh(:,:,2) = 0;
   
    
    for index = 1:length(selectedROI)
        activitylocation = strcmpi(roiActivityNames, selectedROI{index});
        
        for secIndex = (index+1):length(selectedROI)
            activitySeclocation = strcmp(roiActivityNames, selectedROI{secIndex});
           
            locationToCompareByH = getLocTocompare(clusterCount, typeCom, clusterNum, all_event_table,(all_event_table.clusterByH), activitylocation, activitySeclocation);
            locationToCompareByPrecantage = getLocTocompare(clusterCount, typeCom, clusterNum, all_event_table,(all_event_table.clusterByRoiPrecantage), activitylocation, activitySeclocation);
            locationToCompareByPrecantageTh = getLocTocompare(clusterCount, typeCom, clusterNum, all_event_table,(all_event_table.clusterByThresholdRoiPrecantage), activitylocation, activitySeclocation);
            
            currentROIActivityByH = roiActivity(locationToCompareByH, activitylocation);
            secROIActivityByH = roiActivity(locationToCompareByH, activitySeclocation);
            
            currentROIActivityByH = zscore(currentROIActivityByH);
            secROIActivityByH = zscore(secROIActivityByH);
            
            currentROIActivityByP = roiActivity(locationToCompareByPrecantage, activitylocation);
            secROIActivityByP = roiActivity(locationToCompareByPrecantage, activitySeclocation);
           
            currentROIActivityByP = zscore(currentROIActivityByP);
            secROIActivityByP = zscore(secROIActivityByP);
            
            currentROIActivityByPT = roiActivity(locationToCompareByPrecantageTh, activitylocation);
            secROIActivityByPT = roiActivity(locationToCompareByPrecantageTh, activitySeclocation);
           
            currentROIActivityByPT = zscore(currentROIActivityByPT);
            secROIActivityByPT = zscore(secROIActivityByPT);
            
            
            if isempty(locationToCompareByPrecantageTh)
                roiActivityDistanceMatrixByPrecantageTh(index, secIndex) = nan;
                roiActivityDistanceMatrixByPrecantageTh(secIndex, index) = nan;
            else   
                corrEventsPeaksROIByPT = cov(currentROIActivityByPT, secROIActivityByPT);
                roiActivityDistanceMatrixByPrecantageTh(index, secIndex) = corrEventsPeaksROIByPT(1, 2);
                roiActivityDistanceMatrixByPrecantageTh(secIndex, index) = corrEventsPeaksROIByPT(1, 2);
            end  
            
            if isempty(locationToCompareByH)
                roiActivityDistanceMatrixByH(index, secIndex) = nan;
                roiActivityDistanceMatrixByH(secIndex, index) = nan;
            else   
                corrEventsPeaksROIByH = cov(currentROIActivityByH, secROIActivityByH);
                roiActivityDistanceMatrixByH(index, secIndex) = corrEventsPeaksROIByH(1, 2);
                roiActivityDistanceMatrixByH(secIndex, index) = corrEventsPeaksROIByH(1, 2);
            end         
            
            if isempty(locationToCompareByPrecantage)
                roiActivityDistanceMatrixByPrecantage(index, secIndex) = nan;
                roiActivityDistanceMatrixByPrecantage(secIndex, index) = nan;
            else   
                corrEventsPeaksROIByP = cov(currentROIActivityByP, secROIActivityByP);
                roiActivityDistanceMatrixByPrecantage(index, secIndex) = corrEventsPeaksROIByP(1, 2);
                roiActivityDistanceMatrixByPrecantage(secIndex, index) = corrEventsPeaksROIByP(1, 2);
            end
        end
    end
end

function locationToCompare = getLocTocompare(clusterCount, typeCom, clusterNum, all_event_table, indexByCluster, activitylocation, activitySeclocation)
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
        startEventListBycluster = startEventList(indexByCluster ~= max(indexByCluster));
        endEventListBycluster = endEventList(indexByCluster ~= max(indexByCluster));
    else
        startEventListBycluster = startEventList(indexByCluster == clusterNum);
        endEventListBycluster = endEventList(indexByCluster == clusterNum);
    end
    
    locationToCompare = [];
    
    for i = 1:length(startEventListBycluster)
        locationToCompare = [locationToCompare, startEventListBycluster(i):endEventListBycluster(i)];
    end
end