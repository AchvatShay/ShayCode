function plotTreeAndActivityForAllTrialTraces()
   BDATPAFolder = '\\jackie-analysis\F\Layer II-III\Analysis\Bas-M2-Sa1\08.18.22-N1-Tuft\';
   outputpath = '\\jackie-analysis\F\Layer II-III\Analysis\Bas-M2-Sa1\08.18.22-N1-Tuft\Results\N1\tracesPlot\';
   neuronTreePathSWC = '\\jackie-analysis\F\Layer II-III\Analysis\Bas-M2-Sa1\08.18.22-N1-Tuft\swcFiles\neuron_1.swc';
   mkdir(outputpath);
   ImagingSamplineRate = 30;
   
   trialTime = 12;
   
   tuftdepth = 4;
   basaldepth = 2;
    
   tuftRoisNames = 1:11;
   basalRoisNames = [];

   tuftIndexRoi = [];
   basalIndexRoi = [];

    excludeRoi = [];
   [gRoi, rootNodeID, selectedROITable] = loadSwcFile(neuronTreePathSWC, outputpath, false);

   selectedROITable = sortrows(selectedROITable, 2);
   
    for i = 1:length(excludeRoi)
        ex_results = contains(selectedROITable.Name, sprintf('roi%05d', excludeRoi(i)));

        if sum(ex_results) == 1
            selectedROITable(ex_results, :) = [];
        end
    end

    for i = 1:size(selectedROITable, 1)
        currR = find(tuftRoisNames == sscanf(selectedROITable.Name{i}, 'roi%05d'), 1);  
        if ~isempty(currR)
            tuftIndexRoi(end+1) = i;
        end
        currR = find(basalRoisNames == sscanf(selectedROITable.Name{i}, 'roi%05d'), 1);  
        if ~isempty(currR)
            basalIndexRoi(end+1) = i;
        end
    end

    
    selectedROI = selectedROITable.Name;
    
    [roiActivity, ~, ~] = loadActivityFileFromTPA(BDATPAFolder, selectedROI, outputpath);

 
   colorMapLim = [0,0.03];
   
   totalTrialTime = ImagingSamplineRate*trialTime;
   
   t = linspace(0, 12 * (round(size(roiActivity, 1) ./ totalTrialTime)), size(roiActivity, 1));
    
    for i = 1:length(excludeRoi)
        ex_results = contains(selectedROITable.Name, sprintf('roi%05d', excludeRoi(i)));
        
        if sum(ex_results) == 1
            selectedROITable(ex_results, :) = [];
        end
    end
    
    selectedROI = selectedROITable.Name;
  
    selectedROISplitDepth1 = ones(length(selectedROI), 1) * -1;
    selectedROISplitDepth1 = getSelectedROISplitBranchID(gRoi, tuftdepth, selectedROISplitDepth1, selectedROI, rootNodeID);
    selectedROISplitDepth1(basalIndexRoi) = -1;
    selectedROISplitDepth1 = getSelectedROISplitBranchID(gRoi, basaldepth, selectedROISplitDepth1, selectedROI, rootNodeID);
    
    [~, roiSortedByCluster, roiLinkage] = calcROIDistanceInTree_ShortestPathType2(gRoi, selectedROITable, outputpath, selectedROISplitDepth1, false);
      
    fig = figure;
    hold on;

    sb1 = subplot(1, 6,1);

    dendrogram(roiLinkage, 'Labels', selectedROI, 'reorder', roiSortedByCluster, 'Orientation', 'left');
    ylim([0.5, length(selectedROI) + 0.5]);
    set(gca, 'color', 'none');
    axis off;
    
    sb2 = subplot(1, 6, 2:5);
 
    revA = roiSortedByCluster(:);
    
    for j = 1:length(revA)
        plot(roiActivity(:, revA(j))+(j)*2, 'k');hold on;
    end
    
    ax = gca;
    ax.YAxisLocation = 'right'; 
    yticks(2:2:length(revA)*2);
    yticklabels(selectedROI(revA));
    colormap('jet');
   
    ylim([1.5, length(selectedROI)*2 + 4]);
    caxis(colorMapLim);
    set(sb2, 'Position', [sb1.Position(1) + sb1.Position(3), sb1.Position(2), sb2.Position(3), sb2.Position(4)]);
    set(sb1, 'Position', [sb1.Position(1) , sb1.Position(2)-0.005, sb1.Position(3), sb1.Position(4)-0.04]);
    % Create title
    title(['All Activity']);
    
    mysave(fig, [outputpath, '\DendrogramROIShortestPathDistAndActivityROIFORAllTr']);    
end