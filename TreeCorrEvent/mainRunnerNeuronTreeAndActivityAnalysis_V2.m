function mainRunnerNeuronTreeAndActivityAnalysis_V2
    neuronTreePathSWC = "E:\Dropbox (Technion Dropbox)\Yara\Analysis\Yara's Data For Shay\SM01\10.22.19_Tuft\10.22.19_Tuft_swcFiles\neuron_3.swc";
    
    activityByCSV = false;
    neuronActiityPathCSV = 'D:\Shay\work\N\SM04\2019-08-18_SM04_handreach_aligned_Ch1_dffByRoi.csv';
    neuronActivityPathTPA = "E:\Dropbox (Technion Dropbox)\Yara\Analysis\SM01\10.22.19_Tuft";
    
    outputpath = "E:\Dropbox (Technion Dropbox)\Yara\Analysis\Yara's Data For Shay\comparison event detection\NewResults\SM01\10.22.19_Tuft\Ne_3\V4_withfilter_onecluster";
    outputpath = char(outputpath);
    mkdir(outputpath);
   
%     Can be Euclidean OR ShortestPath = ( Between 2 roi according to the tree path )
    roiTreeDistanceFunction = 'ShortestPath';
    
%     Can be WindowEventFULLPearson OR
%     WindoEventToPeakPearson OR PeaksPearson
    roiActivityDistanceFunction = 'WindoEventToPeakPearson';
      
    doComboForCloseRoi = false;
    
    firstDepthCompare = 1;
    secDepthCompare = 2;
    
%     load Tree Data
    [gRoi, ~, selectedROITable] = loadSwcFile(neuronTreePathSWC, outputpath, doComboForCloseRoi);
    
    selectedROI = selectedROITable.Name;
    
    selectedROISplitDepth1 = ones(length(selectedROI), 1) * -1;
    selectedROISplitDepth1 = getSelectedROISplitBranchID(gRoi, firstDepthCompare, selectedROISplitDepth1, selectedROI);   
    
    clusterCount = 1;
    
    roi_count = length(selectedROI);
    aV = ones(1, roi_count)*0.35;
    aV(6) = 0.15;
    
    DeconvFiltDur           = .4;       % smoothing filter duration in sec       
    filter_forROI = ones(1, roi_count) * 1;
    
%     Trial Number To plot with Tree

    save([outputpath '\runParametes'],'aV', 'roi_count', 'filter_forROI', 'DeconvFiltDur');

    trialNumber = [1, 2] ;
    samplingRate = 30;
    time_sec_of_trial = 12;
        
    
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
   
    [all_locationFull_start, all_locationFull_end, all_locationFull_pks, activityClusterValue] = calcActivityEventsWindowsAndPeaks_V2(roiActivity, outputpath, clusterCount, samplingRate, tr_frame_count, aV, roiActivityNames);

    all_event_struct.end = all_locationFull_end;
    
    all_event_struct.start = all_locationFull_start;
    
    all_event_struct.pks = all_locationFull_pks;
    
    all_event_struct.cluster = activityClusterValue;
    
    %     Plot Tree And Trial Activity in the ROI
    
%     totalTrialTime = samplingRate * time_sec_of_trial;
%     plotTreeAndActivityForTrial(trialNumber, totalTrialTime, roiSortedByCluster, roiActivity, roiActivityNames, selectedROI, outputpath, locationPeaks, windowFULL, roiLinkage);
%     


%     Filter ROI activity if needed
%     
    sampFreq        = samplingRate;
    filtDur         = DeconvFiltDur * sampFreq;      % filter duration in sec
    filtLenH        = ceil(filtDur/2);
    filtLen         = filtLenH*2;

    filtSmooth          = hamming(filtLen);
    filtSmooth          = filtSmooth./sum(filtSmooth);


    for i_activity = 1:size(roiActivity, 2)
        if filter_forROI(i_activity)
            fig = figure;
            hold on;
            title({'ROI with filter', roiActivityNames{i_activity}});
            plot(roiActivity(:, i_activity));
            roiActivity(:, i_activity) = filtfilt(filtSmooth,1,roiActivity(:, i_activity));   
            plot(roiActivity(:, i_activity));

            mysave(fig, [outputpath '\filterResults\roiActivity_' num2str(i_activity)]); 
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