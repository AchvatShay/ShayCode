function fileName = plotTreeAndActivityDendogram(outputpath, clusterType, activityMatrix, selectedROI, roiLinkage,  roiSortedByCluster, isJetFlip)   
    activitySort = activityMatrix(roiSortedByCluster, roiSortedByCluster);
    for i_1 = 1:length(selectedROI)
        for i_2 = (i_1 + 1):length(selectedROI)
            activitySort(i_1, i_2) = nan; 
        end
    end
    
    fig = figure;
    hold on;
    fig.Color = [1,1,1];
    sb1 = subplot(6, 1, 5:6);

    d = dendrogram(roiLinkage, 'Labels', selectedROI, 'reorder', roiSortedByCluster, 'Orientation', 'bottom');
%     ylim([0.5, length(selectedROI) + 0.5]);
    
    xlim([0.5,length(selectedROI)+0.5]);
    
    set(gca, 'color', 'none');
%     axis off;
    set(d, 'Color', [0,0,0]);
    set(d, 'LineWidth', 1.5);
    
    sb2 = subplot(6, 1, 1:3);
 
    m = imagesc(activitySort);
    ax = gca;
    ax.Box = 'off';
    ax.YAxisLocation = 'left'; 
    yticks(1:length(roiSortedByCluster));
    yticklabels(selectedROI(roiSortedByCluster));
    ax.YDir = 'normal';
    
    ax.XAxisLocation = 'top'; 
    ax.XGrid = 'on';
    xticks(1:length(roiSortedByCluster));
    xticklabels(selectedROI(roiSortedByCluster));
    xtickangle(90);
    
%     colorbar();
    
    cmap = jet();
    
    if isJetFlip
        cmap = (flipud(cmap));
    end
    
    colormap(cmap);
    
    set(m,'AlphaData',~isnan(activitySort))
     
    set(sb2, 'Position', [sb2.Position(1), sb2.Position(2) - 0.2, sb2.Position(3), sb2.Position(4)]);
    set(sb1, 'Position', [sb2.Position(1), sb2.Position(2) - sb1.Position(4), sb2.Position(3), sb1.Position(4)]);
    
    fileName = [outputpath, '\DendrogramStructureAndActivityMatrix_' clusterType];
    mysave(fig, fileName);
end