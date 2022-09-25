function [roiTreeDistanceMatrix, roiSortedByCluster, l] = calcROIDistanceInTree_ShortestPathType2(gRoi, selectedROI, outputpath, selectedROISplitDepth1, reverseHeatMap)
    roiTreeDistanceMatrix = zeros(length(selectedROI.ID), length(selectedROI.ID));
    roiTreeDistanceMatrixUnW = zeros(length(selectedROI.ID), length(selectedROI.ID));
    tickLabels = [];
    
    rootNode = gRoi.Nodes.Depth(:, 1) == 0;
    rootNodeID = gRoi.Nodes.ID(rootNode);
    rootNodeID = rootNodeID(1);
    
   for index = 1:length(selectedROI.ID)
        tickLabels{index} = selectedROI.Name{index};
        for secIndex = (index+1):length(selectedROI.ID)
            [p1, ~] = shortestpath(gRoi,selectedROI.ID(index),rootNodeID, 'Method', 'unweighted');
            [p2, ~] = shortestpath(gRoi,selectedROI.ID(secIndex),rootNodeID, 'Method', 'unweighted');
         
            commonRois = intersect(p1, p2);
%             maxRoiCounts = max([length(p1), length(p2)]);
            
%             d = 1 / (length(commonRois) ./ maxRoiCounts);
           
           d = 1 / length(commonRois);
           
           roiTreeDistanceMatrixUnW(index, secIndex) = d;
           roiTreeDistanceMatrixUnW(secIndex, index) = d;
           
           [~, d2] = shortestpath(gRoi,selectedROI.ID(index),selectedROI.ID(secIndex), 'Method', 'positive');
           roiTreeDistanceMatrix(index, secIndex) = d2;
           roiTreeDistanceMatrix(secIndex, index) = d2;
        end
    end
      
    y = squareform(roiTreeDistanceMatrixUnW);
    l = linkage(y, 'single');
         
    figDendrogram = figure;
    
    leafOrder = optimalleaforder(l,y);
    
    dendrogram(l, size(roiTreeDistanceMatrixUnW, 1), 'Labels', tickLabels, 'reorder', leafOrder);
    xtickangle(90);
    title('Tree Structure Dendrogram');
    mysave(figDendrogram, [outputpath, '\DendrogramROITreeDist']);
    
    roiSortedByCluster = leafOrder;    

    if selectedROISplitDepth1(roiSortedByCluster(1)) > min(selectedROISplitDepth1)
        roiSortedByCluster = roiSortedByCluster(end:-1:1);
    end
    
    if  reverseHeatMap
        roiSortedByCluster = roiSortedByCluster(end:-1:1);
    end
    
    for index_roi = 1:length(tickLabels)
        labelsNames(index_roi) = {sprintf('roi%d', sscanf(tickLabels{index_roi}, 'roi%d'))};
    end
 
    
    figDist = figure;
    hold on;
    title({'ROI Structure Distance'});
    xticks(1:length(selectedROI.ID));
    yticks(1:length(selectedROI.ID));
    imagesc(roiTreeDistanceMatrix(roiSortedByCluster, roiSortedByCluster));
    colorbar
    colormap(jet);
    colormap(flipud(jet));
    xticklabels(labelsNames(roiSortedByCluster));
    xtickangle(90);
    yticklabels(labelsNames(roiSortedByCluster));
    
    mysave(figDist, [outputpath, '\DistMatrixROIStructure']);
end