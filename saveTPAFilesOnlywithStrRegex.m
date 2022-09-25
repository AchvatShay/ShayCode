function saveTPAFilesOnlywithStrRegex(tpaFolder, regex, outputpath)
    TPAList = dir(strcat(tpaFolder,'\TPA*.mat'));

    fileNumRoi = length(TPAList);
   
    for trialInd = 1:fileNumRoi
        usrData                    = load(fullfile(TPAList(trialInd).folder, TPAList(trialInd).name));
        if ~isfield(usrData, 'strROI')
            error(' has no ROI');
        end
        
        index = 1;
        for m = 1:length(usrData.strROI)
            if contains(usrData.strROI{m}.Name, regex)
                strROI{index} = usrData.strROI{m};
                index = index + 1;
            end
        end
        
        strShift = usrData.strShift;
        save(fullfile(outputpath, TPAList(trialInd).name), 'strROI', 'strShift')
    end
end