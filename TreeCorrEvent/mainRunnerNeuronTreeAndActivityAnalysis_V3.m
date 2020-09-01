function mainRunnerNeuronTreeAndActivityAnalysis_V3
    neuronTreePathSWC = "E:\Dropbox (Technion Dropbox)\Yara\Layer 5_Analysis\Yara's Data For Shay\SM04\08_18_19_tuft_Final_Version\08.18.19_Tuft_Final_Version_07.15.20\swcFiles_neuron1,3,4\neuron_1.swc";
    
    activityByCSV = false;
    neuronActiityPathCSV = "E:\Dropbox (Technion Dropbox)\Yara\Layer 5_Analysis\Yara's Data For Shay\SM04\08.18.19_Tuft\Nate\2019-08-18_SM04_handreach_aligned_Ch1_dffByRoi.csv";
    neuronActivityPathTPA = "E:\Dropbox (Technion Dropbox)\Yara\Layer 5_Analysis\SM04\08_18_19_tuft_Final_Version";
    
    hyperbolicDistMatrixLocation = "E:\Dropbox (Technion Dropbox)\Yara\Layer 5_Analysis\Yara's Data For Shay\SM04\08_18_19_tuft_Final_Version\Analysis\StructuralTreeHyperbolic\matlab_matrix_normal2.mat"; 
    
    behaveFileTreadMillPath = '';
    behaveFrameRate = 100;
    
    outputpath = "E:\Dropbox (Technion Dropbox)\Yara\Layer 5_Analysis\Yara's Data For Shay\SM04\08_18_19_tuft_Final_Version\Analysis\N1\Structural_VS_Functional\1-9-20\Run1\";
    outputpath = char(outputpath);
    mkdir(outputpath);
   
%     Can be Euclidean OR ShortestPath OR HyperbolicDist_L OR HyperbolicDist_P  = ( Between 2 roi according to the tree path )
    roiTreeDistanceFunction = 'HyperbolicDist_P';
    
%     Can be WindowEventFULLPearson OR
%     WindoEventToPeakPearson OR PeaksPearson
    roiActivityDistanceFunction = 'WindoEventToPeakPearson';
      
    excludeRoi = [9];
    
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
      
    clusterCount = 4;
    eventWin = 10;
    
    roi_count = length(selectedROI);
    aV = ones(1, roi_count)*0.3;      
    
    sigmaChangeValue = zeros(1, roi_count);

    
%     Trial Number To plot with Tree

    save([outputpath '\runParametes'],'aV', 'roi_count', 'sigmaChangeValue', 'excludeRoi', 'hyperbolicDistMatrixLocation', 'clusterCount', 'eventWin', 'roiTreeDistanceFunction');

    fid=fopen([outputpath '\Parametes.txt'],'w');
    fprintf(fid, 'hyperbolicDistMatrixLocation : %s r\n', hyperbolicDistMatrixLocation);    
    fprintf(fid, 'roiTreeDistanceFunction : %s r\n', roiTreeDistanceFunction);
    fprintf(fid, 'roiActivityDistanceFunction : %s r\n', roiActivityDistanceFunction);    
    fprintf(fid, 'clusterCount : %d r\n', clusterCount);
    fprintf(fid, 'eventWin : %d r\n', eventWin);
    fclose(fid);
    
    trialNumber = [1, 2] ;
    samplingRate = 20;
    time_sec_of_trial = 12;
        
    
    if (activityByCSV)
        %     load roi activity file
        [roiActivity, roiActivityNames] = loadActivityFile(neuronActiityPathCSV, selectedROI);
        tr_frame_count = [];
    else
        [roiActivity, roiActivityNames, tr_frame_count] = loadActivityFileFromTPA(neuronActivityPathTPA, selectedROI, outputpath);
    end
    
    save([outputpath, '\roiActivityRawData.mat'], 'roiActivity', 'roiActivityNames');
    
    
%     Behave TreadMillData
    if ~isempty(behaveFileTreadMillPath)
        [speedBehave, accelBehave, speedActivity, accelActivity] = treadmilBehave(behaveFileTreadMillPath, behaveFrameRate);
        plotBaseTreadMillActivity(speedBehave, accelBehave, roiActivity, outputpath);
    end
         
   load(hyperbolicDistMatrixLocation);

    
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
   
    if isfile([outputpath, '\roiActivity_comb.mat'])
        load([outputpath, '\roiActivity_comb.mat'], 'allEventsTable', 'roiActivity_comb');
    else
        [allEventsTable, roiActivity_comb] = calcActivityEventsWindowsAndPeaks_V3(roiActivity, outputpath, clusterCount, samplingRate, tr_frame_count, aV, roiActivityNames, sigmaChangeValue);
        save([outputpath, '\roiActivity_comb.mat'], 'allEventsTable', 'roiActivity_comb');
    end
    
    roiActivity_comb = double(roiActivity_comb);
    saveROIBranchingIndexAsLabel(eventWin, gRoi, selectedROISplitDepth1, selectedROI, outputpath, firstDepthCompare, allEventsTable, roiActivity_comb, tr_frame_count);
    saveROIBranchingIndexAsLabel(eventWin, gRoi, selectedROISplitDepth3, selectedROI, outputpath, secDepthCompare, allEventsTable, roiActivity_comb, tr_frame_count);

%     saveNewTPAFile(selectedROI, roiActivity_comb, tr_frame_count);
    
%     Plot Tree And Trial Activity in the ROI    
%     totalTrialTime = samplingRate * time_sec_of_trial;
%     plotTreeAndActivityForTrial(trialNumber, totalTrialTime, roiSortedByCluster, roiActivity, roiActivityNames, selectedROI, outputpath, locationPeaks, windowFULL, roiLinkage);
%     
    
    import mlreportgen.ppt.*
    ppt = Presentation([outputpath '\AnalysisResultsPresentation'], 'AnalysisP.potm');
    open(ppt);
    currentResultsSlideByH = add(ppt, 'AnalysisP');
    currentResultsSlideByP = add(ppt, 'AnalysisP');
    index_presentaionByH = 1;
    index_presentaionByP = 1;
       
    for i_cluster = -1:clusterCount
        if i_cluster == 0
            roiActivityPeakSize = 'All';
        elseif i_cluster == -1
            roiActivityPeakSize = 'All_ExcludeSmallEvents';
        else
            roiActivityPeakSize = ['cluster', num2str(i_cluster)];
        end
        
        outputpathCurr = [outputpath, roiActivityPeakSize];
           
    %     Calc Distance Matrix for ROI in Activity
       switch(roiActivityDistanceFunction)
           case 'WindowEventFULLPearson'
               [roiActivityDistanceMatrixByH, roiActivityDistanceMatrixByP] = calcROIDistanceInActivity_WindowEventPearson_V3(roiActivity_comb, roiActivityNames, selectedROI, allEventsTable, 'FULL', i_cluster);
                
               plotTreeByROIAverageActivityWithCluster(gRoi, outputpathCurr, roiActivity_comb, roiActivityNames, selectedROI, allEventsTable, 'FULL', i_cluster)

           case 'WindoEventToPeakPearson'
               [roiActivityDistanceMatrixByH, roiActivityDistanceMatrixByP] = calcROIDistanceInActivity_WindowEventPearson_V3(roiActivity_comb, roiActivityNames, selectedROI, allEventsTable, 'ToPeak', i_cluster);

               plotTreeByROIAverageActivityWithCluster(gRoi, outputpathCurr, roiActivity_comb, roiActivityNames, selectedROI, allEventsTable, 'ToPeak', i_cluster)

           case 'PeaksPearson'
               [roiActivityDistanceMatrixByH, roiActivityDistanceMatrixByP] = calcROIDistanceInActivity_WindowEventPearson_V3(roiActivity_comb, roiActivityNames, selectedROI, allEventsTable, 'Peaks', i_cluster);
            
               plotTreeByROIAverageActivityWithCluster(gRoi, outputpathCurr, roiActivity_comb, roiActivityNames, selectedROI, allEventsTable, 'Peaks', i_cluster)
       end

       index_presentaionByH = plotResultesByClusterType(currentResultsSlideByH, roiActivityDistanceMatrixByH, 'ByH', selectedROI, roiSortedByCluster, outputpathCurr, roiActivityDistanceFunction,...
           roiActivityPeakSize, gRoi, roiTreeDistanceMatrix, selectedROISplitDepth3, selectedROISplitDepth1, index_presentaionByH, selectedROITable, i_cluster);
      
       index_presentaionByP = plotResultesByClusterType(currentResultsSlideByP, roiActivityDistanceMatrixByP, 'ByP', selectedROI, roiSortedByCluster, outputpathCurr, roiActivityDistanceFunction,...
           roiActivityPeakSize, gRoi, roiTreeDistanceMatrix, selectedROISplitDepth3, selectedROISplitDepth1, index_presentaionByP, selectedROITable, i_cluster);       
    end  
    
    close(ppt);
end
 
function index_presentaion = plotResultesByClusterType(currentResultsSlide, roiActivityDistanceMatrix, clusterType, selectedROI, roiSortedByCluster, outputpathCurr, roiActivityDistanceFunction, roiActivityPeakSize, gRoi, roiTreeDistanceMatrix, selectedROISplitDepth3, selectedROISplitDepth1, index_presentaion, selectedROITable, i_cluster)
        import mlreportgen.ppt.*
    
        figDist = figure;
        hold on;
        title({'ROI Activity Distance'});
        xticks(1:length(selectedROI));
        yticks(1:length(selectedROI));
        imagesc(roiActivityDistanceMatrix(roiSortedByCluster, roiSortedByCluster));
        colorbar
        colormap(jet);
%         colormap(flipud(jet));
        
%         caxis([0,1]);
        xticklabels(selectedROI(roiSortedByCluster));
        xtickangle(90);
        yticklabels(selectedROI(roiSortedByCluster));
        picNameFile = [outputpathCurr, '\' , clusterType, '\DistMatrixActivity_', roiActivityDistanceFunction, '_eventsSize', roiActivityPeakSize];
        mysave(figDist, picNameFile);  

      
        pictureNames = plotROIDistMatrixTreeVSActivity(gRoi, [outputpathCurr, '\' , clusterType],selectedROISplitDepth1, selectedROISplitDepth1, roiTreeDistanceMatrix, roiActivityDistanceMatrix, true, roiActivityDistanceFunction, roiActivityPeakSize, selectedROI);

        plotROIDistMatrixTreeVSActivity(gRoi, [outputpathCurr, '\' , clusterType],selectedROISplitDepth1, selectedROISplitDepth3, roiTreeDistanceMatrix, roiActivityDistanceMatrix, false, roiActivityDistanceFunction, roiActivityPeakSize, selectedROI);
        
        plotRoiDistMatrixTreeVsActivityForDepthCompare(gRoi, [outputpathCurr, '\' , clusterType],  selectedROITable, roiTreeDistanceMatrix, roiActivityDistanceMatrix, roiActivityDistanceFunction, roiActivityPeakSize );
        
        if i_cluster ~= -1
            replace(currentResultsSlide.Children(index_presentaion), Picture([picNameFile '.tif']));       
            replace(currentResultsSlide.Children(index_presentaion + 1), Picture([pictureNames{1} '.tif']));
            index_presentaion = index_presentaion + 2;
        end
        
end

function saveROIBranchingIndexAsLabel(eventWin, gRoi, selectedROISplitDepth1, selectedROI, outputpath, depthNumber, allEventsTable, roiActivity_comb, tr_frame_count)
    classesMDepth1 = unique(selectedROISplitDepth1);
    eventStr = [];
    selectedROISplitDepthToSave1 = selectedROISplitDepth1;
    for indexC = 1:length(classesMDepth1)
        eventStr = [eventStr gRoi.Nodes(classesMDepth1(indexC),:).Name{1} '_'];
        labelsLUT(indexC) = gRoi.Nodes(classesMDepth1(indexC),:).Name(1);
        cls(indexC, :) = getTreeColor('within', indexC);
        selectedROISplitDepthToSave1(selectedROISplitDepth1 == classesMDepth1(indexC)) = indexC;
    end
    
    roiTableLabelDepth1.roiNames =  selectedROI;
    roiTableLabelDepth1.labelsLUT = labelsLUT;
    roiTableLabelDepth1.eventsStr = eventStr;    
    roiTableLabelDepth1.cls = cls;
    roiTableLabelDepth1.labels = selectedROISplitDepthToSave1;
    
    for events_index = 1:size(allEventsTable, 1)
        event_curr_loc = (allEventsTable.pks(events_index)-eventWin):(allEventsTable.pks(events_index)+eventWin);
        
        for roiIndex = 1:length(selectedROI)
            roiTableLabelDepth1.activity.dataEvents(roiIndex, 1:length(event_curr_loc), events_index) = roiActivity_comb(event_curr_loc,roiIndex);
        end
        
        roiTableLabelDepth1.activity.labels(events_index) = allEventsTable.clusterByH(events_index);
    end
    
    for trialIndex = 1:(size(roiActivity_comb, 1) / tr_frame_count)
         for roiIndex = 1:length(selectedROI)
            roiTableLabelDepth1.activity.dataTrials(roiIndex, 1:tr_frame_count, trialIndex) = roiActivity_comb(((trialIndex - 1) * tr_frame_count + 1):(trialIndex * tr_frame_count),roiIndex);
         end  
    end
    
    save([outputpath, '\structuralTreeLabels_depth', num2str(depthNumber) '.mat'], 'roiTableLabelDepth1');
end