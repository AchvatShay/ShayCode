outputfolder = '\\jackie-analysis\F\Layer II-III\Videos\Bas-S1-1\05.23.22-N2-Basal-All';
inputsfolders = {'\\jackie-analysis\F\Layer II-III\Videos\Bas-S1-1\05.23.22-N2-Basal-part1',...
    '\\jackie-analysis\F\Layer II-III\Videos\Bas-S1-1\05.23.22-N2-Basal-part2'};

mkdir(outputfolder);
fileNewName = 'trial%04d.csv';

fileIndex = 1;
for i = 1:length(inputsfolders)
    csvList = dir([inputsfolders{i}, '\*.csv']);
    
    for j = 1:length(csvList)
        copyfile(fullfile(csvList(j).folder, csvList(j).name), fullfile(outputfolder, sprintf(fileNewName, fileIndex)));
        fileIndex = fileIndex + 1;
    end
end