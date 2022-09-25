addpath('\\jackie-analysis10\users\Jackie\Desktop\Hadas\AnalysisProject\MatlabAnalysis');

globalParameters.TPAFolder = '\\192.114.20.109\e\Maisan\2ph experiments\Analysis\';
globalParameters.MainFolder = '\\192.114.20.109\e\Maisan\2ph experiments\Analysis\';
globalParameters.AnimalName = 'CT54';
globalParameters.DateAnimal = '22_06_21 HR tuft control';
globalParameters.swcFile = 'swcFiles\neuron_3.swc';
globalParameters.neuronNumberName = 'N3';
globalParameters.RunnerDate = '22.9.22';
globalParameters.RunnerNumber = 'Run1';

globalParameters.treadmilFile = '';
globalParameters.trajFolderName = '';
globalParameters.videoPath = '';

globalParameters.doBehave = false;
globalParameters.doZscoreAll = false;

globalParameters.swcLocationWithInOutputFolder = false;

globalParameters.neuronActivityPathTPA = fullfile(globalParameters.TPAFolder, globalParameters.AnimalName, globalParameters.DateAnimal);

globalParameters.neuronTreePathSWC = fullfile(globalParameters.neuronActivityPathTPA, 'Tree', globalParameters.swcFile);

globalParameters.eventsDetectionFolder = fullfile(globalParameters.MainFolder, globalParameters.AnimalName, ...
    globalParameters.DateAnimal, 'Analysis', globalParameters.neuronNumberName, 'Structural_VS_Functional',...
    globalParameters.RunnerDate,globalParameters.RunnerNumber, 'EventsDetection');
mkdir(globalParameters.eventsDetectionFolder);

globalParameters.behaveFileTreadMillPath = fullfile(globalParameters.MainFolder, globalParameters.AnimalName, globalParameters.DateAnimal, globalParameters.treadmilFile);

globalParameters.behaveTreadMilOutputFolder = fullfile(globalParameters.MainFolder, globalParameters.AnimalName, ...
    globalParameters.DateAnimal, 'Analysis', 'BehaveTreadMilOutput');
    
globalParameters.isSimData = false;
globalParameters.reverseHeatMap = false;
globalParameters.hyperbolicDistMatrixLocation = "";
% globalParameters.hyperbolicDistMatrixLocation = fullfile(globalParameters.MainFolder, 'Shay', globalParameters.AnimalName,...
%     globalParameters.DateAnimal, 'Analysis', globalParameters.neuronNumberName, 'Structural_VS_Functional',...
%     globalParameters.RunnerDate, globalParameters.RunnerNumber, 'HS_create\StructureTreeHS\matlab_matrixbernoulli_100_3000.mat'); 

globalParameters.glmResults = fullfile(globalParameters.MainFolder, globalParameters.AnimalName,...
    globalParameters.DateAnimal, 'Analysis', globalParameters.neuronNumberName, 'glmAnalysis_Running', 'glmResultsSummary.mat');

% -------------------------------------------------
globalParameters.runMantelTestPerDistanceThreshold = true;
globalParameters.runMantelTestPerDistanceThreshold_only = false;
globalParameters.MantelTJump = 50;
globalParameters.MantelTJumpFolder = fullfile(globalParameters.MainFolder,...
    'MantelThresholdTestSummary', globalParameters.AnimalName, globalParameters.DateAnimal,...
    globalParameters.neuronNumberName, globalParameters.RunnerDate,globalParameters.RunnerNumber);

% ----------------------------------------------------

%     Can be Euclidean OR ShortestPath OR ShortestPathType2 OR ShortestPathCost OR Branch OR HyperbolicDist_L OR HyperbolicDist_P  = ( Between 2 roi according to the tree path )
globalParameters.roiTreeDistanceFunction = 'ShortestPath';
globalParameters.costSP = 0;

globalParameters.DistType = 'Pearson';

globalParameters.costCluster = -1;

globalParameters.std_treadMilThreshold = 0.0001;
globalParameters.aftertonetime = 26;

globalParameters.winLength = 2; % defaulte is 4;

globalParameters.splinesL = '\\jackie-analysis10\users\Jackie\Desktop\Hadas\AnalysisProject\MatlabAnalysis';

globalParameters.doExtraAnalysis = false;
globalParameters.doPCA = true;

globalParameters.PrecentageThresholdType = 1; % 0 == All tree, 1== hemitree

% for Type == 1, max values to splite 3 ||| recommended  [35,75,100]
globalParameters.ClustersByPrecentageThreshold = ...
    [35,75,100];

% for Type == 0 , max values to split 6 ||| recomended [0,20;20,40;40,60;60,80;80,100]
% globalParameters.ClustersByPrecentageThreshold = ...
%     [0,20;...
%     20,40;...
%     40,60;...
%     60,80;...
%     80,100];

globalParameters.treadMilExtraPlot = true;

globalParameters.reRunClusterData = false;
   
globalParameters.behaveFrameRateTM = 100;

globalParameters.ImageSamplingRate = 30;
globalParameters.time_sec_of_trial = 12;
globalParameters.trialNumber = [1, 2];
globalParameters.BehavioralSamplingRate = 200;
globalParameters.behavioralDelay = 0;
globalParameters.toneTime = 4;

%     No events put non
globalParameters.runByEvent = {'non'};
globalParameters.isHandreach = true;
globalParameters.EventTiming = 'start';
globalParameters.runByNegEvent = false;
globalParameters.FirstEventAfter = {'non'};

%     FOR Hand Reach 
%     NO labels 0, 1 suc , 2 fail
globalParameters.split_trialsLabel = 0;
globalParameters.runBehaveLag = [-inf, inf];
globalParameters.do_eventsBetween = false;
globalParameters.doBehaveAlignedPlot = false;

globalParameters.excludeTrailsByEventCount.Name = 'non';
globalParameters.excludeTrailsByEventCount.countRange = [-inf, inf];

%     Can be WindowEventFULLPearson OR
%     WindoEventToPeakPearson OR PeaksPearson OR glm
%     OR WindoEventToPeakCov OR WindoEventPearsonPerEvent OR HS_Activity
globalParameters.roiActivityDistanceFunction = 'WindoEventToPeakPearson';

globalParameters.clusterCount = 4;
globalParameters.eventWin = 10;

% 0.01 
globalParameters.mean_aV = 0.01; % 0.01 for the original MLSP 0.04 for fast
globalParameters.aVForAll = 0.3; % 0.3 or 0.1 for the original MLS, but also missing maybe important events, 0.06 - 0.03 for fast,most of the time 0.04
globalParameters.aVFix.location = [];
globalParameters.aVFix.values = [];

globalParameters.sigmaChangeValue = 0;
    
globalParameters.sigmaFix.location = [];
globalParameters.sigmaFix.values = [];

% most of the time 1.5 is good
globalParameters.thresholdGnValue = 1.5;
globalParameters.thresholdGnFix.location = [];
globalParameters.thresholdGnFix.values = [];

globalParameters.runEventDetectionWithSmoothing = false;
globalParameters.EventsDetectionSpikeRate = nan; % default 0.1

globalParameters.runMLS = true;
globalParameters.runMLSpikeV5 = false;

globalParameters.doAutoExcludeROIs = true;
% if excludeBy == 1 do by raw data trace 
% if excludeBy == 2 do by post event detection trace
% if excludeBy == 3 do by post event detection only events compare 
globalParameters.excludeBy = 3;

globalParameters.excludeRoi = [];

globalParameters.apical_roi = [];

globalParameters.firstDepthCompare = 1;
globalParameters.secDepthCompare = -1;

globalParameters.outputpath = fullfile(globalParameters.MainFolder, globalParameters.AnimalName, ...
    globalParameters.DateAnimal, 'Analysis', globalParameters.neuronNumberName, 'Structural_VS_Functional',...
    globalParameters.RunnerDate,globalParameters.RunnerNumber);

globalParameters.outputpath = char(globalParameters.outputpath);
mkdir(globalParameters.outputpath);

globalParameters.mantelRF = fullfile(globalParameters.MainFolder, 'MantelSummary', globalParameters.AnimalName, globalParameters.DateAnimal,...
        globalParameters.neuronNumberName, globalParameters.RunnerDate, globalParameters.RunnerNumber);
mkdir(globalParameters.mantelRF);
    

warning('off','all');

codePar = 'PublishPDFMainAnalysis2(globalParameters)';

% publish('PublishPDFMainAnalysis2.m', 'showCode', false,...
%     'format','pdf', 'catchError', false, 'outputDir', globalParameters.outputpath, 'codeToEvaluate', codePar);

% PublishPDFMainAnalysis2(globalParameters);

% RunnerHadasCode(globalParameters);


addpath('\..\brike');
addpath('\..\MLspike');
addpath('\..\wanova');

addpath(genpath('\..\OASIS_matlab-master'));

mainRunnerNeuronTreeAndActivityAnalysis_V3(globalParameters);
    
clear;