function AddEventsToBDAAccording()
    folderBDA = '\\192.114.21.76\DataJ\AmirM-HIPPOCAMPUS\KAINATE\Analysis\GP57_copy';
    xlTableLocation = '\\192.114.21.76\DataJ\AmirM-HIPPOCAMPUS\KAINATE\Excel_HADAS\GP57\New Microsoft Excel Worksheet.xlsx'; 
    totalFrames = 1802;
    
    listTPA = dir(fullfile(folderBDA, '\TPA*.mat'));
   
    defaultTime = [100,120];
    
    xlTable = readtable(xlTableLocation);
    
    for i = 1:size(listTPA)
         
         strEvent = {};
         
         trialXlsIndex = find(xlTable.trial == i);
         
         for j = 1:length(trialXlsIndex)
            event = TPA_EventManager();
            event.Name = xlTable.TYPE_Control_Seizure_NoSeizure_IIS_{trialXlsIndex(j)};
            
            if isnan(xlTable.beginning_frame_(trialXlsIndex(j)))
                event.tInd = defaultTime;
                event.Data = [];
            else
                event.tInd = [xlTable.beginning_frame_(trialXlsIndex(j)),xlTable.end_frame_(trialXlsIndex(j))];
                event.Data = zeros(1, totalFrames);
                event.Data(event.tInd(1):event.tInd(2)) = 1;
            end
            
            strEvent{end+1} = event;
         end
         
         newNameF = replace(listTPA(i).name, 'TPA', 'BDA');
         
         if contains(newNameF, 'TPA')
            error('TPA not replaced');
         end
         
         save(fullfile(listTPA(i).folder, newNameF), 'strEvent');
    end
end