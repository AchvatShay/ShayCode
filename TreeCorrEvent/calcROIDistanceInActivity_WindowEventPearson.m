function [roiActivityDistanceMatrix] = calcROIDistanceInActivity_WindowEventPearson(roiActivity, roiActivityNames, selectedROI, all_event_struct, typeCom, clusterNum)
    for index = 1:length(selectedROI)
        activitylocation = strcmpi(roiActivityNames, selectedROI{index});
                
        locationToCompare = getLocTocompare(activitylocation, typeCom, clusterNum, all_event_struct);
        currentROIActivity = roiActivity(locationToCompare, activitylocation);

        for secIndex = 1:length(selectedROI)
            activitySeclocation = strcmp(roiActivityNames, selectedROI{secIndex});
            secROIActivity = roiActivity(locationToCompare, activitySeclocation);
            
            if isempty(locationToCompare)
                roiActivityDistanceMatrix(index, secIndex) = -2;
                continue;
            end
            
            corrEventsPeaksROI = corr([currentROIActivity, secROIActivity], 'type', 'Pearson');
%             if index == secIndex
%                 roiActivityDistanceMatrix(index, secIndex) = 0;
%             else
%                 roiActivityDistanceMatrix(index, secIndex) = 1 - corrEventsPeaksROI(1, 2);
%             end

            roiActivityDistanceMatrix(index, secIndex) = corrEventsPeaksROI(1, 2);
        end
    end
    
    for j = 1:size(roiActivityDistanceMatrix, 1)
        for k = 1:size(roiActivityDistanceMatrix, 2)
            if roiActivityDistanceMatrix(j, k) == -2 && roiActivityDistanceMatrix(k, j) ~= -2 
                roiActivityDistanceMatrix(j, k) = roiActivityDistanceMatrix(k, j);
            elseif roiActivityDistanceMatrix(j, k) ~= -2 && roiActivityDistanceMatrix(k, j) == -2
                roiActivityDistanceMatrix(k, j) = roiActivityDistanceMatrix(j, k);
            elseif roiActivityDistanceMatrix(j, k) == -2 && roiActivityDistanceMatrix(k, j) == -2
                roiActivityDistanceMatrix(j, k) = 0;
                roiActivityDistanceMatrix(k, j) = 0;
            end
            
            roiActivityDistanceMatrix(j, k) = (roiActivityDistanceMatrix(j, k) + roiActivityDistanceMatrix(k, j)) ./ 2;
            roiActivityDistanceMatrix(k, j) = roiActivityDistanceMatrix(j, k) ; 
        end
    end
end

function locationToCompare = getLocTocompare(activityLoc, typeCom, clusterNum, all_event_struct)
    switch typeCom
        case 'FULL'
            startEventList = all_event_struct.start{activityLoc};            
            endEventList = all_event_struct.end{activityLoc};
        case 'ToPeak'
            startEventList = all_event_struct.start{activityLoc};            
            endEventList = all_event_struct.pks{activityLoc};
        case 'Peaks'
            startEventList = all_event_struct.pks{activityLoc};            
            endEventList = all_event_struct.pks{activityLoc};
    end
    
    indexByCluster = all_event_struct.cluster{activityLoc};
    
    if clusterNum == 0
        startEventListBycluster = startEventList;
        endEventListBycluster = endEventList;
    else
        startEventListBycluster = startEventList(indexByCluster == clusterNum);
        endEventListBycluster = endEventList(indexByCluster == clusterNum);
    end
    
    locationToCompare = [];
    
    for i = 1:length(startEventListBycluster)
        locationToCompare = [locationToCompare, startEventListBycluster(i):endEventListBycluster(i)];
    end
end