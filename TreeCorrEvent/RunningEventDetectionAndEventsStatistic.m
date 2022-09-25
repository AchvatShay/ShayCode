function RunningEventDetectionAndEventsStatistic(globalParameters) 
     
     neuronActivityPathTPA = globalParameters.neuronActivityPathTPA;

    neuronTreePathSWC = globalParameters.neuronTreePathSWC;
    
    outputpath = globalParameters.outputpath;
   
    doComboForCloseRoi = false;
    
    eventsDetectionFolder = globalParameters.eventsDetectionFolder;
      
    sprintf('Animal :%s, Date :%s, Neuron :%s', globalParameters.AnimalName, globalParameters.DateAnimal, globalParameters.neuronNumberName)
    
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
    
    roi_count = length(selectedROI);
    aV = ones(1, roi_count)*globalParameters.aVForAll;
    
    if ~isempty(globalParameters.aVFix.location)
        aV(globalParameters.aVFix.location) = globalParameters.aVFix.values;
    end
    
    sigmaChangeValue = globalParameters.sigmaChangeValue * ones(1, roi_count);
    
    if ~isempty(globalParameters.sigmaFix.location)
        aV(globalParameters.sigmaFix.location) = globalParameters.sigmaFix.values;
    end
 
    thresholdGn = globalParameters.thresholdGnValue * ones(1, roi_count);
    
    if ~isempty(globalParameters.thresholdGnFix.location)
        thresholdGn(globalParameters.thresholdGnFix.location) = globalParameters.thresholdGnFix.values;
    end
    
    save([outputpath '\runParametes'],'aV', 'roi_count', 'sigmaChangeValue', 'globalParameters');

    [roiActivity, roiActivityNames, tr_frame_count] = loadActivityFileFromTPA(neuronActivityPathTPA, selectedROI, outputpath);

   %     Calc branching
    selectedROISplitDepth1 = ones(length(selectedROI), 1) * -1;
    selectedROISplitDepth1 = getSelectedROISplitBranchID(gRoi, globalParameters.firstDepthCompare, selectedROISplitDepth1, selectedROI, rootNodeID);   
    
%     Calc Distance Matrix for ROI in Tree
   switch(globalParameters.roiTreeDistanceFunction)
        case 'Euclidean'
           [roiTreeDistanceMatrix, roiSortedByCluster, roiLinkage] = calcROIDistanceInTree_Euclidean(gRoi, selectedROI, outputpath, selectedROISplitDepth1, false); 
        case 'ShortestPath'
           [roiTreeDistanceMatrix, roiSortedByCluster, roiLinkage] = calcROIDistanceInTree_ShortestPath(gRoi, selectedROITable, outputpath, selectedROISplitDepth1, false);
        case 'ShortestPathCost'
           [roiTreeDistanceMatrix, roiSortedByCluster, roiLinkage] = calcROIDistanceInTree_ShortestPathCost(gRoi, selectedROITable, outputpath, selectedROISplitDepth1, globalParameters.costSP, false);
        case 'Branch'
           [roiTreeDistanceMatrix, roiSortedByCluster, roiLinkage] = calcROIDistanceInTree_Branch(gRoi, selectedROITable, outputpath,selectedROISplitDepth1, false);
        case 'HyperbolicDist_L'
           [roiTreeDistanceMatrix, roiSortedByCluster, roiLinkage] = calcROIDistanceInTree_Hyperbolic(gRoi, selectedROITable, outputpath, loranzDistMat, selectedROISplitDepth1, false);
        case 'HyperbolicDist_P'
           [roiTreeDistanceMatrix, roiSortedByCluster, roiLinkage] = calcROIDistanceInTree_Hyperbolic(gRoi, selectedROITable, outputpath, poincareDistMat, selectedROISplitDepth1, false);
    end
        
    % Save Graph for HS structure with colors
    classesD1 = unique(selectedROISplitDepth1);   
    classesD1(classesD1 == -1) = [];
 
    colorMatrix1 = zeros(length(selectedROISplitDepth1), 3);
    for d_i = 1:length(selectedROISplitDepth1)
        if selectedROISplitDepth1(d_i) == -1
            colorMatrix1(d_i, :) = [0,0,0];
        else  
            colorMatrix1(d_i, :) = getTreeColor('within', find(classesD1 == selectedROISplitDepth1(d_i)), true);
        end
    end
    
    save([outputpath, '\roiActivityRawData.mat'], 'roiActivity', 'roiActivityNames', 'colorMatrix1', 'selectedROISplitDepth1');
    close all;

    if isfile([eventsDetectionFolder, '\roiActivity_comb.mat'])
        load([eventsDetectionFolder, '\roiActivity_comb.mat'], 'allEventsTable', 'roiActivity_comb');  
    else
        [allEventsTable, roiActivity_comb] = calcActivityEventsWindowsAndPeaks_V3(roiActivity, eventsDetectionFolder, 1, globalParameters.ImageSamplingRate, tr_frame_count, aV, roiActivityNames, sigmaChangeValue, globalParameters.mean_aV, globalParameters.runMLS, thresholdGn, false);        
        save([eventsDetectionFolder, '\roiActivity_comb.mat'], 'allEventsTable', 'roiActivity_comb');
    end 
    
    for i_e = 1:size(allEventsTable, 1)
        tr_index = floor(allEventsTable.start(i_e) ./ tr_frame_count) + 1;
        allEventsTable.tr_index(i_e) = tr_index;
    end
       
    writetable(allEventsTable,[outputpath '\eventsCaSummary.csv']);

    f = figure;hold on;
    for i = 1:length(classesD1)
        indexList = find(selectedROISplitDepth1 == classesD1(i));
        avgActivitySide1 = mean(roiActivity(:, indexList), 2);
        
        plot(avgActivitySide1 + i, 'Color', colorMatrix1(indexList(1), :), 'DisplayName', sprintf('Side %d', i));
    end
    
    legend('show');
    plot(mean(roiActivity, 2), 'Color', [0,0,0], 'DisplayName', 'All');
    mysave(f, fullfile(outputpath, 'avgActivityperSide'));
    
    roiActivityPeakSize = 'All';
    locationByH = 1: size(allEventsTable, 1);
    locationByP = 1: size(allEventsTable, 1);
    event_count_ByH = size(allEventsTable, 1);
    event_count_ByP = size(allEventsTable, 1);
    
    outputpathCurr = [outputpath, '\', roiActivityPeakSize];
        
    sprintf('Ca Events, %s', roiActivityPeakSize)

    isFlipMap = false;
    i_cluster = 1;
    globalParameters.clusterCount = 1;
    
    switch(globalParameters.roiActivityDistanceFunction)
           case 'WindowEventFULLPearson'
               [roiActivityDistanceMatrixByH, roiActivityDistanceMatrixByP] = calcROIDistanceInActivity_WindowEventPearson_V3(roiActivity_comb, roiActivityNames, selectedROI, allEventsTable, 'FULL', i_cluster, globalParameters.clusterCount);               
               plotTreeByROIAverageActivityWithCluster(gRoi, outputpathCurr, roiActivity_comb, roiActivityNames, selectedROI, allEventsTable, 'FULL', i_cluster, roiSortedByCluster)              
           case 'WindoEventToPeakPearson'
               [roiActivityDistanceMatrixByH_all, roiActivityDistanceMatrixByP_all] = calcROIDistanceInActivity_WindowEventPearson_V3(roiActivity_comb, roiActivityNames, selectedROI, allEventsTable, 'ToPeak', i_cluster, globalParameters.clusterCount); 
               roiActivityDistanceMatrixByH = squeeze(roiActivityDistanceMatrixByH_all(:,:,1));
               roiActivityDistanceMatrixByP = squeeze(roiActivityDistanceMatrixByP_all(:,:,1));              
               plotTreeByROIAverageActivityWithCluster(gRoi, outputpathCurr, roiActivity_comb, roiActivityNames, selectedROI, allEventsTable, 'ToPeak', i_cluster, roiSortedByCluster)
           case 'WindoEventPearsonPerEvent'         
               roiActivityDistanceMatrixByH = squeeze(mean(curEventPearson(locationByH, :, :), 1, 'omitnan'));
               roiActivityDistanceMatrixByP = squeeze(mean(curEventPearson(locationByP, :, :), 1, 'omitnan'));
               
               roiActivityDistanceMatrixByH_all(:,:, 1) =  roiActivityDistanceMatrixByH; 
               roiActivityDistanceMatrixByH_all(:,:, 2) =  0;
               
               roiActivityDistanceMatrixByP_all(:,:, 1) =  roiActivityDistanceMatrixByP; 
               roiActivityDistanceMatrixByP_all(:,:, 2) =  0;
               mkdir(outputpathCurr);
           case 'PeaksPearson'
               [roiActivityDistanceMatrixByH_all, roiActivityDistanceMatrixByP_all] = calcROIDistanceInActivity_WindowEventPearson_V3(roiActivity_comb, roiActivityNames, selectedROI, allEventsTable, 'Peaks', i_cluster, globalParameters.clusterCount);
            
               roiActivityDistanceMatrixByH = squeeze(roiActivityDistanceMatrixByH_all(:,:,1));
               roiActivityDistanceMatrixByP = squeeze(roiActivityDistanceMatrixByP_all(:,:,1));
              
               
               plotTreeByROIAverageActivityWithCluster(gRoi, outputpathCurr, roiActivity_comb, roiActivityNames, selectedROI, allEventsTable, 'Peaks', i_cluster, roiSortedByCluster)
          
           case 'WindoEventToPeakCov'
               [roiActivityDistanceMatrixByH_all, roiActivityDistanceMatrixByP_all] = calcROIDistanceInActivity_WindowEventCov_V3(roiActivity_comb, roiActivityNames, selectedROI, allEventsTable, 'ToPeak', i_cluster, globalParameters.clusterCount);

               roiActivityDistanceMatrixByH = squeeze(roiActivityDistanceMatrixByH_all(:,:,1));
               roiActivityDistanceMatrixByP = squeeze(roiActivityDistanceMatrixByP_all(:,:,1));
               
               plotTreeByROIAverageActivityWithCluster(gRoi, outputpathCurr, roiActivity_comb, roiActivityNames, selectedROI, allEventsTable, 'ToPeak', i_cluster, roiSortedByCluster)           
           case 'WindoEventToPeakSperman'
               [roiActivityDistanceMatrixByH, roiActivityDistanceMatrixByP] = calcROIDistanceInActivity_WindowEventSperman_V3(roiActivity_comb, roiActivityNames, selectedROI, allEventsTable, 'ToPeak', i_cluster, globalParameters.clusterCount);
            
               plotTreeByROIAverageActivityWithCluster(gRoi, outputpathCurr, roiActivity_comb, roiActivityNames, selectedROI, allEventsTable, 'ToPeak', i_cluster, roiSortedByCluster)           
    end
           
   if sum(isnan(roiActivityDistanceMatrixByH), 'all') < (size(roiActivityDistanceMatrixByH(:), 1) - size(roiActivityDistanceMatrixByH, 1)) && ...
       sum((roiActivityDistanceMatrixByH < 0), 'all') < (size(roiActivityDistanceMatrixByH(:), 1) - size(roiActivityDistanceMatrixByH, 1)) && ...
       size(roiActivityDistanceMatrixByH, 1) > 2


       roiActivityDistanceMatrixByHNO_nan = roiActivityDistanceMatrixByH;
       roiActivityDistanceMatrixByHNO_nan(isnan(roiActivityDistanceMatrixByH)) = 0;
       roiActivityDistanceMatrixByHNO_nan(roiActivityDistanceMatrixByH < 0) = 0;

       [outM, pValM] = bramila_mantel(1 - abs(roiActivityDistanceMatrixByHNO_nan), roiTreeDistanceMatrix, 5000, 'pearson');
   else
       outM  = 0;
       pValM = 1;
   end

   save([outputpathCurr, '\mantelResults.mat'], 'outM', 'pValM');
   sprintf('Cluster By H')

   plotTreeAndActivityDendogram(outputpathCurr,  'ByH', roiActivityDistanceMatrixByH, selectedROI,...
        roiLinkage,  roiSortedByCluster, isFlipMap, false);

   plotTreeAndActivityDendogram(outputpathCurr,  'ByH', roiActivityDistanceMatrixByH, selectedROI,...
        roiLinkage,  roiSortedByCluster, isFlipMap, true);

    close all;

    sprintf('Cluster By P')

    plotTreeAndActivityDendogram(outputpathCurr, 'ByP', roiActivityDistanceMatrixByP, selectedROI, roiLinkage,...
        roiSortedByCluster, isFlipMap, false);
    
    plotTreeAndActivityDendogram(outputpathCurr, 'ByP', roiActivityDistanceMatrixByP, selectedROI, roiLinkage,...
        roiSortedByCluster, isFlipMap, true);
    
    close all;
       
   sprintf('Cluster By H')
   plotResultesByClusterType(isFlipMap, event_count_ByH, roiActivityDistanceMatrixByH_all, 'ByH', selectedROI, roiSortedByCluster, outputpathCurr, globalParameters.roiActivityDistanceFunction,...
       roiActivityPeakSize, gRoi, roiTreeDistanceMatrix, selectedROISplitDepth1, selectedROITable, i_cluster, globalParameters.DistType);

   snapnow;
   close all;
       
   sprintf('Cluster By P')
   plotResultesByClusterType(isFlipMap, event_count_ByP, roiActivityDistanceMatrixByP_all, 'ByP', selectedROI, roiSortedByCluster, outputpathCurr, globalParameters.roiActivityDistanceFunction,...
       roiActivityPeakSize, gRoi, roiTreeDistanceMatrix, selectedROISplitDepth1, selectedROITable, i_cluster, globalParameters.DistType);       

    close all;
    fclose all;
    
    eventsStatistic(outputpath, allEventsTable, selectedROISplitDepth1)
end
 
function plotResultesByClusterType(isFlipMap, event_count,roiActivityDistanceMatrix, clusterType, selectedROI, roiSortedByCluster, outputpathCurr, roiActivityDistanceFunction, roiActivityPeakSize, gRoi, roiTreeDistanceMatrix, selectedROISplitDepth1, selectedROITable, i_cluster, distType)
        outputPathF = [outputpathCurr, '\' , clusterType, '\BetweenAndWithinSubTrees'];

        roiActivityDistanceMatrixCor = squeeze(roiActivityDistanceMatrix(:, :, 1));
        
        import mlreportgen.ppt.*
    
        figDist = figure;
        hold on;
        title({'ROI Activity Distance', ['events:', num2str(event_count)]});
        xticks(1:length(selectedROI));
        yticks(1:length(selectedROI));
        m = imagesc(roiActivityDistanceMatrixCor(roiSortedByCluster, roiSortedByCluster));
        colorbar
        cmap = jet();
        
        if isFlipMap
            cmap = flipud(cmap);
        end
        
        colormap(cmap);
        
        set(m,'AlphaData',~isnan(roiActivityDistanceMatrixCor(roiSortedByCluster, roiSortedByCluster)))
                
        for index_roi = 1:length(selectedROI)
            labelsNames(index_roi) = {sprintf('roi%d', sscanf(selectedROI{index_roi}, 'roi%d'))};
        end
        
        xticklabels(labelsNames(roiSortedByCluster));
        xtickangle(90);
        yticklabels(labelsNames(roiSortedByCluster));
        picNameFile = [outputPathF, '\DistMatrixActivity_', roiActivityDistanceFunction, '_eventsSize', roiActivityPeakSize];
        mysave(figDist, picNameFile);  

        if size(find(~isnan(roiActivityDistanceMatrixCor), 1), 1) > 1
        
            removeIndex = [];
            test = 1 - abs(roiActivityDistanceMatrixCor);
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

            mysave(figDendrogram, [outputPathF, '\DendrogramROIActivity']);
        end
        
        plotROIDistMatrixTreeVSActivityBlack(event_count, gRoi, outputPathF, selectedROISplitDepth1, selectedROISplitDepth1, roiTreeDistanceMatrix, roiActivityDistanceMatrix, true, roiActivityDistanceFunction, roiActivityPeakSize, selectedROI, [], distType, clusterType);
        
        plotROIDistMatrixTreeVSActivity(event_count, gRoi, outputPathF,selectedROISplitDepth1, selectedROISplitDepth1, roiTreeDistanceMatrix, roiActivityDistanceMatrix, true, roiActivityDistanceFunction, roiActivityPeakSize, selectedROI, [], distType, clusterType);
end