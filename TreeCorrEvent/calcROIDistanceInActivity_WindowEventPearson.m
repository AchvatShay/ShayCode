function [roiActivityDistanceMatrix] = calcROIDistanceInActivity_WindowEventPearson(roiActivity, roiActivityNames, selectedROI, windowList)
    locationToCompare = [];
    for index = 1:length(windowList)
        locationToCompare = [locationToCompare,...
            windowList(index, 1) : windowList(index, 2)]; 
    end

    for index = 1:length(selectedROI)
        activitylocation = strcmpi(roiActivityNames, selectedROI{index});
        currentROIActivity = roiActivity(locationToCompare, activitylocation);

        for secIndex = 1:length(selectedROI)
            activitySeclocation = strcmp(roiActivityNames, selectedROI{secIndex});
            secROIActivity = roiActivity(locationToCompare, activitySeclocation);
            
            corrEventsPeaksROI = corr([currentROIActivity, secROIActivity], 'type', 'Pearson');
            if index == secIndex
                roiActivityDistanceMatrix(index, secIndex) = 0;
            else
                roiActivityDistanceMatrix(index, secIndex) = 1 - corrEventsPeaksROI(1, 2);
            end
        end
    end  
end