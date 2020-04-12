function  [roiTreeDistanceMatrix, roiSortedByCluster, l] = calcROIDistanceInTree_Euclidean(gRoi, selectedROI, outputpath)
    roiTreeDistanceMatrix = zeros(length(selectedROI), length(selectedROI));
    tickLabels = [];
    for index = 1:length(selectedROI)
        tickLabels{index} = selectedROI{index};
        for secIndex = 1:length(selectedROI)
            fNode = gRoi.Nodes(findnode(gRoi,selectedROI{index}), :);
            sNode = gRoi.Nodes(findnode(gRoi,selectedROI{secIndex}), :);
  
            roiTreeDistanceMatrix(index, secIndex) = norm([fNode.X(1), fNode.Y(1), fNode.Z(1)] - [sNode.X(1), sNode.Y(1), sNode.Z(1)]); 
        end
    end
    
    clusterNumber = sum(gRoi.Nodes.Depth(: ,1) == 2) * 3;
    
    y = squareform(roiTreeDistanceMatrix);
    l = linkage(y, 'single');
    c = cluster(l,'maxclust',clusterNumber);
          
    figDendrogram = figure;
    dendrogram(l, 'Labels', tickLabels, 'ColorThreshold', 'default');
    mysave(figDendrogram, [outputpath, '\DendrogramROIEuclideanDist']);
    
    [~, roiSortedByCluster] = sort(c);
  
    
    figDist = figure;
    hold on;
    title({'ROI Distance'});
    xticks(1:length(selectedROI));
    yticks(1:length(selectedROI));
    imagesc(roiTreeDistanceMatrix(roiSortedByCluster, roiSortedByCluster));
    colorbar
    xticklabels(tickLabels(roiSortedByCluster));
    xtickangle(90);
    yticklabels(tickLabels(roiSortedByCluster));
    
    mysave(figDist, [outputpath, '\DistMatrixTreeROIEuclidean']);    
end