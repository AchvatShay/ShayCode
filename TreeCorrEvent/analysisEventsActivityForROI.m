function analysisEventsActivityForROI(gROI, allEventsTable, selectedROI, selectedROISplitDepth, outputpath, fileName, clusterCount)
    outputpath = [outputpath, '\behave\'];
    mkdir(outputpath);
    
    classes = unique(selectedROISplitDepth);
    classes(classes == -1) = [];
    fileID = fopen([outputpath, '\' fileName 'Sum_behaveAnalysis.txt'],'w');
    fileIDSec = fopen([outputpath, '\' fileName 'Precentage_behaveAnalysis.txt'],'w');
    
    for i_cluster = 0:clusterCount
        sumActivityForROI_noW = zeros(1, length(selectedROI));
        sumActivityForROI_W_PksH = zeros(1, length(selectedROI));
        sumActivityForROI_W_Precentage = zeros(1, length(selectedROI));

        countEvents_noW = 0;
        countEvents_P = 0;
        
        for i_e = 1:size(allEventsTable, 1)
            if allEventsTable.clusterByH(i_e) == i_cluster || i_cluster == 0
                sumActivityForROI_W_PksH(allEventsTable.roisEvent{i_e} == 1) = sumActivityForROI_W_PksH(allEventsTable.roisEvent{i_e} == 1) + 1*allEventsTable.H(i_e);
                sumActivityForROI_noW(allEventsTable.roisEvent{i_e} == 1) = sumActivityForROI_noW(allEventsTable.roisEvent{i_e} == 1) + 1;        
                countEvents_noW = countEvents_noW + 1;
            end
            
            if allEventsTable.clusterByRoiPrecantage(i_e) == i_cluster || i_cluster == 0
                sumActivityForROI_W_Precentage(allEventsTable.roisEvent{i_e} == 1) = sumActivityForROI_W_Precentage(allEventsTable.roisEvent{i_e} == 1) + 1*allEventsTable.roiPrecantage(i_e);
                countEvents_P = countEvents_P + 1;
            end
        end
        
        plotResultsA(outputpath, [fileName, '_noWeight', '_sum'], i_cluster, sumActivityForROI_noW, classes, selectedROISplitDepth, 'no weight', gROI, fileID);
        plotResultsA(outputpath, [fileName, '_WeightHigh', '_sum'], i_cluster, sumActivityForROI_W_PksH, classes, selectedROISplitDepth, 'weight High', gROI, fileID);
        plotResultsA(outputpath, [fileName, '_WeightPrecentage', '_sum'], i_cluster, sumActivityForROI_W_Precentage, classes, selectedROISplitDepth, 'weight Precentage', gROI, fileID);   
      
        sumActivityForROI_noW = sumActivityForROI_noW ./ countEvents_noW;
        sumActivityForROI_W_PksH = sumActivityForROI_W_PksH ./ countEvents_noW;
        sumActivityForROI_W_Precentage = sumActivityForROI_W_Precentage ./ countEvents_P;
        
        plotResultsA(outputpath, [fileName, '_noWeight', '_precentage'], i_cluster, sumActivityForROI_noW, classes, selectedROISplitDepth, 'no weight', gROI, fileIDSec);
        plotResultsA(outputpath, [fileName, '_WeightHigh', '_precentage'], i_cluster, sumActivityForROI_W_PksH, classes, selectedROISplitDepth, 'weight High', gROI, fileIDSec);
        plotResultsA(outputpath, [fileName, '_WeightPrecentage', '_precentage'], i_cluster, sumActivityForROI_W_Precentage, classes, selectedROISplitDepth, 'weight Precentage', gROI, fileIDSec);   
    
    end
    
    fclose(fileID);
end

function plotResultsA(outputpath, fileName, i_cluster, sumActivityForROI, classes, selectedROISplitDepth, titleAdd, gROI, fileID)
    formatSpec = 'cluster %d, type: %s, name: %s, mean: %d, std: %d, count: %d\n';
    
    fig = figure;
    hold on;

    %         all ROI        
    meanAll = mean(sumActivityForROI);
    stdAll = std(sumActivityForROI);
    x_tick{1} = 'allRoi';

    errorbar(1, meanAll,stdAll, 'o', 'Color', 'black', 'MarkerSize', 6, 'MarkerEdgeColor','black','MarkerFaceColor','black');
    text(1,meanAll,sprintf(' mean: %d,\n std: %d\n count: %d', meanAll, stdAll, length(sumActivityForROI)));
    indexT = 3;
    
    fprintf(fileID, formatSpec,i_cluster,titleAdd,'allROI', meanAll, stdAll, length(sumActivityForROI));
    
    for s_t = 1:length(classes)
        sum_c = sum(classes(s_t) == selectedROISplitDepth);
        m_c = mean(sumActivityForROI(classes(s_t) == selectedROISplitDepth));
        std_c = std(sumActivityForROI(classes(s_t) == selectedROISplitDepth));
        color = getTreeColor('within', s_t);
        name = gROI.Nodes.Name{classes(s_t)};
        x_tick{end + 1} = name;
        errorbar(indexT, m_c,std_c,'o', 'Color', color, 'MarkerSize', 6, 'MarkerEdgeColor',color,'MarkerFaceColor',color);
        text(indexT, m_c,sprintf(' mean: %d,\n std: %d\n count: %d', m_c, std_c, sum_c));
        indexT = indexT + 2;
        
        fprintf(fileID, formatSpec,i_cluster,titleAdd,name, m_c, std_c, sum_c);
    end

    title({['cluster: ' num2str(i_cluster) ' , Type: ' titleAdd]});
    xticks([1:2:(indexT - 2)]);
    xticklabels(x_tick);
    xtickangle(90);
    xlim([0, (indexT)]);

    mysave(fig, [outputpath, '\' fileName '_cluster_' num2str(i_cluster) 'analysisR']);

end