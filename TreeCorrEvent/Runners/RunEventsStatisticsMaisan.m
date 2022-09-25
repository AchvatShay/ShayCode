addpath('\\jackie-analysis10\users\Jackie\Desktop\Hadas\AnalysisProject\MatlabAnalysis');

globalParameters.TPAFolder = '\\192.114.20.109\e\Maisan\2ph experiments\Analysis';
globalParameters.MainFolder = '\\192.114.20.109\e\Maisan\2ph experiments\Analysis';
globalParameters.AnimalName = 'CT54';
globalParameters.DateAnimal = '22_05_21 baseline table';
globalParameters.swcFile = '\swcFiles\neuron_1.swc';
globalParameters.neuronNumberName = 'N1';
globalParameters.RunnerDate = '31.3.22';
globalParameters.RunnerNumber = 'Run2';

globalParameters.swcLocationWithInOutputFolder = false;

globalParameters.neuronActivityPathTPA = fullfile(globalParameters.TPAFolder, globalParameters.AnimalName, globalParameters.DateAnimal);

globalParameters.neuronTreePathSWC = fullfile(globalParameters.neuronActivityPathTPA, 'Tree', globalParameters.swcFile);

globalParameters.eventsDetectionFolder = fullfile(globalParameters.MainFolder, globalParameters.AnimalName, ...
    globalParameters.DateAnimal, 'Analysis', globalParameters.neuronNumberName, 'Structural_VS_Functional',...
    globalParameters.RunnerDate,globalParameters.RunnerNumber, 'EventsDetection');
mkdir(globalParameters.eventsDetectionFolder);
  
%     Can be Euclidean OR ShortestPath OR ShortestPathCost OR Branch OR HyperbolicDist_L OR HyperbolicDist_P  = ( Between 2 roi according to the tree path )
globalParameters.roiTreeDistanceFunction = 'ShortestPath';
globalParameters.costSP = 0;

globalParameters.DistType = 'Pearson';

globalParameters.costCluster = -1;

globalParameters.ImageSamplingRate = 30;
globalParameters.time_sec_of_trial = 12;
globalParameters.toneTime = 4;

%     Can be WindowEventFULLPearson OR
%     WindoEventToPeakPearson OR PeaksPearson OR glm
%     OR WindoEventToPeakCov OR WindoEventPearsonPerEvent OR HS_Activity
globalParameters.roiActivityDistanceFunction = 'WindoEventToPeakPearson';

% 0.01 
globalParameters.mean_aV = 0.01; 
globalParameters.aVForAll = 0.1;
globalParameters.aVFix.location = [];
globalParameters.aVFix.values = [];

globalParameters.sigmaChangeValue = 0;
    
globalParameters.sigmaFix.location = [];
globalParameters.sigmaFix.values = [];

% most of the time 1.5 is good
globalParameters.thresholdGnValue = 1.5;
globalParameters.thresholdGnFix.location = [];
globalParameters.thresholdGnFix.values = [];

globalParameters.runMLS = true;

globalParameters.excludeRoi = [14, 18, 22, 23, 24, 54];
globalParameters.firstDepthCompare = 1;
globalParameters.secDepthCompare = -1;

globalParameters.outputpath = fullfile(globalParameters.MainFolder, globalParameters.AnimalName, ...
    globalParameters.DateAnimal, 'Analysis', globalParameters.neuronNumberName, 'Structural_VS_Functional',...
    globalParameters.RunnerDate,globalParameters.RunnerNumber);

globalParameters.outputpath = char(globalParameters.outputpath);
mkdir(globalParameters.outputpath);

warning('off','all');
RunningEventDetectionAndEventsStatistic(globalParameters);

clear;