function pictureNames = plotROIDistMatrixTreeVSActivity(gRoi, outputpath, firstBranchROI,mainTreeBranchROI, roiTreeDistanceMatrix, roiActivityDistanceMatrix, do_corrtest, roiActivityDistanceFunction, roiActivityPeakSize, selectedRoi)
    %     Plot ROI Activity VS Tree Distance
    fig = figure;
    hold on;
    % Create ylabel
    ylabel({'Calcium Event Correlation'});

    % Create xlabel
    xlabel({'Dendritic distance'});

    title({'ROI Activity VS Tree Distance'});
%     leg = zeros(3, 1);
    leg = [];
%     legColor = []; 
    classesM = unique(mainTreeBranchROI);
    index_classes = 1;

    
    corrIndexMatrix = 1;   
    classesColorName = {};
    corrIndexMatrixInsideMainBranch = 1;
    for index = 1: size(roiTreeDistanceMatrix, 2)
        for secIndex = (index + 1): size(roiTreeDistanceMatrix, 2)
            for clr = 1:length(classesM)
                if (mainTreeBranchROI(index) == mainTreeBranchROI(secIndex))
                    color = getTreeColor('within', find(classesM == mainTreeBranchROI(index)));
                    colorName = {gRoi.Nodes(mainTreeBranchROI(index),:).Name{1}, gRoi.Nodes(mainTreeBranchROI(index),:).Name{1}};
                    
                    corrMatrixForROIInsideTheMainBranch(corrIndexMatrixInsideMainBranch, :) = [roiTreeDistanceMatrix(index, secIndex), roiActivityDistanceMatrix(index, secIndex)];
                    corrIndexMatrixInsideMainBranch = corrIndexMatrixInsideMainBranch + 1;
                    break;
                else
                    if (firstBranchROI(index) == firstBranchROI(secIndex))
                        colorName = {gRoi.Nodes(mainTreeBranchROI(index),:).Name{1}, gRoi.Nodes(mainTreeBranchROI(secIndex),:).Name{1}};
                        color = getTreeColor('between');
                    else
                        colorName = {gRoi.Nodes(firstBranchROI(index),:).Name{1}, gRoi.Nodes(firstBranchROI(secIndex),:).Name{1}};
                        color = getTreeColor('main');
                    end
                end
            end
            
            hold on;
            corrMatrixForROI(corrIndexMatrix, :) = [roiTreeDistanceMatrix(index, secIndex), roiActivityDistanceMatrix(index, secIndex)];
            corrIndexMatrix = corrIndexMatrix + 1;
            scatter(roiTreeDistanceMatrix(index, secIndex), roiActivityDistanceMatrix(index, secIndex), 'filled', 'MarkerFaceColor', color);
            
            if isempty(classesColorName) || ...
                    (sum(strcmp(classesColorName, [colorName{1} '_' colorName{2}])) == 0 && sum(strcmp(classesColorName, [colorName{2} '_' colorName{1}])) == 0)
                colorName = [colorName{1} '_' colorName{2}];
                colorName = replace(colorName,{'&','-'}, '_'); 
                classesColorName(index_classes) = {colorName};
                classesColor(index_classes) = {color};
                
                leg(index_classes) = plot(0,0, 'color', color, 'LineWidth', 2.5);
                legColor(index_classes) = {colorName};
                
                resultsT.(colorName) = [];
                index_classes = index_classes + 1;
            else
                if (sum(strcmp(classesColorName, [colorName{1} '_' colorName{2}])) ~= 0)
                    colorName = [colorName{1} '_' colorName{2}];
                else
                    colorName = [colorName{2} '_' colorName{1}];
                end
                colorName = replace(colorName,{'&','-'}, '_'); 
            end
            
                
            resultsT.(colorName)(end + 1, :) = [roiTreeDistanceMatrix(index, secIndex), roiActivityDistanceMatrix(index, secIndex)];
        end
    end

    legend(leg, legColor);
    legend('Location','northwestoutside')
    
%     ylim([0,1]);
       
    fileName1 = [outputpath, '\ActivityDistVSDendriticDistForROI_' roiActivityDistanceFunction ,'_eventsSize', roiActivityPeakSize, '_numofTreeDepth', num2str(length(classesM))];
    mysave(fig, fileName1);

    %     Plot ROI Activity VS Tree Distance
    fig3 = figure;
    hold on;

    title({'ROI Activity VS Tree Distance'});
    legend(leg, legColor);

    matR = [];
    groupR = [];
    labelsR = [];
    indexGroup = 1;
    for clr1 = 1:length(classesColorName)
        tempR = resultsT.(classesColorName{clr1});

        if isempty(tempR)
            continue;
        end

        matR = [matR; tempR(:,2)];
        groupR = [groupR; ones(size(tempR(:,2)))*indexGroup];

        indexGroup = indexGroup + 1;

        labelsR{end + 1} = classesColorName{clr1};

    end
    
    boxplot(matR, groupR, 'Labels', labelsR);        
    
    fileName4 = [outputpath, '\DendriticDistVSActivityDistForROIBOXPlot_' roiActivityDistanceFunction ,'_eventsSize', roiActivityPeakSize, '_numofTreeDepth', num2str(length(classesM))];
    mysave(fig3, fileName4);
%     --------------------------------------------------------------------------
    
    f_name = fieldnames(resultsT);
    for t = 1:length(f_name)
        if isempty(resultsT.(f_name{t}))
            continue;
        end
        
        writetable(array2table(resultsT.(f_name{t})),fullfile(outputpath, ['ActivityVSDendriticForROI_' num2str(t) '_Depth', num2str(length(classesM)) '.xls']),'Sheet',f_name{t});
    end
    
    %     coutI = 1;
    nodesColor = zeros(length(gRoi.Nodes.Name),3);
    tempC = zeros(length(classesM(classesM ~= -1)), 3);
    tempC(:, 1) = 1;
    nodesColor(classesM(classesM ~= -1), :) = tempC;
    
    for clr = 1:length(classesM)
        for i = 1:length(mainTreeBranchROI)
            if mainTreeBranchROI(i) == classesM(clr)
                locRoi = find(strcmp(gRoi.Nodes.Name, selectedRoi(i)));
                nodesColor(locRoi, :) = getTreeColor('within', (clr));
%                 coutI = coutI + 1;
            end
        end
    end
     
    figGraph = figure;
    plot(gRoi, 'EdgeLabel',gRoi.Edges.Weight, 'NodeColor', nodesColor);
    title({'Number of subtree ', num2str(length(classesM))});
    fileName2 = [outputpath, '\GraphWithROI_' num2str(length(classesM))];
    mysave(figGraph, fileName2);
   
    
    pictureNames = {fileName1, fileName2};
    
    if do_corrtest            
    %     Cals positive corr between ROI tree and activity distance
         [RHO,PVAL] = corr(corrMatrixForROI,'type','Pearson');
         [RHO_InsideTheMainBranch,PVAL_InsideTheMainBranch] = corr(corrMatrixForROIInsideTheMainBranch,'type','Pearson');

        save([outputpath, '\CorrEventsDistVSDendriticDist_' roiActivityDistanceFunction ,'_eventsSize', roiActivityPeakSize, '_numofTreeDepth', num2str(length(classesM))], 'RHO', 'PVAL', 'RHO_InsideTheMainBranch', 'PVAL_InsideTheMainBranch');
    end  
end