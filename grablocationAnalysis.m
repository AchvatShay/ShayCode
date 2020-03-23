function grablocationAnalysis(output, grabsFile, trajInput_folder, trail_files_name, is_norm, bySF)

% load xlxs data 
[num,txt,raw] = xlsread(grabsFile);

[rowIndex, colIndex] = find(strcmp(raw, 'Experiment'));
experimentName = raw{rowIndex,colIndex + 1};


[trailsNumberRow, trailsNumberCol] = find(strcmp(raw, 'Trial #'));
data(:, 1) = raw((trailsNumberRow + 1):end, trailsNumberCol);

[statusNumberRow, statusNumberCol] = find(strcmp(raw, 'Success/failure/0'));
data(:, 2) = raw((statusNumberRow + 1):end, statusNumberCol);

[FirstGrabNumberRow, FirstGrabNumberCol] = find(strcmp(raw, 'Frame # first grab'));
data(:, 3) = raw((FirstGrabNumberRow + 1):end, FirstGrabNumberCol);

[secondGrabNumberRow, secondGrabNumberCol] = find(strcmp(raw, 'Frame # second grab'));
data(:, 4) = raw((secondGrabNumberRow + 1):end, secondGrabNumberCol);


[thirdGrabNumberRow, thirdGrabNumberCol] = find(strcmp(raw, 'Frame # third grab'));
data(:, 5) = raw((thirdGrabNumberRow + 1):end, thirdGrabNumberCol);

[pR, pC] = find(strcmp(raw, 'pelletPlot'));
data(:, 10) = raw((pR + 1):end, pC);

[meanIncludeR, meanIncludeC] = find(strcmp(raw, 'meanInclude'));
data(:, 11) = raw((meanIncludeR + 1):end, meanIncludeC);

% [normalizedRow, normalizedCol] = find(strcmp(raw, 'Head -post bar location'));
% normalizedVal = raw{normalizedRow, normalizedCol + 1};
normalizedVal = 0;

[pelletrow, pelletCol] = find(strcmp(raw, 'Pellet position X'));
data(:, 12) = raw((pelletrow + 1):end, pelletCol);


% remove nan values in trails
indexNanTrails=cellfun(@isnan,data(:,1),'uni',false);
indexNanTrails=cellfun(@any,indexNanTrails);
data(indexNanTrails, :) = [];

% load trk files for all trails
listFoldersTrails = dir(strcat(trajInput_folder,'\*\*.csv'));

% listFoldersTrails = dir(strcat(trajInput_folder,'\*.csv'));

for i = 1: size(data, 1)

    if data{i,1} < 10
        trail_name = strcat(trail_files_name, '_00', num2str(data{i,1}));
    elseif data{i,1} < 100
        trail_name = strcat(trail_files_name, '_0', num2str(data{i,1}));
    else
        trail_name = strcat(trail_files_name, '_', num2str(data{i,1}));
    end
    
    %     getTrailTrak
    trkFile = find(contains({listFoldersTrails.folder}, trail_name)==1);

%     trkFile = find(contains({listFoldersTrails.name}, trail_name)==1);

    traj = createTrajFromCSV(strcat(listFoldersTrails(trkFile).folder, '\', listFoldersTrails(trkFile).name));
    
%     firstGrab for trail
    data(i, 6) = getPosForGrabAndFrame(data{i, 3}, is_norm, traj, normalizedVal);
    
%     secondGrab for trail
    data(i, 7) = getPosForGrabAndFrame(data{i, 4}, is_norm, traj, normalizedVal);
    
%     thirdGrab for trail
    data(i, 8) = getPosForGrabAndFrame(data{i, 5}, is_norm, traj, normalizedVal);
    
% %     pellet location
%     frontPelletM = traj.pTrk(3, 1, :);
%     frontPelletMResults = mean(frontPelletM);
    if is_norm
%         sidePelletM = traj.pTrk(4, :, 1);

%         Only for now because i dont have H and W in pellet
        sidePelletM = [329.327, 270.2873];

        vectorPellet = [frontPelletMResults- normalizedVal, sidePelletM(1), sidePelletM(2)];
        data(i, 9) = {norm(vectorPellet)};
    else
        data(i, 9) = {data{i, 12} - normalizedVal};
    end
end

mkdir(output);

plotGrabAndSave(output, experimentName, '1', data(:, [1,2,6,9,10,11]), is_norm, bySF);
plotGrabAndSave(output, experimentName, '2', data(:, [1,2,7,9,10,11]), is_norm, bySF);
plotGrabAndSave(output, experimentName, '3', data(:, [1,2,8,9,10,11]), is_norm, bySF);

plotAllGrabsAndSave(output, experimentName, data, is_norm, 1, bySF);
plotAllGrabsAndSave(output, experimentName, data, is_norm, 0, bySF);

end

function [value] = getPosForGrabAndFrame(frame, is_norm, traj, normalizedVal)
    if ~isnan(frame)
        frontM = traj.X(frame);
        
        if is_norm
            sideM = traj.pTrk(2, :, frame);
            vectorPos = [frontM(1)- normalizedVal, sideM(1), sideM(2)];
            value = {norm(vectorPos)};
        else
            value = {frontM(1) - normalizedVal};
        end
    else
        value = {NaN};
    end
end