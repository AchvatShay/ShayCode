outputfolder = '\\jackie-analysis\F\Layer II-III\Analysis\Bas-M2-Sa1\08.09.22-Tuft-N1-All';
inputsfolders = {'\\jackie-analysis\F\Layer II-III\Analysis\Bas-M2-Sa1\08.09.22-Tuft-N1-1',...
    '\\jackie-analysis\F\Layer II-III\Analysis\Bas-M2-Sa1\08.09.22-Tuft-N1-2'};

mkdir(outputfolder);
fileNewName = '_TSeries_08092022_0853_%03d_Cycle00001_Ch1_000001_ome.mat';

fileIndex = 1;
for i = 1:length(inputsfolders)
    bdaList = dir([inputsfolders{i}, '\BDA*.mat']);
    tpaList = dir([inputsfolders{i}, '\TPA*.mat']);
    
    for j = 1:length(bdaList)
        copyfile(fullfile(bdaList(j).folder, bdaList(j).name), fullfile(outputfolder, ['BDA', sprintf(fileNewName, fileIndex)]));
        copyfile(fullfile(tpaList(j).folder, tpaList(j).name), fullfile(outputfolder, ['TPA', sprintf(fileNewName, fileIndex)]));
        fileIndex = fileIndex + 1;
    end
end