outputfolder = '\\jackie-analysis\F\Layer II-III\Videos\Bas-S1-1\05.23.22-N2-Basal-All';
inputsfolders = {'\\jackie-analysis\F\Layer II-III\Videos\Bas-S1-1\05.23.22-N2-Basal-part1',...
    '\\jackie-analysis\F\Layer II-III\Videos\Bas-S1-1\05.23.22-N2-Basal-part2'};

mkdir(outputfolder);
fileNewName = 'trial%04d.mp4';

fileIndex = 1;
for i = 1:length(inputsfolders)
    mpList = dir([inputsfolders{i}, '\trial*.mp4']);
    
    for j = 1:length(mpList)       
        if ~isempty(regexp( mpList(j).name,'trial[0-9][0-9][0-9][0-9].mp4', 'once'))
            copyfile(fullfile(mpList(j).folder, mpList(j).name), fullfile(outputfolder, sprintf(fileNewName, fileIndex)));
            fileIndex = fileIndex + 1;
        end
    end
end