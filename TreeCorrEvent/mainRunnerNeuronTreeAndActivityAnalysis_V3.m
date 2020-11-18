function mainRunnerNeuronTreeAndActivityAnalysis_V3(globalParameters) 
    
    neuronTreePathSWC = fullfile(globalParameters.MainFolder, 'Shay', globalParameters.AnimalName, globalParameters.DateAnimal, globalParameters.swcFile);
    
    activityByCSV = false;
    neuronActiityPathCSV = '';
    neuronActivityPathTPA = fullfile(globalParameters.MainFolder, globalParameters.AnimalName, globalParameters.DateAnimal);
    
    outputpath = globalParameters.outputpath;
   
    behaveFileTreadMillPath = fullfile(globalParameters.MainFolder, 'Shay' , globalParameters.AnimalName, globalParameters.DateAnimal, globalParameters.treadmilFile);
    
    doComboForCloseRoi = false;
    
    eventsDetectionFolder = fullfile(globalParameters.MainFolder, 'Shay' , globalParameters.AnimalName, ...
    globalParameters.DateAnimal, 'Analysis', globalParameters.neuronNumberName, 'Structural_VS_Functional',...
    globalParameters.RunnerDate,globalParameters.RunnerNumber, 'EventsDetection');
    mkdir(eventsDetectionFolder);
    
    
    centralityFolder = fullfile(globalParameters.outputpath, 'centrality');
    mkdir(centralityFolder);

    sprintf('Animal :%s, Date :%s, Neuron :%s, Behave :%s, Analysis :%s', globalParameters.AnimalName, globalParameters.DateAnimal, globalParameters.neuronNumberName, globalParameters.behaveType, globalParameters.analysisType)
    
%     load Tree Data
    sprintf('Structure Plot Results')
       
    [gRoi, rootNodeID, selectedROITable] = loadSwcFile(neuronTreePathSWC, outputpath, doComboForCloseRoi);
    
    for i = 1:length(globalParameters.excludeRoi)
        ex_results = contains(selectedROITable.Name, sprintf('roi%05d', globalParameters.excludeRoi(i)));
        
        if sum(ex_results) == 1
            selectedROITable(ex_results, :) = [];
        end
    end
    
    selectedROI = selectedROITable.Name;
     
    index_apical = zeros(1, length(globalParameters.apical_roi));   
    for i = 1:length(globalParameters.apical_roi)
        ex_results = find(contains(selectedROITable.Name, sprintf('roi%05d', globalParameters.apical_roi(i))));
        
        if ~isempty(ex_results)
            index_apical(i) = ex_results;
        end
    end
 
    
    roi_count = length(selectedROI);
    aV = ones(1, roi_count)*globalParameters.aVForAll;
    
    if ~isempty(globalParameters.aVFix.location)
        aV(globalParameters.aVFix.location) = globalParameters.aVFix.values;
    end
    
    sigmaChangeValue = zeros(1, roi_count);

    
%     Trial Number To plot with Tree

    save([outputpath '\runParametes'],'aV', 'roi_count', 'sigmaChangeValue', 'globalParameters');

    fid=fopen([outputpath '\Parametes.txt'],'w');
    fprintf(fid, 'hyperbolicDistMatrixLocation : %s r\n', globalParameters.hyperbolicDistMatrixLocation);    
    fprintf(fid, 'roiTreeDistanceFunction : %s r\n', globalParameters.roiTreeDistanceFunction);
    fprintf(fid, 'roiActivityDistanceFunction : %s r\n', globalParameters.roiActivityDistanceFunction);    
    fprintf(fid, 'clusterCount : %d r\n', globalParameters.clusterCount);
    fprintf(fid, 'eventWin : %d r\n', globalParameters.eventWin);
    
    for in = 1:length(globalParameters.runByEvent)
        fprintf(fid, 'event behave : %s r\n', globalParameters.runByEvent{in});
    end
    
    fprintf(fid, 'event behave lag : %d - %d r\n', globalParameters.runBehaveLag(1), globalParameters.runBehaveLag(2));
    fclose(fid);
        
    
    if (activityByCSV)
        %     load roi activity file
        [roiActivity, roiActivityNames] = loadActivityFile(neuronActiityPathCSV, selectedROI);
        tr_frame_count = [];
    else
        [roiActivity, roiActivityNames, tr_frame_count] = loadActivityFileFromTPA(neuronActivityPathTPA, selectedROI, outputpath);
    end
      
%     Behave TreadMillData
      
   if ~strcmp(globalParameters.hyperbolicDistMatrixLocation, "") 
        load(globalParameters.hyperbolicDistMatrixLocation);
   end
   
   %     Calc branching
    selectedROISplitDepth1 = ones(length(selectedROI), 1) * -1;
    selectedROISplitDepth1 = getSelectedROISplitBranchID(gRoi, globalParameters.firstDepthCompare, selectedROISplitDepth1, selectedROI);   
  
    selectedROISplitDepth3 = ones(length(selectedROI), 1) * -1;
    selectedROISplitDepth3 = getSelectedROISplitBranchID(gRoi, globalParameters.secDepthCompare, selectedROISplitDepth3, selectedROI);   

    
%     Calc Distance Matrix for ROI in Tree
    switch(globalParameters.roiTreeDistanceFunction)
        case 'Euclidean'
           [roiTreeDistanceMatrix, roiSortedByCluster, roiLinkage] = calcROIDistanceInTree_Euclidean(gRoi, selectedROI, outputpath, selectedROISplitDepth1); 
        case 'ShortestPath'
           [roiTreeDistanceMatrix, roiSortedByCluster, roiLinkage] = calcROIDistanceInTree_ShortestPath(gRoi, selectedROITable, outputpath, selectedROISplitDepth1);
        case 'HyperbolicDist_L'
           [roiTreeDistanceMatrix, roiSortedByCluster, roiLinkage] = calcROIDistanceInTree_Hyperbolic(gRoi, selectedROITable, outputpath, loranzDistMat, selectedROISplitDepth1);
        case 'HyperbolicDist_P'
           [roiTreeDistanceMatrix, roiSortedByCluster, roiLinkage] = calcROIDistanceInTree_Hyperbolic(gRoi, selectedROITable, outputpath, poincareDistMat, selectedROISplitDepth1);
    end
        
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
    
    save([outputpath, '\roiActivityRawData.mat'], 'roiActivity', 'roiActivityNames', 'colorMatrix1', 'colorMatrix2', 'selectedROISplitDepth1', 'selectedROISplitDepth3');
    saveGraphForHS(gRoi, rootNodeID, outputpath, colorMatrix1, colorMatrix2, selectedROITable);
    
%     Calc Activity Events Window
    snapnow;
    close all;

    if isfile([eventsDetectionFolder, '\roiActivity_comb.mat'])
        load([eventsDetectionFolder, '\roiActivity_comb.mat'], 'allEventsTable', 'roiActivity_comb'); 
        
        if globalParameters.reRunClusterData
        %     -----------------------------------------------------------------------------------------------------

            SpikeTrainClusterSecByH = getClusterForActivity(allEventsTable.H, globalParameters.clusterCount);
            printClusterResults(SpikeTrainClusterSecByH, globalParameters.clusterCount, mean(roiActivity_comb, 2), allEventsTable.pks, allEventsTable.start, allEventsTable.event_end, allEventsTable.H, outputpath, 'ByH')

        %   -----------------------------------------------------------------------------------------------------  

            SpikeTrainClusterSecByPrecantage = getClusterForActivity(allEventsTable.roiPrecantage, globalParameters.clusterCount);
            printClusterResults(SpikeTrainClusterSecByPrecantage, globalParameters.clusterCount, mean(roiActivity_comb, 2), allEventsTable.pks, allEventsTable.start, allEventsTable.event_end, allEventsTable.H, outputpath, 'ByP')

        %     -----------------------------------------------------------------------------------------------------

            allEventsTable.clusterByRoiPrecantage = SpikeTrainClusterSecByPrecantage';
            allEventsTable.clusterByH = SpikeTrainClusterSecByH';
        end
        
    elseif all(strcmp(globalParameters.runByEvent, 'non'))
        [allEventsTable, roiActivity_comb] = calcActivityEventsWindowsAndPeaks_V3(roiActivity, eventsDetectionFolder, globalParameters.clusterCount, globalParameters.ImageSamplingRate, tr_frame_count, aV, roiActivityNames, sigmaChangeValue, globalParameters.mean_aV);
        
        save([eventsDetectionFolder, '\roiActivity_comb.mat'], 'allEventsTable', 'roiActivity_comb');
    else
        error('first run all with no events')
    end    
    
    for i_e = 1:size(allEventsTable, 1)
        tr_index = floor(allEventsTable.start(i_e) ./ tr_frame_count) + 1;
        allEventsTable.tr_index(i_e) = tr_index;
    end
    
    if globalParameters.isHandreach 
        [BehaveDataAll, NAMES, trials_label] = loadBDAFile(neuronActivityPathTPA, globalParameters.BehavioralSamplingRate, globalParameters.ImageSamplingRate, tr_frame_count, globalParameters.behavioralDelay, globalParameters.toneTime);
        
        if ~strcmp(globalParameters.excludeTrailsByEventCount.Name, 'non')
           behaveCountForCa = BehaveDataAll.(['last', globalParameters.excludeTrailsByEventCount.Name]).count(allEventsTable.tr_index);
          
           fig = figure;
           hold on;

           subplot(2, 1, 1);
           h_ByT = histogram(BehaveDataAll.(['last', globalParameters.excludeTrailsByEventCount.Name]).count); 
           title({['Event ' globalParameters.excludeTrailsByEventCount.Name], 'Histogram By Trial'});

           subplot(2, 1, 2);
           h_ByP = histogram(behaveCountForCa);
           title({['Event ' globalParameters.excludeTrailsByEventCount.Name], 'Histogram By Ca Events'});

           mysave(fig, [outputpath, '\HistogramEventsCount_' globalParameters.excludeTrailsByEventCount.Name]);  
            
            allEventsTable(behaveCountForCa < globalParameters.excludeTrailsByEventCount.countRange(1) | ...
                behaveCountForCa > globalParameters.excludeTrailsByEventCount.countRange(2),:) = [];
        end
       
       if all(~strcmp(globalParameters.runByEvent, 'non'))          
           runByEventTemp = {};
           runBehaveLagTemp = [];
           for i_run = 1:length(globalParameters.runByEvent)
                if contains(globalParameters.runByEvent(i_run), '_all')
                    runByEvent_fix = replace(globalParameters.runByEvent{i_run}, '_all', '');
                    newEvents = NAMES(contains(NAMES, runByEvent_fix)&(~contains(NAMES, ['last' runByEvent_fix]))&(~contains(NAMES, ['firstTone' runByEvent_fix])));
                    runByEventTemp((end + 1 ): (end + length(newEvents))) = newEvents;
                    runBehaveLagTemp((end + 1 ): (end + length(newEvents)), :) = [ones(length(newEvents), 1) * globalParameters.runBehaveLag(i_run, 1), ones(length(newEvents), 1) * globalParameters.runBehaveLag(i_run, 2)];
                else
                    runByEventTemp(end+1) = globalParameters.runByEvent(i_run);
                    runBehaveLagTemp(end + 1, :) = globalParameters.runBehaveLag(i_run, :);
                end
           end
           
           currentEventLoc = zeros(length(runByEventTemp),1);
          
           for in = 1:length(runByEventTemp)
              currentEventLoc(in) = find(strcmp(NAMES, runByEventTemp{in}));
              
              if ~strcmp(globalParameters.FirstEventAfter , 'non')
                   [BehaveDataAll.([NAMES{currentEventLoc(in)},'_', globalParameters.FirstEventAfter{1}]).startTiming,...
                       BehaveDataAll.([NAMES{currentEventLoc(in)},'_', globalParameters.FirstEventAfter{1}]).endTiming] = findFirstEventsAfter(BehaveDataAll, NAMES, NAMES{currentEventLoc(in)}, globalParameters.FirstEventAfter{1});
                   NAMES(end + 1) = {[NAMES{currentEventLoc(in)},'_', globalParameters.FirstEventAfter{1}]};
                  
                   currentEventLoc(in) = length(NAMES); 
                   runByEventTemp(in) =  NAMES(end);
              end
              
              if globalParameters.doBehaveAlignedPlot
                  if strcmp(globalParameters.EventTiming, 'start')
                      plotEventCaForBehaveDataHandReach(BehaveDataAll.(NAMES{currentEventLoc(in)}).startTiming, tr_frame_count, allEventsTable, globalParameters.clusterCount, outputpath, NAMES{currentEventLoc(in)}, trials_label, globalParameters.split_trialsLabel)           
                  else
                      plotEventCaForBehaveDataHandReach(BehaveDataAll.(NAMES{currentEventLoc(in)}).endTiming, tr_frame_count, allEventsTable, globalParameters.clusterCount, outputpath, NAMES{currentEventLoc(in)}, trials_label, globalParameters.split_trialsLabel)           
                  end
              end
           end
           
           eventsIndexTodelete = zeros(1, size(allEventsTable, 1));
           for i_e = 1:size(allEventsTable, 1)
               if globalParameters.split_trialsLabel ~= 0 & trials_label(allEventsTable.tr_index(i_e)) ~= globalParameters.split_trialsLabel
                    eventsIndexTodelete(i_e) = 1;
                    continue;
               end
               
               alignedLocation = zeros(1, length(runByEventTemp));
               aligned_start = zeros(1, length(runByEventTemp));
               
               checkEvent = zeros(1, length(runByEventTemp));
               for in = 1:length(runByEventTemp) 
                   if strcmp(globalParameters.EventTiming, 'start')
                       alignedLocation(in) = BehaveDataAll.(NAMES{currentEventLoc(in)}).startTiming(allEventsTable.tr_index(i_e));
                   else
                       alignedLocation(in) = BehaveDataAll.(NAMES{currentEventLoc(in)}).endTiming(allEventsTable.tr_index(i_e));
                   end
                   
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
               
                if globalParameters.do_eventsBetween
                    if ~(all(checkEvent == 0))
                       eventsIndexTodelete(i_e) = 1;
                    end
                else
                    if all(checkEvent == 1)
                        eventsIndexTodelete(i_e) = 1;
                    end
                end
           end

           
           if globalParameters.runByNegEvent
               allEventsTable(eventsIndexTodelete == 0, :) = [];
           else
               allEventsTable(eventsIndexTodelete == 1, :) = [];
           end           
       end
    else
        [speedBehave, accelBehave, ~, ~, BehaveDataTreadmil] = treadmilBehave(behaveFileTreadMillPath, globalParameters.behaveFrameRateTM, globalParameters.ImageSamplingRate);
        
        if all(~strcmp(globalParameters.runByEvent, 'non'))
           eventsIndexTodelete = zeros(1, size(allEventsTable, 1));
           
           for i_e = 1:size(allEventsTable, 1)
               
               check_runByEvents = zeros(size(globalParameters.runByEvent));
               for ind = 1:length(globalParameters.runByEvent)
                   if isempty(find(allEventsTable.start(i_e) == BehaveDataTreadmil.(globalParameters.runByEvent{ind}), 1))
                       check_runByEvents(ind) = 1;
                   end
               end
               
               if all(check_runByEvents == 1)
                   eventsIndexTodelete(i_e) = 1;               
               end
               
           end
           
           allEventsTable(eventsIndexTodelete == 1, :) = [];
        else
            plotBaseTreadMillActivity(speedBehave, accelBehave, roiActivity, outputpath, selectedROI, allEventsTable, globalParameters.clusterCount); 
            plotEventsCaForBehaveDataTreadMil(speedBehave, accelBehave, allEventsTable, globalParameters.clusterCount, outputpath, 300, BehaveDataTreadmil);
            
            save([outputpath, 'BehaveTreadMilResults'], 'BehaveDataTreadmil');
        end
        
    end
    
    writetable(allEventsTable,[outputpath '\eventsCaSummary.csv']);
    
    snapnow;
    close all;

    plotEventsHistogram(allEventsTable, outputpath, globalParameters.clusterCount);
    
    if isempty(allEventsTable)
        snapnow;
        close all;
        fclose('all');
        return;
    end
    
    roiActivity_comb = double(roiActivity_comb);
    
%     for HS Activity! with cluster
    sprintf('Pca according to cluster by H')
    saveDataForHS(gRoi, allEventsTable, 'ByH', roiActivity, roiActivity_comb, roiActivityNames, outputpath, colorMatrix1, colorMatrix2, classesD1, classesD2, selectedROISplitDepth1, selectedROISplitDepth3);

    snapnow;
    close all;
    
    sprintf('Pca according to cluster by P')
    saveDataForHS(gRoi, allEventsTable, 'ByP', roiActivity, roiActivity_comb, roiActivityNames, outputpath, colorMatrix1, colorMatrix2, classesD1, classesD2, selectedROISplitDepth1, selectedROISplitDepth3);
    
%     Plot Tree And Trial Activity in the ROI    
%     totalTrialTime = globalParameters.ImageSamplingRate * globalParameters.time_sec_of_trial;
%     plotTreeAndActivityForTrial(globalParameters.trialNumber, totalTrialTime, roiSortedByCluster, roiActivity, roiActivityNames, selectedROI, outputpath, locationPeaks, windowFULL, roiLinkage);
%     
    snapnow;
    close all;

    sprintf('Ca Events Analysis according to subtree"s , mean activity')
    
    analysisEventsActivityForROI(gRoi, allEventsTable, selectedROI, selectedROISplitDepth1, outputpath, ['Depth1' globalParameters.runByEvent{:}], globalParameters.clusterCount);
    analysisEventsActivityForROI(gRoi, allEventsTable, selectedROI, selectedROISplitDepth3, outputpath, ['Depth2' globalParameters.runByEvent{:}], globalParameters.clusterCount);
    
    snapnow;
    close all;

    plotEventsSperation(allEventsTable, roiActivity_comb, selectedROI, selectedROISplitDepth1, outputpath, gRoi, roiSortedByCluster, roiTreeDistanceMatrix, index_apical);
        
    import mlreportgen.ppt.*
    ppt = Presentation([outputpath '\AnalysisResultsPresentation'], 'AnalysisP.potm');
    open(ppt);
    currentResultsSlideSt = add(ppt, 'Analysis_St');
    currentResultsSlideHist = add(ppt, 'HistogramP');
    
    currentResultsSlideByH = add(ppt, 'AnalysisP');
    currentResultsSlideByP = add(ppt, 'AnalysisP');
    
    currentResultsSlideByH_s = add(ppt, 'AnalysisP');
    currentResultsSlideByP_s = add(ppt, 'AnalysisP');
    
    currentResultsSlideByH_Dendogram = add(ppt, 'AnalysisD');
    currentResultsSlideByP_Dendogram = add(ppt, 'AnalysisD');
    
    currentResultsSlideByH_no1 = add(ppt, 'AnalysisNo1H');
    currentResultsSlideByP_no1 = add(ppt, 'AnalysisNo1P');
    
    replace(currentResultsSlideSt.Children(1), Picture([outputpath '\GraphWithROI.tif']));       
    replace(currentResultsSlideSt.Children(2), Picture([outputpath '\DistMatrixROIStructure.tif']));       
    replace(currentResultsSlideSt.Children(end), Paragraph([globalParameters.AnimalName, ' ', globalParameters.DateAnimal, ' ', globalParameters.neuronNumberName]));       
            
    replace(currentResultsSlideHist.Children(1), Picture([outputpath '\HistogramEventsCluster.tif']));       
    
    index_presentaionByH = 1;
    index_presentaionByP = 1;       
    
    for i_cluster = -1:globalParameters.clusterCount
        if i_cluster == 0
            roiActivityPeakSize = 'All';
            event_count_ByH = size(allEventsTable, 1);
            event_count_ByP = size(allEventsTable, 1);
        elseif i_cluster == -1
            roiActivityPeakSize = 'All_ExcludeBigEvents';
            
            event_count_ByH = sum(allEventsTable.clusterByH ~= globalParameters.clusterCount);
            event_count_ByP = sum(allEventsTable.clusterByRoiPrecantage ~= globalParameters.clusterCount);
        else
            roiActivityPeakSize = ['cluster', num2str(i_cluster)];
            
            event_count_ByH = sum(allEventsTable.clusterByH == i_cluster);
            event_count_ByP = sum(allEventsTable.clusterByRoiPrecantage == i_cluster);
        end
        
        outputpathCurr = [outputpath, '\', roiActivityPeakSize];
        
        sprintf('Ca Events, %s', roiActivityPeakSize)
            
           
    %     Calc Distance Matrix for ROI in Activity
       switch(globalParameters.roiActivityDistanceFunction)
           case 'WindowEventFULLPearson'
               [roiActivityDistanceMatrixByH, roiActivityDistanceMatrixByP] = calcROIDistanceInActivity_WindowEventPearson_V3(roiActivity_comb, roiActivityNames, selectedROI, allEventsTable, 'FULL', i_cluster, globalParameters.clusterCount);
                
               plotTreeByROIAverageActivityWithCluster(gRoi, outputpathCurr, roiActivity_comb, roiActivityNames, selectedROI, allEventsTable, 'FULL', i_cluster)
              
           case 'WindoEventToPeakPearson'
               [roiActivityDistanceMatrixByH, roiActivityDistanceMatrixByP] = calcROIDistanceInActivity_WindowEventPearson_V3(roiActivity_comb, roiActivityNames, selectedROI, allEventsTable, 'ToPeak', i_cluster, globalParameters.clusterCount);

               plotTreeByROIAverageActivityWithCluster(gRoi, outputpathCurr, roiActivity_comb, roiActivityNames, selectedROI, allEventsTable, 'ToPeak', i_cluster)
               
           case 'PeaksPearson'
               [roiActivityDistanceMatrixByH, roiActivityDistanceMatrixByP] = calcROIDistanceInActivity_WindowEventPearson_V3(roiActivity_comb, roiActivityNames, selectedROI, allEventsTable, 'Peaks', i_cluster, globalParameters.clusterCount);
            
               plotTreeByROIAverageActivityWithCluster(gRoi, outputpathCurr, roiActivity_comb, roiActivityNames, selectedROI, allEventsTable, 'Peaks', i_cluster)
          
           case 'WindoEventToPeakCov'
               [roiActivityDistanceMatrixByH, roiActivityDistanceMatrixByP] = calcROIDistanceInActivity_WindowEventCov_V3(roiActivity_comb, roiActivityNames, selectedROI, allEventsTable, 'ToPeak', i_cluster, globalParameters.clusterCount);
            
               plotTreeByROIAverageActivityWithCluster(gRoi, outputpathCurr, roiActivity_comb, roiActivityNames, selectedROI, allEventsTable, 'ToPeak', i_cluster)           
           case 'WindoEventToPeakSperman'
               [roiActivityDistanceMatrixByH, roiActivityDistanceMatrixByP] = calcROIDistanceInActivity_WindowEventSperman_V3(roiActivity_comb, roiActivityNames, selectedROI, allEventsTable, 'ToPeak', i_cluster, globalParameters.clusterCount);
            
               plotTreeByROIAverageActivityWithCluster(gRoi, outputpathCurr, roiActivity_comb, roiActivityNames, selectedROI, allEventsTable, 'ToPeak', i_cluster)           
       end
       
       saveActivityDistanceForHS(roiActivityDistanceMatrixByH, outputpathCurr, roiActivityNames, colorMatrix1, colorMatrix2);
       
       if i_cluster ~= -1
           sprintf('Cluster By H')
       
            fileNameD_ByH_f = plotTreeAndActivityDendogram(outputpathCurr,  'ByH', roiActivityDistanceMatrixByH, selectedROI,...
                roiLinkage,  roiSortedByCluster, false, false);
            replace(currentResultsSlideByH_Dendogram.Children(i_cluster + 2), Picture([fileNameD_ByH_f '.tif'])); 
            
            fileNameD_ByH_t = plotTreeAndActivityDendogram(outputpathCurr,  'ByH', roiActivityDistanceMatrixByH, selectedROI,...
                roiLinkage,  roiSortedByCluster, false, true);
            replace(currentResultsSlideByH_Dendogram.Children(i_cluster + 7), Picture([fileNameD_ByH_t '.tif'])); 
            
            snapnow;
            close all;
       
            sprintf('Cluster By P')
       
            fileNameD_ByP_f = plotTreeAndActivityDendogram(outputpathCurr, 'ByP', roiActivityDistanceMatrixByP, selectedROI, roiLinkage,...
                roiSortedByCluster, false, false);
            replace(currentResultsSlideByP_Dendogram.Children(i_cluster + 2), Picture([fileNameD_ByP_f '.tif']));  
            
            fileNameD_ByP_t = plotTreeAndActivityDendogram(outputpathCurr, 'ByP', roiActivityDistanceMatrixByP, selectedROI, roiLinkage,...
                roiSortedByCluster, false, true);
            replace(currentResultsSlideByP_Dendogram.Children(i_cluster + 7), Picture([fileNameD_ByP_t '.tif']));  
       else
           sprintf('Cluster By H')
       
           fileNameD_ByH_f = plotTreeAndActivityDendogram(outputpathCurr,  'ByH', roiActivityDistanceMatrixByH, selectedROI,...
                roiLinkage,  roiSortedByCluster, false, false);
            replace(currentResultsSlideByH_no1.Children(3), Picture([fileNameD_ByH_f '.tif'])); 
            
           fileNameD_ByH_t = plotTreeAndActivityDendogram(outputpathCurr,  'ByH', roiActivityDistanceMatrixByH, selectedROI,...
                roiLinkage,  roiSortedByCluster, false, true);
            replace(currentResultsSlideByH_no1.Children(4), Picture([fileNameD_ByH_t '.tif'])); 
            
            snapnow;
            close all;
       
            sprintf('Cluster By P')
       
             fileNameD_ByP_f = plotTreeAndActivityDendogram(outputpathCurr, 'ByP', roiActivityDistanceMatrixByP, selectedROI, roiLinkage,...
                roiSortedByCluster, false, false);
            replace(currentResultsSlideByP_no1.Children(3), Picture([fileNameD_ByP_f '.tif']));  
            
            fileNameD_ByP_t = plotTreeAndActivityDendogram(outputpathCurr, 'ByP', roiActivityDistanceMatrixByP, selectedROI, roiLinkage,...
                roiSortedByCluster, false, true);
            replace(currentResultsSlideByP_no1.Children(4), Picture([fileNameD_ByP_t '.tif']));  
       end
       snapnow;
       close all;
       
       sprintf('Cluster By H')
       index_presentaionByH = plotResultesByClusterType(true, false, event_count_ByH, currentResultsSlideByH, currentResultsSlideByH_s, roiActivityDistanceMatrixByH, 'ByH', selectedROI, roiSortedByCluster, outputpathCurr, globalParameters.roiActivityDistanceFunction,...
           roiActivityPeakSize, gRoi, roiTreeDistanceMatrix, selectedROISplitDepth3, selectedROISplitDepth1, index_presentaionByH, selectedROITable, i_cluster, index_apical, currentResultsSlideByH_no1);
        
       snapnow;
       close all;
       
       sprintf('Cluster By P')
       index_presentaionByP = plotResultesByClusterType(true, false, event_count_ByP, currentResultsSlideByP, currentResultsSlideByP_s, roiActivityDistanceMatrixByP, 'ByP', selectedROI, roiSortedByCluster, outputpathCurr, globalParameters.roiActivityDistanceFunction,...
           roiActivityPeakSize, gRoi, roiTreeDistanceMatrix, selectedROISplitDepth3, selectedROISplitDepth1, index_presentaionByP, selectedROITable, i_cluster, index_apical, currentResultsSlideByP_no1);       
       
       sprintf('centrality Analysis By H');
       plotCentralityForGraph(gRoi, roiActivityDistanceMatrixByH, selectedROI, fullfile(centralityFolder, roiActivityPeakSize, 'ByH'), true, selectedROISplitDepth1);

       sprintf('centrality Analysis By P');
       plotCentralityForGraph(gRoi, roiActivityDistanceMatrixByP, selectedROI, fullfile(centralityFolder, roiActivityPeakSize, 'ByP'), true, selectedROISplitDepth1);

       snapnow;
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
    
    snapnow;
    close(ppt);
    
    close all;
    fclose all;
    
end
 
function index_presentaion = plotResultesByClusterType(doPP, isFlipMap, event_count, currentResultsSlide, currentResultsSlide_s, roiActivityDistanceMatrix, clusterType, selectedROI, roiSortedByCluster, outputpathCurr, roiActivityDistanceFunction, roiActivityPeakSize, gRoi, roiTreeDistanceMatrix, selectedROISplitDepth3, selectedROISplitDepth1, index_presentaion, selectedROITable, i_cluster, index_apical, currentResultsSlide_no1)
        import mlreportgen.ppt.*
    
        figDist = figure;
        hold on;
        title({'ROI Activity Distance', ['events:', num2str(event_count)]});
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
                
        for index_roi = 1:length(selectedROI)
            labelsNames(index_roi) = {sprintf('roi%d', sscanf(selectedROI{index_roi}, 'roi%d'))};
        end
        
        xticklabels(labelsNames(roiSortedByCluster));
        xtickangle(90);
        yticklabels(labelsNames(roiSortedByCluster));
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
        
        pictureNames = plotROIDistMatrixTreeVSActivity(event_count, gRoi, [outputpathCurr, '\' , clusterType],selectedROISplitDepth1, selectedROISplitDepth1, roiTreeDistanceMatrix, roiActivityDistanceMatrix, true, roiActivityDistanceFunction, roiActivityPeakSize, selectedROI, index_apical, 'Correlation', clusterType);

        pictureNames_s = plotROIDistMatrixTreeVSActivity(event_count, gRoi, [outputpathCurr, '\' , clusterType],selectedROISplitDepth1, selectedROISplitDepth3, roiTreeDistanceMatrix, roiActivityDistanceMatrix, false, roiActivityDistanceFunction, roiActivityPeakSize, selectedROI, index_apical, 'Correlation', clusterType);
        
        plotRoiDistMatrixTreeVsActivityForDepthCompare(gRoi, [outputpathCurr, '\' , clusterType],  selectedROITable, roiTreeDistanceMatrix, roiActivityDistanceMatrix, roiActivityDistanceFunction, roiActivityPeakSize);
        
        if i_cluster ~= -1 && doPP
            replace(currentResultsSlide.Children(index_presentaion), Picture([picNameFile '.tif']));       
            replace(currentResultsSlide.Children(index_presentaion + 1), Picture([pictureNames{1} '.tif']));
            replace(currentResultsSlide_s.Children(index_presentaion), Picture([picNameFile '.tif']));       
            replace(currentResultsSlide_s.Children(index_presentaion + 1), Picture([pictureNames_s{1} '.tif']));
            
            index_presentaion = index_presentaion + 2;
        elseif  doPP
           replace(currentResultsSlide_no1.Children(1), Picture([picNameFile '.tif']));
           replace(currentResultsSlide_no1.Children(2), Picture([pictureNames{1} '.tif']));
        end
        
        if i_cluster == 0 && doPP
            replace(currentResultsSlide.Children(end - 1), Picture([pictureNames{2} '.tif']));
            replace(currentResultsSlide_s.Children(end - 1), Picture([pictureNames_s{2} '.tif']));
        end  
        
%         calcManelTest(activityMatrix, isPearson, distanceMatrix);
end

function saveDataForHS(gRoi, allEventsTable, clusterType, roiActivity, roiActivity_comb, roiActivityNames, outputpath, colorMatrix1, colorMatrix2, classesD1, classesD2, selectedROISplitDepth1, selectedROISplitDepth3)
    
    switch clusterType
        case 'ByH'
            clusterResults = allEventsTable.clusterByH;
        case 'ByP'
            clusterResults = allEventsTable.clusterByRoiPrecantage;
    end

    classes = unique(clusterResults);
    classes(end + 1) = 0;
     
     for i = 1:length(classes)
        nameC = ['cluster_', num2str(classes(i))];
        resultsData.(nameC) = nan(size(roiActivity));
        resultsData_comb.(nameC) = nan(size(roiActivity_comb));        
     end
     
     for index = 1:size(allEventsTable, 1)
         nameC = ['cluster_', num2str(clusterResults(index))];
        
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
        tmp(isnan(tmp(:, 1)), :) = [];
        save([outputpath, '\roiActivityRaw_' clusterType '_ByEvents_' num2str(classes(i)) '.mat'], 'tmp', 'roiActivityNames', 'colorMatrix1', 'colorMatrix2')
        
        tmp = [];
        tmp = resultsData_comb.(nameC);
        tmp(isnan(tmp(:, 1)), :) = [];
        save([outputpath, '\roiActivityComb_' clusterType '_ByEvents_' num2str(classes(i)) '.mat'], 'tmp', 'roiActivityNames', 'colorMatrix1', 'colorMatrix2')     
     end
 
     plotPCAResults(classes, resultsData, roiActivityNames, colorMatrix1, colorMatrix2, outputpath, clusterType, classesD1, classesD2, gRoi, selectedROISplitDepth1, selectedROISplitDepth3);
end