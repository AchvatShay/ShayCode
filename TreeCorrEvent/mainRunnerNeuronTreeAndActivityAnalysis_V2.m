function mainRunnerNeuronTreeAndActivityAnalysis_V2
    neuronTreePathSWC = "E:\Dropbox (Technion Dropbox)\Yara\Analysis\Yara's Data For Shay\SM04\08.18.19\08.18.19_Tuft_new_05.04.20\swcFiles_Without9\neuron_1.swc";
    
    activityByCSV = false;
    neuronActiityPathCSV = 'D:\Shay\work\N\SM04\2019-08-18_SM04_handreach_aligned_Ch1_dffByRoi.csv';
    neuronActivityPathTPA = "E:\Dropbox (Technion Dropbox)\Yara\Analysis\Yara's Data For Shay\SM04\08.18.19\08.18.19_Tuft_new_05.04.20\18_08_19";
    
    outputpath = "E:\Dropbox (Technion Dropbox)\Test\Tuft_new_05.04.20\ByStartToPeak";
    outputpath = char(outputpath);
    
%     Can be Euclidean OR ShortestPath = ( Between 2 roi according to the tree path )
    roiTreeDistanceFunction = 'ShortestPath';
    
%     Can be WindowEventFULLPearson OR
%     WindoEventToPeakPearson OR PeaksPearson
    roiActivityDistanceFunction = 'WindoEventToPeakPearson';
        
    threshold_std = 3;
    PeakWidth = 3;
    clusterCount = 3;
    histBinWidth = 0.01;
    
    roi_count = 19;
    aV = ones(1, roi_count)*0.2;
    aV(1) = 0.3;
% %     aV(5) = 0.2;
% %     aV(9) = 0.4;
%     aV(17) = 0.1;
%     aV(18) = 0.1;
%     aV(19) = 0.1;
%     aV(14) = 0.15;
%     aV(4) = 0.15;
%     aV(11) = 0.1;
%     aV(8) = 0.2;
%     aV(5) = 0.3;
%     aV(12) = 0.15;
%     aV(13) = 0.1;
%     aV(15) = 0.15;
%     

%     aV(5) = 0.2;
%     aV(9) = 0.4;
%     aV(1) = 0.3;
    aV(17) = 0.1;
    aV(18) = 0.1;
    aV(19) = 0.1;
    aV(14) = 0.15;
    aV(4) = 0.15;
    aV(11) = 0.1;
    aV(12) = 0.15;
    aV(13) = 0.1;
    aV(15) = 0.15;
   


%     Trial Number To plot with Tree
    trialNumber = [1, 2] ;
    samplingRate = 20;
    time_sec_of_trial = 12;
        
    DeconvFiltDur           = .4;       % smoothing filter duration in sec
        
    doActivityLowFilter = false;
    doComboForCloseRoi = false;
    
    firstDepthCompare = 1;
    secDepthCompare = 2;
    
%     load Tree Data
    [gRoi, ~, selectedROITable] = loadSwcFile(neuronTreePathSWC, outputpath, doComboForCloseRoi);
    
    selectedROI = selectedROITable.Name;
    
    selectedROISplitDepth1 = ones(length(selectedROI), 1) * -1;
    selectedROISplitDepth1 = getSelectedROISplitBranchID(gRoi, firstDepthCompare, selectedROISplitDepth1, selectedROI);   
    
    if (activityByCSV)
        %     load roi activity file
        [roiActivity, roiActivityNames] = loadActivityFile(neuronActiityPathCSV, selectedROI);
    else
        [roiActivity, roiActivityNames, tr_frame_count] = loadActivityFileFromTPA(neuronActivityPathTPA, selectedROI, outputpath);
    end
        
    
%     Calc Distance Matrix for ROI in Tree
    switch(roiTreeDistanceFunction)
        case 'Euclidean'
           [roiTreeDistanceMatrix, roiSortedByCluster, roiLinkage] = calcROIDistanceInTree_Euclidean(gRoi, selectedROI, outputpath); 
        case 'ShortestPath'
           [roiTreeDistanceMatrix, roiSortedByCluster, roiLinkage] = calcROIDistanceInTree_ShortestPath(gRoi, selectedROITable, outputpath);
    end
    
%     Calc Activity Events Window
   
    [all_locationFull_start, all_locationFull_end, all_locationFull_pks, activityClusterValue] = calcActivityEventsWindowsAndPeaks_V2(roiActivity, outputpath, threshold_std, PeakWidth, clusterCount, histBinWidth, samplingRate, tr_frame_count, aV);

    all_event_struct.end = all_locationFull_end;
    
    all_event_struct.start = all_locationFull_start;
    
    all_event_struct.pks = all_locationFull_pks;
    
    all_event_struct.cluster = activityClusterValue;
    
    %     Plot Tree And Trial Activity in the ROI
    
%     totalTrialTime = samplingRate * time_sec_of_trial;
%     plotTreeAndActivityForTrial(trialNumber, totalTrialTime, roiSortedByCluster, roiActivity, roiActivityNames, selectedROI, outputpath, locationPeaks, windowFULL, roiLinkage);
%     
    
    if doActivityLowFilter
        sampFreq        = samplingRate;
        filtDur         = DeconvFiltDur * sampFreq;      % filter duration in sec
        filtLenH        = ceil(filtDur/2);
        filtLen         = filtLenH*2;

        filtSmooth          = hamming(filtLen);
        filtSmooth          = filtSmooth./sum(filtSmooth);
        
        
        for i_activity = 1:size(roiActivity, 2)
            fig = figure;
            hold on;
        
            plot(roiActivity(:, i_activity));
            roiActivity(:, i_activity) = filtfilt(filtSmooth,1,roiActivity(:, i_activity));   
            plot(roiActivity(:, i_activity));
            
            mysave(fig, ['\filterResults\roiActivity_' num2str(i_activity)]);  
        end
    end

    for i_cluster = 0:clusterCount
        if i_cluster == 0
            roiActivityPeakSize = 'All';
        else
            roiActivityPeakSize = ['cluster', num2str(i_cluster)];
        end
        
        outputpathCurr = [outputpath, '\', roiActivityPeakSize '\'];
           
    %     Calc Distance Matrix for ROI in Activity
       switch(roiActivityDistanceFunction)
           case 'WindowEventFULLPearson'
               [roiActivityDistanceMatrix] = calcROIDistanceInActivity_WindowEventPearson(roiActivity, roiActivityNames, selectedROI, all_event_struct, 'FULL', i_cluster);
           case 'WindoEventToPeakPearson'
               [roiActivityDistanceMatrix] = calcROIDistanceInActivity_WindowEventPearson(roiActivity, roiActivityNames, selectedROI, all_event_struct, 'ToPeak', i_cluster);
           case 'PeaksPearson'
               [roiActivityDistanceMatrix] = calcROIDistanceInActivity_WindowEventPearson(roiActivity, roiActivityNames, selectedROI, all_event_struct, 'Peaks', i_cluster);
       end

        figDist = figure;
        hold on;
        title({'ROI Activity Distance'});
        xticks(1:length(selectedROI));
        yticks(1:length(selectedROI));
        imagesc(roiActivityDistanceMatrix(roiSortedByCluster, roiSortedByCluster));
        colorbar
        colormap(jet);
        colormap(flipud(jet));
        
%         caxis([0,1]);
        xticklabels(selectedROI(roiSortedByCluster));
        xtickangle(90);
        yticklabels(selectedROI(roiSortedByCluster));

        mysave(figDist, [outputpathCurr, '\DistMatrixActivity_', roiActivityDistanceFunction, '_eventsSize', roiActivityPeakSize]);  

        plotROIDistMatrixTreeVSActivity(gRoi, outputpathCurr, selectedROISplitDepth1, roiTreeDistanceMatrix, roiActivityDistanceMatrix, true, roiActivityDistanceFunction, roiActivityPeakSize, selectedROI);


        selectedROISplitDepth3 = ones(length(selectedROI), 1) * -1;
        selectedROISplitDepth3 = getSelectedROISplitBranchID(gRoi, secDepthCompare, selectedROISplitDepth3, selectedROI);   

        plotROIDistMatrixTreeVSActivity(gRoi, outputpathCurr, selectedROISplitDepth3, roiTreeDistanceMatrix, roiActivityDistanceMatrix, false, roiActivityDistanceFunction, roiActivityPeakSize, selectedROI);
        
        
        plotRoiDistMatrixTreeVsActivityForDepthCompare(gRoi, outputpathCurr,  selectedROITable, roiTreeDistanceMatrix, roiActivityDistanceMatrix, roiActivityDistanceFunction, roiActivityPeakSize );
        
    end   
 end