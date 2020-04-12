function mainRunnerNeuronTreeAndActivityAnalysis
    neuronTreePathSWC = "E:\Dropbox (Technion Dropbox)\Analysis (1)\Yara's Data For Shay\SM00\06.26.19_FreeRun\SM00_06.26.19_FreeRun_swcFiles\neuron_1.swc";
    
    activityByCSV = false;
    neuronActiityPathCSV = 'D:\Shay\work\N\SMO1_ 15_8_19\15_08_19_aligned_Ch1_dffByRoi.csv';
    neuronActivityPathTPA = 'E:\Dropbox (Technion Dropbox)\Analysis (1)\SM00\06.26.19_FreeRun\';
    
    outputpath = 'E:\Dropbox (Technion Dropbox)\Test\';
    
    
%     Can be Euclidean OR ShortestPath = ( Between 2 roi according to the tree path )
    roiTreeDistanceFunction = 'ShortestPath';
    
%     Can be Euclidean OR PeakDistance OR WindowEventFULLPearson OR
%     WindoEventToPeakPearson OR PeaksPearson
    roiActivityDistanceFunction = 'PeaksPearson';

%     Can be All OR Low OR High OR Medium
    roiActivityPeakSize = 'All';
    
%     Trial Number To plot with Tree
    trialNumber = [1, 2] ;
    samplingRate = 20;
    time_sec_of_trial = 12;
    
    
    firstDepthCompare = 2;
    secDepthCompare = 3;
    
%     load Tree Data
    [gRoi, ~, selectedROITable] = loadSwcFile(neuronTreePathSWC, outputpath);
    
    selectedROI = selectedROITable.Name;
    
    selectedROISplitDepth1 = ones(length(selectedROI), 1) * -1;
    selectedROISplitDepth1 = getSelectedROISplitBranchID(gRoi, firstDepthCompare, selectedROISplitDepth1, selectedROI);   
    
    if (activityByCSV)
        %     load roi activity file
        [roiActivity, roiActivityNames] = loadActivityFile(neuronActiityPathCSV, selectedROI);
    else
        [roiActivity, roiActivityNames] = loadActivityFileFromTPA(neuronActivityPathTPA, selectedROI, outputpath);
    end
        
    
%     Calc Distance Matrix for ROI in Tree
    switch(roiTreeDistanceFunction)
        case 'Euclidean'
           [roiTreeDistanceMatrix, roiSortedByCluster, roiLinkage] = calcROIDistanceInTree_Euclidean(gRoi, selectedROI, outputpath); 
        case 'ShortestPath'
           [roiTreeDistanceMatrix, roiSortedByCluster, roiLinkage] = calcROIDistanceInTree_ShortestPath(gRoi, selectedROITable, outputpath);
    end
    
%     Calc Activity Events Window
    [windowFULL, windowToPeak, locationPeaks, valuePeaks] = calcActivityEventsWindowsAndPeaks(roiActivity, outputpath);

    %     Plot Tree And Trial Activity in the ROI
    
%     totalTrialTime = samplingRate * time_sec_of_trial;
%     plotTreeAndActivityForTrial(trialNumber, totalTrialTime, roiSortedByCluster, roiActivity, roiActivityNames, selectedROI, outputpath, locationPeaks, windowFULL, roiLinkage);
%     
    
    switch(roiActivityPeakSize)
        case 'All'
            peakSelectedIndex = 1:length(locationPeaks);
        case 'Low'
            peakSelectedIndex = valuePeaks < 2;
        case 'High'
            peakSelectedIndex = valuePeaks > 5;
        case 'Medium'
            peakSelectedIndex = valuePeaks >= 2 & valuePeaks <= 5;
    end
    
    valuePeaks = valuePeaks(peakSelectedIndex);    
    locationPeaks = locationPeaks(peakSelectedIndex);
    windowToPeak = windowToPeak(peakSelectedIndex, :);
    windowFULL = windowFULL(peakSelectedIndex, :);
    
%     Calc Distance Matrix for ROI in Activity
   switch(roiActivityDistanceFunction)
        case 'Euclidean'
           [roiActivityDistanceMatrix] = calcROIDistanceInActivity_Euclidean(roiActivity, roiActivityNames, selectedROI, windowFULL); 
        case 'PeakDistance'
           [roiActivityDistanceMatrix] = calcROIDistanceInActivity_PeakDistance(roiActivity, roiActivityNames, selectedROI, locationPeaks);
       case 'WindowEventFULLPearson'
           [roiActivityDistanceMatrix] = calcROIDistanceInActivity_WindowEventPearson(roiActivity, roiActivityNames, selectedROI, windowFULL);
       case 'WindoEventToPeakPearson'
           [roiActivityDistanceMatrix] = calcROIDistanceInActivity_WindowEventPearson(roiActivity, roiActivityNames, selectedROI, windowToPeak);
       case 'PeaksPearson'
           [roiActivityDistanceMatrix] = calcROIDistanceInActivity_WindowEventPearson(roiActivity, roiActivityNames, selectedROI, [locationPeaks, locationPeaks]);
   end

    figDist = figure;
    hold on;
    title({'ROI Activity Distance'});
    xticks(1:length(selectedROI));
    yticks(1:length(selectedROI));
    imagesc(roiActivityDistanceMatrix(roiSortedByCluster, roiSortedByCluster));
    colorbar
    xticklabels(selectedROI(roiSortedByCluster));
    xtickangle(90);
    yticklabels(selectedROI(roiSortedByCluster));
    
    mysave(figDist, [outputpath, '\DistMatrixActivity_', roiActivityDistanceFunction, '_eventsSize', roiActivityPeakSize]);  
    
    yAct = squareform(roiActivityDistanceMatrix);
    lAct = linkage(yAct, 'single');
          
    figDendrogram = figure;
    
    leafOrderAct = optimalleaforder(lAct,yAct);
    
    dendrogram(lAct, 'Labels', selectedROI, 'reorder', leafOrderAct);
    mysave(figDendrogram, [outputpath, '\DendrogramROIActivityDist', roiActivityDistanceFunction, '_eventsSize', roiActivityPeakSize]);
    
  
    plotROIDistMatrixTreeVSActivity(gRoi, outputpath, selectedROISplitDepth1, roiTreeDistanceMatrix, roiActivityDistanceMatrix, true, roiActivityDistanceFunction, roiActivityPeakSize);
    
    
    selectedROISplitDepth3 = ones(length(selectedROI), 1) * -1;
    selectedROISplitDepth3 = getSelectedROISplitBranchID(gRoi, secDepthCompare, selectedROISplitDepth3, selectedROI);   
  
    plotROIDistMatrixTreeVSActivity(gRoi, outputpath, selectedROISplitDepth3, roiTreeDistanceMatrix, roiActivityDistanceMatrix, false, roiActivityDistanceFunction, roiActivityPeakSize);
end