function [roiTreeDistanceMatrix, roiSortedByCluster, l] = calcROIDistanceInTree_ShortestPath(gRoi, selectedROI, outputpath)
    roiTreeDistanceMatrix = zeros(length(selectedROI.ID), length(selectedROI.ID));
    roiTreeDistanceMatrixUnW = zeros(length(selectedROI.ID), length(selectedROI.ID));
    tickLabels = [];
    
   for index = 1:length(selectedROI.ID)
        tickLabels{index} = selectedROI.Name{index};
        for secIndex = 1:length(selectedROI.ID)
           [p, d] = shortestpath(gRoi,selectedROI.ID(index),selectedROI.ID(secIndex), 'Method', 'unweighted');
           
           for i = 1:length(p)-1
                d = d + abs(gRoi.Nodes.Depth(p(i), 1) - gRoi.Nodes.Depth(p(i+1), 1));  
           end
           
           roiTreeDistanceMatrixUnW(index, secIndex) = d;
           
           [~, d2] = shortestpath(gRoi,selectedROI.ID(index),selectedROI.ID(secIndex), 'Method', 'positive');
           roiTreeDistanceMatrix(index, secIndex) = d2;
           
        end
    end
      
    y = squareform(roiTreeDistanceMatrixUnW);
    l = linkage(y, 'single');
         
    figDendrogram = figure;
    
    leafOrder = optimalleaforder(l,y);
    
    dendrogram(l, 'Labels', tickLabels, 'reorder', leafOrder);
    
    mysave(figDendrogram, [outputpath, '\DendrogramROIShortestPathDist']);
    
    roiSortedByCluster = leafOrder;    

    figDist = figure;
    hold on;
    title({'ROI Distance'});
    xticks(1:length(selectedROI.ID));
    yticks(1:length(selectedROI.ID));
    imagesc(roiTreeDistanceMatrix(roiSortedByCluster, roiSortedByCluster));
    colorbar
    colormap(jet);
    xticklabels(tickLabels(roiSortedByCluster));
    xtickangle(90);
    yticklabels(tickLabels(roiSortedByCluster));
    
    mysave(figDist, [outputpath, '\DistMatrixROIShortestPathDist']);
end