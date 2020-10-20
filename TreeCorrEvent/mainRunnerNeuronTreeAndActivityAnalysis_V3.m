function mainRunnerNeuronTreeAndActivityAnalysis_V3
    neuronTreePathSWC = "C:\Users\Jackie\Dropbox (Technion Dropbox)\Yara\Layer 5_Analysis\Shay\SM04\07.03.19_RewardRun\07.03.19_SM04_RewardRun_swcFiles\neuron_2.swc";
    
    activityByCSV = false;
    neuronActiityPathCSV = "";
    neuronActivityPathTPA = "C:\Users\Jackie\Dropbox (Technion Dropbox)\Yara\Layer 5_Analysis\SM04\07.03.19_RewardRun\";
    
    hyperbolicDistMatrixLocation = "";
%     hyperbolicDistMatrixLocation = "C:\Users\Jackie\Dropbox (Technion Dropbox)\Yara\Layer 5_Analysis\Shay\SM04\07.03.19_RewardRun\Analysis\N1\Structural_VS_Functional\14-10-20\Run1\HS_create\StructuralTreeHyperbolic\matlab_matrixbernoulli_100_3000.mat"; 
    
    
    outputpath = "C:\Users\Jackie\Dropbox (Technion Dropbox)\Yara\Layer 5_Analysis\Shay\SM04\07.03.19_RewardRun\Analysis\N2\Structural_VS_Functional\19-10-20\Run1\no_behave\Pearson\SP\";
    outputpath = char(outputpath);
    mkdir(outputpath);
   
    behaveFileTreadMillPath = "C:\Users\Jackie\Dropbox (Technion Dropbox)\Yara\Layer 5_Analysis\Shay\SM04\07.03.19_RewardRun\07.03.19_SM04_RewardRun_Behavior.txt";
    behaveFrameRateTM = 100;
    
    ImageSamplingRate = 20;
    time_sec_of_trial = 30;
    trialNumber = [1, 2] ;
    BehavioralSamplingRate = 200;
    behavioralDelay = 20;
       
%     No events put non
    runByEvent = {'non'};
    isHandreach = false;
    
%     FOR Hand Reach 
%     NO labels 0, 1 suc , 2 fail
    split_trialsLabel = 0;
    runBehaveLag = [-inf, inf];
    do_events_seq = [];
    doBehaveAlignedPlot = false;
        
%     Can be Euclidean OR ShortestPath OR HyperbolicDist_L OR HyperbolicDist_P  = ( Between 2 roi according to the tree path )
    roiTreeDistanceFunction = 'ShortestPath';
    
%     Can be WindowEventFULLPearson OR
%     WindoEventToPeakPearson OR PeaksPearson
%     OR WindoEventToPeakCov
    roiActivityDistanceFunction = 'WindoEventToPeakPearson';
      
    clusterCount = 4;
    eventWin = 10;
    
    % 0.01 
    mean_aV = 0.01; 
        
    excludeRoi = [34];
    
    apical_roi = [];
    
    doComboForCloseRoi = false;
    
    firstDepthCompare = 1;
    secDepthCompare = 2;
    
%     load Tree Data
    [gRoi, rootNodeID, selectedROITable] = loadSwcFile(neuronTreePathSWC, outputpath, doComboForCloseRoi);
    
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
    
    for in = 1:length(runByEvent)
        fprintf(fid, 'event behave : %s r\n', runByEvent{in});
    end
    
    fprintf(fid, 'event behave lag : %d - %d r\n', runBehaveLag(1), runBehaveLag(2));
    fclose(fid);
        
    
    if (activityByCSV)
        %     load roi activity file
        [roiActivity, roiActivityNames] = loadActivityFile(neuronActiityPathCSV, selectedROI);
        tr_frame_count = [];
    else
        [roiActivity, roiActivityNames, tr_frame_count] = loadActivityFileFromTPA(neuronActivityPathTPA, selectedROI, outputpath);
    end
      
%     Behave TreadMillData
      
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
    
    % Save Graph for HS structure with colors
    classesD1 = unique(selectedROISplitDepth1);   
    classesD2 = unique(selectedROISplitDepth3);   
    
    classesD1(classesD1 == -1) = [];
    classesD2(classesD2 == -1) = [];
    
    colorMatrix1 = zeros(length(selectedROISplitDepth1), 3);
    colorMatrix2 = zeros(length(selectedROISplitDepth3), 3);
    for d_i = 1:length(selectedROISplitDepth1)
        colorMatrix1(d_i, :) = getTreeColor('within', find(classesD1 == selectedROISplitDepth1(d_i)));
        colorMatrix2(d_i, :) = getTreeColor('within', find(classesD2 == selectedROISplitDepth3(d_i)));
    end
    
    save([outputpath, '\roiActivityRawData.mat'], 'roiActivity', 'roiActivityNames', 'colorMatrix1', 'colorMatrix2');
    saveGraphForHS(gRoi, rootNodeID, outputpath, colorMatrix1, colorMatrix2, selectedROITable);
    
%     Calc Activity Events Window

    close all;

    if isfile([outputpath, '\roiActivity_comb.mat'])
        load([outputpath, '\roiActivity_comb.mat'], 'allEventsTable', 'roiActivity_comb');        
    elseif all(strcmp(runByEvent, 'non'))
        [allEventsTable, roiActivity_comb] = calcActivityEventsWindowsAndPeaks_V3(roiActivity, outputpath, clusterCount, ImageSamplingRate, tr_frame_count, aV, roiActivityNames, sigmaChangeValue, mean_aV);
        
        save([outputpath, '\roiActivity_comb.mat'], 'allEventsTable', 'roiActivity_comb');
    else
        error('first run all with no events')
    end    
    
    for i_e = 1:size(allEventsTable, 1)
        tr_index = floor(allEventsTable.start(i_e) ./ tr_frame_count) + 1;
        allEventsTable.tr_index(i_e) = tr_index;
    end
    
    if isHandreach
       if all(~strcmp(runByEvent, 'non'))
           [BehaveDataAll, NAMES, trials_label] = loadBDAFile(neuronActivityPathTPA, BehavioralSamplingRate, ImageSamplingRate, tr_frame_count, behavioralDelay);
        
           runByEventTemp = {};
           runBehaveLagTemp = [];
           for i_run = 1:length(runByEvent)
                if contains(runByEvent(i_run), '_all')
                    runByEvent_fix = replace(runByEvent{i_run}, '_all', '');
                    newEvents = NAMES(contains(NAMES, runByEvent_fix)&(~contains(NAMES, ['last' runByEvent_fix])));
                    runByEventTemp((end + 1 ): (end + length(newEvents))) = newEvents;
                    runBehaveLagTemp((end + 1 ): (end + length(newEvents)), :) = [ones(length(newEvents), 1) * runBehaveLag(i_run, 1), ones(length(newEvents), 1) * runBehaveLag(i_run, 2)];
                else
                    runByEventTemp(end+1) = runByEvent(i_run);
                    runBehaveLagTemp(end + 1, :) = runBehaveLag(i_run, :);
                end
           end
           
           currentEventLoc = zeros(length(runByEventTemp),1);
           for in = 1:length(runByEventTemp)
              currentEventLoc(in) = find(strcmp(NAMES, runByEventTemp{in}));
              
              if doBehaveAlignedPlot
                 plotEventCaForBehaveDataHandReach(BehaveDataAll.(NAMES{currentEventLoc(in)}).startTiming, allEventsTable, clusterCount, outputpath)           
              end
           end
           
           eventsIndexTodelete = zeros(1, size(allEventsTable, 1));
           for i_e = 1:size(allEventsTable, 1)
               if split_trialsLabel ~= 0 & trials_label(allEventsTable.tr_index(i_e)) ~= split_trialsLabel
                    eventsIndexTodelete(i_e) = 1;
                    continue;
               end
               
               alignedLocation = zeros(1, length(runByEventTemp));
               aligned_start = zeros(1, length(runByEventTemp));
               
               checkEvent = zeros(1, length(runByEventTemp));
               for in = 1:length(runByEventTemp)
                   alignedLocation(in) = BehaveDataAll.(NAMES{currentEventLoc(in)}).startTiming(allEventsTable.tr_index(i_e));
                   
                   if alignedLocation(in) ~= 0
                      alignedLocation(in) = (allEventsTable.tr_index(i_e) - 1) * tr_frame_count + alignedLocation(in);
                      aligned_start(in) = allEventsTable.start(i_e) - alignedLocation(in);
                      if (aligned_start(in) < runBehaveLagTemp(in, 1)) | (aligned_start(in) > runBehaveLagTemp(in, 2))
                         checkEvent(in) = 1; 
                      end
                   else
                       checkEvent(in) = 1;
                   end
               end
               
               if ~isempty(do_events_seq)
                   seq_check = zeros(1, size(do_events_seq, 1));
                   for seq = 1:size(do_events_seq, 1)
                       if ~all(checkEvent(do_events_seq(seq, :)) == 0)
                          seq_check(seq) = 1;
                       end
                   end
                   
                   if all(seq_check == 1)
                        eventsIndexTodelete(i_e) = 1;
                   end
               else
                    if all(checkEvent == 1)
                        eventsIndexTodelete(i_e) = 1;
                    end
               end              
              
           end

           allEventsTable(eventsIndexTodelete == 1, :) = [];
       end
    else
        [speedBehave, accelBehave, ~, ~, BehaveDataTreadmil] = treadmilBehave(behaveFileTreadMillPath, behaveFrameRateTM, ImageSamplingRate);
        
        if all(~strcmp(runByEvent, 'non'))
           eventsIndexTodelete = zeros(1, size(allEventsTable, 1));
           
           for i_e = 1:size(allEventsTable, 1)
               
               check_runByEvents = zeros(size(runByEvent));
               for ind = 1:length(runByEvent)
                   if isempty(find(allEventsTable.start(i_e) == BehaveDataTreadmil.(runByEvent{ind}), 1))
                       check_runByEvents(ind) = 1;
                   end
               end
               
               if all(check_runByEvents == 1)
                   eventsIndexTodelete(i_e) = 1;               
               end
               
           end
           
           allEventsTable(eventsIndexTodelete == 1, :) = [];
        else
            plotBaseTreadMillActivity(speedBehave, accelBehave, roiActivity, outputpath, selectedROI, allEventsTable, clusterCount); 
            plotEventsCaForBehaveDataTreadMil(speedBehave, accelBehave, allEventsTable, clusterCount, outputpath, 300, BehaveDataTreadmil);
        end
        
    end
    
    writetable(allEventsTable,[outputpath '\eventsCaSummary.csv']);
    
    if isempty(allEventsTable)
        close all;
        fclose('all');
        return;
    end
    
    roiActivity_comb = double(roiActivity_comb);
    saveROIBranchingIndexAsLabel(eventWin, gRoi, selectedROISplitDepth1, selectedROI, outputpath, firstDepthCompare, allEventsTable, roiActivity_comb, tr_frame_count);
    saveROIBranchingIndexAsLabel(eventWin, gRoi, selectedROISplitDepth3, selectedROI, outputpath, secDepthCompare, allEventsTable, roiActivity_comb, tr_frame_count);

%     for HS Activity! with cluster
    saveDataForHS(allEventsTable, roiActivity, roiActivity_comb, roiActivityNames, outputpath, colorMatrix1, colorMatrix2);

%     saveNewTPAFile(selectedROI, roiActivity_comb, tr_frame_count);
    
%     Plot Tree And Trial Activity in the ROI    
%     totalTrialTime = ImageSamplingRate * time_sec_of_trial;
%     plotTreeAndActivityForTrial(trialNumber, totalTrialTime, roiSortedByCluster, roiActivity, roiActivityNames, selectedROI, outputpath, locationPeaks, windowFULL, roiLinkage);
%     
    
    analysisEventsActivityForROI(gRoi, allEventsTable, selectedROI, selectedROISplitDepth1, outputpath, ['Depth1_Behave_' runByEvent{:}], clusterCount);
    analysisEventsActivityForROI(gRoi, allEventsTable, selectedROI, selectedROISplitDepth3, outputpath, ['Depth2_Behave_' runByEvent{:}], clusterCount);

    close all;

    import mlreportgen.ppt.*
    ppt = Presentation([outputpath '\AnalysisResultsPresentation'], 'AnalysisP.potm');
    open(ppt);
    currentResultsSlideSt = add(ppt, 'Analysis_St');
    
    currentResultsSlideByH = add(ppt, 'AnalysisP');
    currentResultsSlideByP = add(ppt, 'AnalysisP');
    
    currentResultsSlideByH_s = add(ppt, 'AnalysisP');
    currentResultsSlideByP_s = add(ppt, 'AnalysisP');
    
    currentResultsSlideByH_Dendogram = add(ppt, 'AnalysisD');
    currentResultsSlideByP_Dendogram = add(ppt, 'AnalysisD');
    
    replace(currentResultsSlideSt.Children(1), Picture([outputpath '\GraphWithROI.tif']));       
    replace(currentResultsSlideSt.Children(2), Picture([outputpath '\DistMatrixROIStructure.tif']));       
            
    
    index_presentaionByH = 1;
    index_presentaionByP = 1;
       
    for i_cluster = -1:clusterCount
        if i_cluster == 0
            roiActivityPeakSize = 'All';
            event_count_ByH = size(allEventsTable, 1);
            event_count_ByP = size(allEventsTable, 1);
        elseif i_cluster == -1
            roiActivityPeakSize = 'All_ExcludeSmallEvents';
            
            event_count_ByH = sum(allEventsTable.clusterByH ~= 1);
            event_count_ByP = sum(allEventsTable.clusterByRoiPrecantage ~= 1);
        else
            roiActivityPeakSize = ['cluster', num2str(i_cluster)];
            
            event_count_ByH = sum(allEventsTable.clusterByH == i_cluster);
            event_count_ByP = sum(allEventsTable.clusterByRoiPrecantage == i_cluster);
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
          
           case 'WindoEventToPeakCov'
               [roiActivityDistanceMatrixByH, roiActivityDistanceMatrixByP] = calcROIDistanceInActivity_WindowEventCov_V3(roiActivity_comb, roiActivityNames, selectedROI, allEventsTable, 'ToPeak', i_cluster);
            
               plotTreeByROIAverageActivityWithCluster(gRoi, outputpathCurr, roiActivity_comb, roiActivityNames, selectedROI, allEventsTable, 'ToPeak', i_cluster)           
       end
       
       saveActivityDistanceForHS(roiActivityDistanceMatrixByH, outputpathCurr, roiActivityNames, colorMatrix1, colorMatrix2);
       
       if i_cluster ~= -1
            fileNameD_ByH = plotTreeAndActivityDendogram(outputpathCurr,  'ByH', roiActivityDistanceMatrixByH, selectedROI, roiLinkage,  roiSortedByCluster, false);
            replace(currentResultsSlideByH_Dendogram.Children(i_cluster + 2), Picture([fileNameD_ByH '.tif'])); 
            
            fileNameD_ByP = plotTreeAndActivityDendogram(outputpathCurr, 'ByP', roiActivityDistanceMatrixByP, selectedROI, roiLinkage,  roiSortedByCluster, false);
            replace(currentResultsSlideByP_Dendogram.Children(i_cluster + 2), Picture([fileNameD_ByP '.tif']));       
       end    
       
       index_presentaionByH = plotResultesByClusterType(false, event_count_ByH, currentResultsSlideByH, currentResultsSlideByH_s, roiActivityDistanceMatrixByH, 'ByH', selectedROI, roiSortedByCluster, outputpathCurr, roiActivityDistanceFunction,...
           roiActivityPeakSize, gRoi, roiTreeDistanceMatrix, selectedROISplitDepth3, selectedROISplitDepth1, index_presentaionByH, selectedROITable, i_cluster, index_apical);
      
       index_presentaionByP = plotResultesByClusterType(false, event_count_ByP, currentResultsSlideByP, currentResultsSlideByP_s, roiActivityDistanceMatrixByP, 'ByP', selectedROI, roiSortedByCluster, outputpathCurr, roiActivityDistanceFunction,...
           roiActivityPeakSize, gRoi, roiTreeDistanceMatrix, selectedROISplitDepth3, selectedROISplitDepth1, index_presentaionByP, selectedROITable, i_cluster, index_apical);       
      
       fclose('all');
       close all;
    end  
    
    replace(currentResultsSlideSt.Children(1), Picture([outputpath '\GraphWithROI.tif']));       
    replace(currentResultsSlideSt.Children(2), Picture([outputpath '\DistMatrixROIStructure.tif']));       

    add(currentResultsSlideByH.Children(end), Paragraph('Cluster By Pks'));
    add(currentResultsSlideByP.Children(end), Paragraph('Cluster By Percentage'));
    add(currentResultsSlideByH_s.Children(end), Paragraph('Cluster By Pks'));
    add(currentResultsSlideByP_s.Children(end), Paragraph('Cluster By Percentage'));
    
    add(currentResultsSlideByH_Dendogram.Children(1), Paragraph('Cluster By Pks'));
    add(currentResultsSlideByP_Dendogram.Children(1), Paragraph('Cluster By Percentage'));
    
    close(ppt);
    
    close all;
end
 
function index_presentaion = plotResultesByClusterType(isFlipMap, event_count, currentResultsSlide, currentResultsSlide_s, roiActivityDistanceMatrix, clusterType, selectedROI, roiSortedByCluster, outputpathCurr, roiActivityDistanceFunction, roiActivityPeakSize, gRoi, roiTreeDistanceMatrix, selectedROISplitDepth3, selectedROISplitDepth1, index_presentaion, selectedROITable, i_cluster, index_apical)
        import mlreportgen.ppt.*
    
        figDist = figure;
        hold on;
        title({'ROI Activity Distance'});
        xticks(1:length(selectedROI));
        yticks(1:length(selectedROI));
        m = imagesc(roiActivityDistanceMatrix(roiSortedByCluster, roiSortedByCluster));
        colorbar
        cmap = jet();
        
        if isFlipMap
            cmap = flipud(cmap);
        end
        
        colormap(cmap);
        
        set(m,'AlphaData',~isnan(roiActivityDistanceMatrix(roiSortedByCluster, roiSortedByCluster)))
        
        xticklabels(selectedROI(roiSortedByCluster));
        xtickangle(90);
        yticklabels(selectedROI(roiSortedByCluster));
        picNameFile = [outputpathCurr, '\' , clusterType, '\DistMatrixActivity_', roiActivityDistanceFunction, '_eventsSize', roiActivityPeakSize];
        mysave(figDist, picNameFile);  

        if size(find(~isnan(roiActivityDistanceMatrix), 1), 1) > 1
        
            removeIndex = [];
            test = 1 - abs(roiActivityDistanceMatrix);
            for i = 1: size(test, 1)
                if (isnan(test(i, i)))
                    removeIndex = [removeIndex, i];
                end

                test(i, i) = 0;
            end

            test(removeIndex, :) = [];
            test(:, removeIndex) = [];

            y = squareform(test);
            l = linkage(y, 'single');

            figDendrogram = figure;
            leafOrder = optimalleaforder(l,y);
            labI = 1:length(selectedROI);
            labI(removeIndex) = [];
            dendrogram(l, 'Labels', selectedROI(labI), 'Reorder', leafOrder);
            xtickangle(90);

            mysave(figDendrogram, [outputpathCurr, '\' , clusterType, '\DendrogramROIActivity']);
        end
        
        pictureNames = plotROIDistMatrixTreeVSActivity(event_count, gRoi, [outputpathCurr, '\' , clusterType],selectedROISplitDepth1, selectedROISplitDepth1, roiTreeDistanceMatrix, roiActivityDistanceMatrix, true, roiActivityDistanceFunction, roiActivityPeakSize, selectedROI, index_apical);

        pictureNames_s = plotROIDistMatrixTreeVSActivity(event_count, gRoi, [outputpathCurr, '\' , clusterType],selectedROISplitDepth1, selectedROISplitDepth3, roiTreeDistanceMatrix, roiActivityDistanceMatrix, false, roiActivityDistanceFunction, roiActivityPeakSize, selectedROI, index_apical);
        
        plotRoiDistMatrixTreeVsActivityForDepthCompare(gRoi, [outputpathCurr, '\' , clusterType],  selectedROITable, roiTreeDistanceMatrix, roiActivityDistanceMatrix, roiActivityDistanceFunction, roiActivityPeakSize);
        
        if i_cluster ~= -1
            replace(currentResultsSlide.Children(index_presentaion), Picture([picNameFile '.tif']));       
            replace(currentResultsSlide.Children(index_presentaion + 1), Picture([pictureNames{1} '.tif']));
            replace(currentResultsSlide_s.Children(index_presentaion), Picture([picNameFile '.tif']));       
            replace(currentResultsSlide_s.Children(index_presentaion + 1), Picture([pictureNames_s{1} '.tif']));
            
            index_presentaion = index_presentaion + 2;
        end
        
        if i_cluster == 0      
            replace(currentResultsSlide.Children(end - 1), Picture([pictureNames{2} '.tif']));
            replace(currentResultsSlide_s.Children(end - 1), Picture([pictureNames_s{2} '.tif']));
        end
        
end

function saveROIBranchingIndexAsLabel(eventWin, gRoi, selectedROISplitDepth1, selectedROI, outputpath, depthNumber, allEventsTable, roiActivity_comb, tr_frame_count)
    classesMDepth1 = unique(selectedROISplitDepth1);
    eventStr = [];
    selectedROISplitDepthToSave1 = selectedROISplitDepth1;
    for indexC = 1:length(classesMDepth1)
        if classesMDepth1(indexC) == -1
            eventStr = [eventStr 'ND' '_'];
            labelsLUT(indexC) = {'ND'};
        
        else
            eventStr = [eventStr gRoi.Nodes(classesMDepth1(indexC),:).Name{1} '_'];
            labelsLUT(indexC) = gRoi.Nodes(classesMDepth1(indexC),:).Name(1);
        end
        
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
        
        if sum(event_curr_loc < 0) > 0
            event_curr_loc = 1:(eventWin*2);
        end
        
        if sum(event_curr_loc > size(roiActivity_comb, 1)) > 0
            event_curr_loc = (size(roiActivity_comb, 1) - (eventWin*2)):size(roiActivity_comb, 1);
        end
        
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

function saveDataForHS(allEventsTable, roiActivity, roiActivity_comb, roiActivityNames, outputpath, colorMatrix1, colorMatrix2)

    classes = unique(allEventsTable.clusterByH);
    classes(end + 1) = 0;
     
     for i = 1:length(classes)
        nameC = ['cluster_', num2str(classes(i))];
        resultsData.(nameC) = ones(size(roiActivity)) .* -100;
        resultsData_comb.(nameC) = ones(size(roiActivity_comb)) .* -100;        
     end
     
     for index = 1:size(allEventsTable, 1)
         nameC = ['cluster_', num2str(allEventsTable.clusterByH(index))];
        
         resultsData.(nameC)(allEventsTable.start(index):(min(allEventsTable.event_end(index), allEventsTable.pks(index) + 20)), :) = ...
             roiActivity(allEventsTable.start(index):(min(allEventsTable.event_end(index), allEventsTable.pks(index) + 20)), :);
         resultsData.('cluster_0')(allEventsTable.start(index):(min(allEventsTable.event_end(index), allEventsTable.pks(index) + 20)), :) = ...
             roiActivity(allEventsTable.start(index):(min(allEventsTable.event_end(index), allEventsTable.pks(index) + 20)), :);
        
         resultsData_comb.(nameC)(allEventsTable.start(index):(min(allEventsTable.event_end(index), allEventsTable.pks(index) + 20)), :) = ...
             roiActivity_comb(allEventsTable.start(index):(min(allEventsTable.event_end(index), allEventsTable.pks(index) + 20)), :);
         resultsData_comb.('cluster_0')(allEventsTable.start(index):(min(allEventsTable.event_end(index), allEventsTable.pks(index) + 20)), :) = ...
             roiActivity_comb(allEventsTable.start(index):(min(allEventsTable.event_end(index), allEventsTable.pks(index) + 20)), :);
     end
     
     
     
     for i = 1:length(classes)
        nameC = ['cluster_', num2str(classes(i))];
        tmp = resultsData.(nameC);
        tmp(tmp(:, 1) == -100, :) = [];
        save([outputpath, '\roiActivityRaw_ByEvents_' num2str(classes(i)) '.mat'], 'tmp', 'roiActivityNames', 'colorMatrix1', 'colorMatrix2')
        
        tmp = [];
        tmp = resultsData_comb.(nameC);
        tmp(tmp(:, 1) == -100, :) = [];
        save([outputpath, '\roiActivityComb_ByEvents_' num2str(classes(i)) '.mat'], 'tmp', 'roiActivityNames', 'colorMatrix1', 'colorMatrix2')     
     end
 
end