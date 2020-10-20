function mainRunnerNeuronTreeAndActivityAnalysis_HS
    fileToRun = {'all', 'c0', 'c1', 'c2', 'c3', 'c4'};
    
    %     Can be Euclidean OR ShortestPath OR HyperbolicDist_L OR HyperbolicDist_P  = ( Between 2 roi according to the tree path )
    roiTreeDistanceFunction = {'HyperbolicDist_P' , 'ShortestPath'};
    structureType = {'HS', 'SP'};
    
    for k = 1:length(structureType)
        for i = 1:length(fileToRun)
            HS_RunnerForCluster(fileToRun{i}, structureType{k}, roiTreeDistanceFunction{k});
        end
    end
end

function HS_RunnerForCluster(clusterName, structureType, roiTreeDistanceFunction)
    neuronTreePathSWC = "C:\Users\Jackie\Dropbox (Technion Dropbox)\Yara\Layer 5_Analysis\Shay\SM01\10.22.19_Tuft\10.22.19_Tuft_swcFiles\neuron_3.swc";
    
    neuronActivityMatrix = ['C:\Users\Jackie\Dropbox (Technion Dropbox)\Yara\Layer 5_Analysis\Shay\SM01\10.22.19_Tuft\Analysis\N2\Structural_VS_Functional\14-10-20\Run1\HS_create\fail\ActivityHS_' clusterName '\matlab_matrix_0_normal_500_100000.mat'];
    
    hyperbolicDistMatrixLocation = "C:\Users\Jackie\Dropbox (Technion Dropbox)\Yara\Layer 5_Analysis\Shay\SM01\10.22.19_Tuft\Analysis\N2\Structural_VS_Functional\14-10-20\Run1\HS_create\StructuralTreeHyperbolic\matlab_matrixbernoulli_100_3000.mat"; 
    
    behaveFileTreadMillPath = '';
    behaveFrameRate = 100;
    
    outputpath = ['C:\Users\Jackie\Dropbox (Technion Dropbox)\Yara\Layer 5_Analysis\Shay\SM01\10.22.19_Tuft\Analysis\N2\Structural_VS_Functional\14-10-20\Run1\HSActivity\fail\' structureType '\' clusterName '\'];
    outputpath = char(outputpath);
    mkdir(outputpath);     
    
    excludeRoi = [];
    apical_roi = [];
    
    doComboForCloseRoi = false;
    
    firstDepthCompare = 1;
    secDepthCompare = 2;
    
%     load Tree Data
    [gRoi, ~, selectedROITable] = loadSwcFile(neuronTreePathSWC, outputpath, doComboForCloseRoi);
    
    for i = 1:length(excludeRoi)
        ex_results = contains(selectedROITable.Name, sprintf('roi%05d', excludeRoi(i)));
        
        if sum(ex_results) == 1
            selectedROITable(ex_results, :) = [];
        end
    end
    
    selectedROI = selectedROITable.Name;
    
    index_apical = zeros(1, length(apical_roi));   
    for i = 1:length(apical_roi)
        ex_results = find(contains(selectedROITable.Name, sprintf('roi%05d', apical_roi(i))));
        
        if ~isempty(ex_results)
            index_apical(i) = ex_results;
        end
    end
 
    
%     Behave TreadMillData
    if ~isempty(behaveFileTreadMillPath)
        [speedBehave, accelBehave, speedActivity, accelActivity] = treadmilBehave(behaveFileTreadMillPath, behaveFrameRate);
        plotBaseTreadMillActivity(speedBehave, accelBehave, roiActivity, outputpath);
    end
      
   if ~strcmp(hyperbolicDistMatrixLocation, "") 
        load(hyperbolicDistMatrixLocation);
   end
    
%     Calc Distance Matrix for ROI in Tree
    switch(roiTreeDistanceFunction)
        case 'Euclidean'
           [roiTreeDistanceMatrix, roiSortedByCluster, roiLinkage] = calcROIDistanceInTree_Euclidean(gRoi, selectedROI, outputpath); 
        case 'ShortestPath'
           [roiTreeDistanceMatrix, roiSortedByCluster, roiLinkage] = calcROIDistanceInTree_ShortestPath(gRoi, selectedROITable, outputpath);
        case 'HyperbolicDist_L'
           [roiTreeDistanceMatrix, roiSortedByCluster, roiLinkage] = calcROIDistanceInTree_Hyperbolic(gRoi, selectedROITable, outputpath, loranzDistMat);
        case 'HyperbolicDist_P'
           [roiTreeDistanceMatrix, roiSortedByCluster, roiLinkage] = calcROIDistanceInTree_Hyperbolic(gRoi, selectedROITable, outputpath, poincareDistMat);
    end
    
%     Calc branching
    selectedROISplitDepth1 = ones(length(selectedROI), 1) * -1;
    selectedROISplitDepth1 = getSelectedROISplitBranchID(gRoi, firstDepthCompare, selectedROISplitDepth1, selectedROI);   
  
    selectedROISplitDepth3 = ones(length(selectedROI), 1) * -1;
    selectedROISplitDepth3 = getSelectedROISplitBranchID(gRoi, secDepthCompare, selectedROISplitDepth3, selectedROI);   
        
    
%     Calc Activity Events Window

    close all;
    
%     Plot Tree And Trial Activity in the ROI    
%     totalTrialTime = samplingRate * time_sec_of_trial;
%     plotTreeAndActivityForTrial(trialNumber, totalTrialTime, roiSortedByCluster, roiActivity, roiActivityNames, selectedROI, outputpath, locationPeaks, windowFULL, roiLinkage);
%     
    
    close all;

   load(neuronActivityMatrix);
   
   plotTreeAndActivityDendogram(outputpath, 'HS', roiActivityDistanceMatrix, selectedROI, roiLinkage,  roiSortedByCluster, true);
   
%    diffMAp = calcActivityMapAndStructureMapDiff(roiActivityDistanceMatrix, roiTreeDistanceMatrix, false);
% 
%    plotResultesByClusterType(diffMAp, selectedROI, roiSortedByCluster, [outputpath, '\DiffMatrix\'],...
%        gRoi, roiTreeDistanceMatrix, selectedROISplitDepth3, selectedROISplitDepth1, selectedROITable, index_apical);
%       
   
   plotResultesByClusterType(roiActivityDistanceMatrix, selectedROI, roiSortedByCluster, outputpath,...
       gRoi, roiTreeDistanceMatrix, selectedROISplitDepth3, selectedROISplitDepth1, selectedROITable, index_apical);

   
   fclose('all');
   close all;


end
 
function index_presentaion = plotResultesByClusterType(roiActivityDistanceMatrix, selectedROI, roiSortedByCluster, outputpathCurr, ...
    gRoi, roiTreeDistanceMatrix, selectedROISplitDepth3, selectedROISplitDepth1, selectedROITable, index_apical)
       
        figDist = figure;
        hold on;
        title({'ROI Activity Distance'});
        xticks(1:length(selectedROI));
        yticks(1:length(selectedROI));
        imagesc(roiActivityDistanceMatrix(roiSortedByCluster, roiSortedByCluster));
        colorbar
        cmap = jet();
        
        cmap = flipud(cmap);
        colormap(cmap);
        
        xticklabels(selectedROI(roiSortedByCluster));
        xtickangle(90);
        yticklabels(selectedROI(roiSortedByCluster));
        picNameFile = [outputpathCurr, '\DistMatrixActivity_HS'];
        mysave(figDist, picNameFile);  
        
        y = squareform(roiActivityDistanceMatrix);
        l = linkage(y, 'single');

        figDendrogram = figure;
        leafOrder = optimalleaforder(l,y);
        dendrogram(l, 'Labels', selectedROI, 'Reorder', leafOrder);
        xtickangle(90);
        
        mysave(figDendrogram, [outputpathCurr, '\DendrogramROIActivity']);
    
        plotROIDistMatrixTreeVSActivity([],gRoi, [outputpathCurr],selectedROISplitDepth1, selectedROISplitDepth1, roiTreeDistanceMatrix, roiActivityDistanceMatrix, true, 'HS', 'HS', selectedROI,index_apical,  'Distance');

        plotROIDistMatrixTreeVSActivity([],gRoi, [outputpathCurr],selectedROISplitDepth1, selectedROISplitDepth3, roiTreeDistanceMatrix, roiActivityDistanceMatrix, false, 'HS', 'HS', selectedROI, index_apical, 'Distance');
        
        plotRoiDistMatrixTreeVsActivityForDepthCompare(gRoi, [outputpathCurr],  selectedROITable, roiTreeDistanceMatrix, roiActivityDistanceMatrix, 'HS', 'HS' );
      
end