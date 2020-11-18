addpath('C:\Users\Jackie\Desktop\HadasCode\AnalysisProject\MatlabAnalysis');

globalParameters.MainFolder = 'C:\Users\Jackie\Dropbox (Technion Dropbox)\Yara\Layer 5_Analysis\';
globalParameters.AnimalName = 'SM04';
globalParameters.DateAnimal = '08_18_19_tuft_Final_Version';
globalParameters.swcFile = '08.18.19_Tuft_Final_Version_07.15.20\swcFiles_neuron2\neuron_2.swc';
globalParameters.neuronNumberName = 'N2';
globalParameters.RunnerDate = '2-11-20';
globalParameters.RunnerNumber = 'Run1';
globalParameters.behaveType = 'suc';
globalParameters.analysisType = 'Pearson2\SP';
globalParameters.treadmilFile = '';

globalParameters.hyperbolicDistMatrixLocation = "";
% globalParameters.hyperbolicDistMatrixLocation = fullfile(globalParameters.MainFolder, 'Shay', globalParameters.AnimalName,...
%     globalParameters.DateAnimal, 'Analysis', globalParameters.neuronNumberName, 'Structural_VS_Functional',...
%     globalParameters.RunnerDate, globalParameters.RunnerNumber, 'HS_create\StructureTreeHS\matlab_matrixbernoulli_100_3000.mat'); 

%     Can be Euclidean OR ShortestPath OR HyperbolicDist_L OR HyperbolicDist_P  = ( Between 2 roi according to the tree path )
globalParameters.roiTreeDistanceFunction = 'ShortestPath';

globalParameters.reRunClusterData = false;
   
globalParameters.behaveFrameRateTM = 100;

globalParameters.ImageSamplingRate = 20;
globalParameters.time_sec_of_trial = 12;
globalParameters.trialNumber = [1, 2];
globalParameters.BehavioralSamplingRate = 200;
globalParameters.behavioralDelay = 20;
globalParameters.toneTime = 4;

%     No events put non
globalParameters.runByEvent = {'success'};
globalParameters.isHandreach = true;
globalParameters.EventTiming = 'start';
globalParameters.runByNegEvent = false;
globalParameters.FirstEventAfter = {'non'};

%     FOR Hand Reach 
%     NO labels 0, 1 suc , 2 fail
globalParameters.split_trialsLabel = 1;
globalParameters.runBehaveLag = [-inf, inf];
globalParameters.do_eventsBetween = false;
globalParameters.doBehaveAlignedPlot = false;

globalParameters.excludeTrailsByEventCount.Name = 'non';
globalParameters.excludeTrailsByEventCount.countRange = [-inf, inf];

%     Can be WindowEventFULLPearson OR
%     WindoEventToPeakPearson OR PeaksPearson
%     OR WindoEventToPeakCov
globalParameters.roiActivityDistanceFunction = 'WindoEventToPeakPearson';

globalParameters.clusterCount = 4;
globalParameters.eventWin = 10;

% 0.01 
globalParameters.mean_aV = 0.01; 
globalParameters.aVForAll = 0.3;
globalParameters.aVFix.location = [];
globalParameters.aVFix.values = [];

globalParameters.excludeRoi = [];

globalParameters.apical_roi = [];

globalParameters.firstDepthCompare = 1;
globalParameters.secDepthCompare = 2;

globalParameters.outputpath = fullfile(globalParameters.MainFolder, 'Shay' , globalParameters.AnimalName, ...
    globalParameters.DateAnimal, 'Analysis', globalParameters.neuronNumberName, 'Structural_VS_Functional',...
    globalParameters.RunnerDate,globalParameters.RunnerNumber, globalParameters.behaveType, globalParameters.analysisType);

globalParameters.outputpath = char(globalParameters.outputpath);
mkdir(globalParameters.outputpath);

warning('off','all');

codePar = 'PublishPDFMainAnalysis3(globalParameters)';

publish('PublishPDFMainAnalysis3.m', 'showCode', false,...
    'format','pdf', 'catchError', false, 'outputDir', globalParameters.outputpath, 'codeToEvaluate', codePar);

% PublishPDFMainAnalysis3(globalParameters);

clear;