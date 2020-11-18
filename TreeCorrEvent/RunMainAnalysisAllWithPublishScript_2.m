addpath('C:\Users\Jackie\Desktop\HadasCode\AnalysisProject\MatlabAnalysis');

globalParameters.MainFolder = 'C:\Users\Jackie\Dropbox (Technion Dropbox)\Yara\Layer 5_Analysis\';
globalParameters.AnimalName = 'SM04';
globalParameters.DateAnimal = '10.20.19_Tuft';
globalParameters.swcFile = 'swcFilesFix\neuron_2.swc';
globalParameters.neuronNumberName = 'N2';
globalParameters.RunnerDate = '2-11-20';
globalParameters.RunnerNumber = 'Run2';
globalParameters.behaveType = 'sup_FTF';
globalParameters.analysisType = 'Pearson\SP';
globalParameters.treadmilFile = '';

globalParameters.hyperbolicDistMatrixLocation = "";
% globalParameters.hyperbolicDistMatrixLocation = fullfile(globalParameters.MainFolder, 'Shay', globalParameters.AnimalName,...
%     globalParameters.DateAnimal, 'Analysis', globalParameters.neuronNumberName, 'Structural_VS_Functional',...
%     globalParameters.RunnerDate, globalParameters.RunnerNumber, 'HS_create\StructureTreeHS\matlab_matrixbernoulli_100_3000.mat'); 

%     Can be Euclidean OR ShortestPath OR HyperbolicDist_L OR HyperbolicDist_P  = ( Between 2 roi according to the tree path )
globalParameters.roiTreeDistanceFunction = 'ShortestPath';

globalParameters.reRunClusterData = false;
   
globalParameters.behaveFrameRateTM = 100;

globalParameters.ImageSamplingRate = 30;
globalParameters.time_sec_of_trial = 12;
globalParameters.trialNumber = [1, 2] ;
globalParameters.BehavioralSamplingRate = 200;
globalParameters.behavioralDelay = 20;
globalParameters.toneTime = 4;

%     No events put non
globalParameters.runByEvent = {'firstTonesupination'};
globalParameters.EventTiming = 'start';
globalParameters.runByNegEvent = false;
globalParameters.FirstEventAfter = {'non'};
globalParameters.isHandreach = true;

%     FOR Hand Reach 
%     NO labels 0, 1 suc , 2 fail
globalParameters.split_trialsLabel = 2;
globalParameters.runBehaveLag = [-3, 3];
globalParameters.do_eventsBetween = false;
globalParameters.doBehaveAlignedPlot = true;

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
globalParameters.aVForAll = 0.15;
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
mkdir([globalParameters.outputpath, '\EventsPlots']);

warning('off','all');

codePar = 'PublishPDFMainAnalysis2(globalParameters)';

publish('PublishPDFMainAnalysis2.m', 'showCode', false,...
    'format','pdf', 'catchError', false, 'outputDir', globalParameters.outputpath, 'codeToEvaluate', codePar);

% PublishPDFMainAnalysis2(globalParameters);

clear;