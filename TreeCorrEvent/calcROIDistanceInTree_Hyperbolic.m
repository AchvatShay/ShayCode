function [roiTreeDistanceMatrix, roiSortedByCluster, l] = calcROIDistanceInTree_Hyperbolic(gRoi, selectedROI, outputpath, loranzORPDistMat)
   tickLabels = [];
   loranzLocation = zeros(1, length(selectedROI.ID));
   
   for index = 1:length(selectedROI.ID)
        tickLabels{index} = selectedROI.Name{index};
        loranzLocation(index) = find(gRoi.Nodes.ID == selectedROI.ID(index));
   end
      
   roiTreeDistanceMatrix = loranzORPDistMat(loranzLocation, loranzLocation); 
   
    y = squareform(roiTreeDistanceMatrix);
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
    colormap(flipud(jet));
    xticklabels(tickLabels(roiSortedByCluster));
    xtickangle(90);
    yticklabels(tickLabels(roiSortedByCluster));
    
    mysave(figDist, [outputpath, '\DistMatrixROIShortestPathDist']);
end