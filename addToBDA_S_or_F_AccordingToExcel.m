% load xlxs data 
[num,txt,raw] = xlsread('SM04_8_18_19.xlsx');

[rowIndex, colIndex] = find(strcmp(raw, 'Experiment'));
experimentName = raw{rowIndex,colIndex + 1};


[trailsNumberRow, trailsNumberCol] = find(strcmp(raw, 'Trial #'));
data(:, 1) = raw((trailsNumberRow + 1):end, trailsNumberCol);

[statusNumberRow, statusNumberCol] = find(strcmp(raw, 'success/ failure/ 0'));
data(:, 2) = raw((statusNumberRow + 1):end, statusNumberCol);

bdaFolder = 'C:\Users\Jackie\Dropbox (Technion Dropbox)\Yara\Layer 5\SM04\08_18_19_tuft_Final_Version\';
trail_files_name = 'BDA_TSeries_08182019_1104';

nanIndexCheck = cellfun(@isnan,data(:,1),'uni',false);
nanIndexCheck=cellfun(@any,nanIndexCheck);
data(nanIndexCheck, :) = [];

for i = 1: size(data,1)
    if data{i,1} < 10
        trail_name = strcat(trail_files_name, '_00', num2str(data{i,1}), '_Cycle00001_Ch1_000001_ome');
    elseif data{i,1} < 100
        trail_name = strcat(trail_files_name, '_0', num2str(data{i,1}), '_Cycle00001_Ch1_000001_ome');
    else
        trail_name = strcat(trail_files_name, '_', num2str(data{i,1}), '_Cycle00001_Ch1_000001_ome');
    end
    
    nameForFile = strcat(bdaFolder, '\', trail_name, '.mat');
    bda_events = load(nameForFile);
    strEvent = bda_events.strEvent;
    
    event = TPA_EventManager();
    event.tInd = [1,1];
    
    if (strcmp(data{i, 2}, 'S'))
        event.Name = 'success';
        strEvent{end + 1} = event;
    elseif (strcmp(data{i, 2}, 'F'))
        event.Name = 'failure';
        strEvent{end + 1} = event;
    else
    end
    
    save(fullfile(bdaFolder, [trail_name '.mat']), 'strEvent');
    
end

clear;