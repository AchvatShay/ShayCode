function [roiActivity, roiActivityNames] = loadActivityFileFromTPA(activityfileTPAFolder, selectedROI, outputpath)
    TPAList = dir(strcat(activityfileTPAFolder,'\TPA*'));

    fileNumRoi = length(TPAList);
     
    dataSize = 0;
    activity = table;
    for trialInd = 1:fileNumRoi
        usrData                    = load(fullfile(TPAList(trialInd).folder, TPAList(trialInd).name));
        if ~isfield(usrData, 'strROI')
            error(' has no ROI');
        end
        for m = 1:length(usrData.strROI)
            currentData = [];
            currentROIName = sprintf('roi%05d', extractROIstr(usrData.strROI{m}.Name));
            
            indexROI = find(strcmp(activity.Properties.VariableNames, currentROIName), 1);
            if isempty(indexROI)&& trialInd ~= 1
                    error('ROI Not exists in all trials');
            end
            
            % match new format to old format, the deltaF over F is saved in Data(:,2)
            % instead of procROI
            if ~isfield(usrData.strROI{m}, 'Data') && ~isprop(usrData.strROI{m}, 'Data')
                if ~isfield(usrData.strROI{m}, 'procROI')
                    error(' unfamiliar TPA file, cannot extract data');
                else
                    currentData = usrData.strROI{m}.procROI;
                end
            else
                currentData = usrData.strROI{m}.Data(:,2);
            end
            
            if dataSize == 0
                dataSize = length(currentData);
            elseif dataSize ~= size(currentData, 1)
                warning('ROI not the same data size');
                break;
            end
            
            activity.(currentROIName)(((trialInd - 1) * (length(currentData)) + 1):((trialInd) * (length(currentData)))) = currentData;        
        end
    end

    roinames = activity.Properties.VariableNames;
    roi_index = 1;
    for index = 1:length(roinames)
        if isempty(selectedROI) || ~isempty(find(strcmpi(selectedROI, roinames{index}), 1))
           currentROIActivity = activity.(roinames{index});
           
           roiActivity(:, roi_index) = currentROIActivity;
           roiActivityNames{roi_index} = roinames{index};
           roi_index = roi_index + 1;
        end
    end
    
    writetable(activity,fullfile(outputpath, 'activityFileAsTable.csv'))
end