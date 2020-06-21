function plotROIDistMatrixTreeVSActivity(gRoi, outputpath, mainTreeBranchROI, roiTreeDistanceMatrix, roiActivityDistanceMatrix, do_corrtest, roiActivityDistanceFunction, roiActivityPeakSize, selectedRoi)
    %     Plot ROI Activity VS Tree Distance
    fig = figure;
    hold on;
    % Create ylabel
    ylabel({'Calcium Event Distance'});

    % Create xlabel
    xlabel({'Dendritic distance'});

    title({'ROI Activity VS Tree Distance'});
%     leg = zeros(3, 1);
    leg = [];
%     legColor = []; 
    classesM = unique(mainTreeBranchROI);
    index_classes = 1;   
    for index = 1:length(classesM)     
        for secIndex = index:length(classesM)
            if (classesM(index) == -1 && classesM(secIndex) == -1)
                nameF = 'NotInDepth';
                nameS = 'NotInDepth';
                color = [1, 0, 0];
            elseif (classesM(index) == -1 && classesM(secIndex) ~= -1)
                nameF = gRoi.Nodes(classesM(secIndex),:).Name{1};
                nameF(nameF == '_') = '-';

                nameS = 'NotInDepth';
                color = [1, 0, 0];
            elseif (classesM(index) ~= -1 && classesM(secIndex) == -1)
                nameF = gRoi.Nodes(classesM(index),:).Name{1};
                nameF(nameF == '_') = '-';

                nameS = 'NotInDepth';
                color = [1, 0, 0];
            else
                nameF = gRoi.Nodes(classesM(index),:).Name{1};
                nameF(nameF == '_') = '-';

                nameS = gRoi.Nodes(classesM(secIndex),:).Name{1};
                nameS(nameS == '_') = '-';

                if isequal(nameF, nameS)
                    color = [0; rand(2,1)];
                else
                    color = [1, 0, 0];
                end
            end
            
            classesColor(index, secIndex) = {color};
            leg(index_classes) = plot(0,0, 'color', classesColor{index, secIndex}, 'LineWidth', 2.5);
            legColor(index_classes) = {[nameF '&' nameS]};
            
            classesColorName(index, secIndex) = replace(legColor(index_classes),{'&','-'}, '_'); 
            resultsT.(classesColorName{index, secIndex}) = []; 
            index_classes = index_classes + 1;
        end
    end
    
    corrIndexMatrix = 1;   
    corrIndexMatrixInsideMainBranch = 1;
    for index = 1: size(roiTreeDistanceMatrix, 2)
        for secIndex = (index + 1): size(roiTreeDistanceMatrix, 2)
            for clr = 1:length(classesM)
                if (mainTreeBranchROI(index) == mainTreeBranchROI(secIndex) && mainTreeBranchROI(secIndex) == classesM(clr))
                    color = classesColor{clr, clr};
                    colorName = classesColorName{clr, clr};
                    corrMatrixForROIInsideTheMainBranch(corrIndexMatrixInsideMainBranch, :) = [roiTreeDistanceMatrix(index, secIndex), roiActivityDistanceMatrix(index, secIndex)];
                    corrIndexMatrixInsideMainBranch = corrIndexMatrixInsideMainBranch + 1;
                    break;
                else
                    for clr2 = clr:length(classesM)
                        if (mainTreeBranchROI(index) == classesM(clr) && mainTreeBranchROI(secIndex) == classesM(clr2)) || ...
                                (mainTreeBranchROI(index) == classesM(clr2) && mainTreeBranchROI(secIndex) == classesM(clr))
                            color = classesColor{clr, clr2};
                            colorName = classesColorName{clr, clr2};
                            break;
                        end
                    end
                end
            end
            
            hold on;
            corrMatrixForROI(corrIndexMatrix, :) = [roiTreeDistanceMatrix(index, secIndex), roiActivityDistanceMatrix(index, secIndex)];
            corrIndexMatrix = corrIndexMatrix + 1;
            scatter(roiTreeDistanceMatrix(index, secIndex), roiActivityDistanceMatrix(index, secIndex), 'filled', 'MarkerFaceColor', color);
            
            resultsT.(colorName)(end + 1, :) = [roiTreeDistanceMatrix(index, secIndex), roiActivityDistanceMatrix(index, secIndex)];
        end
    end

    legend(leg, legColor);
%     ylim([0,1]);
       
    mysave(fig, [outputpath, '\ActivityDistVSDendriticDistForROI_' roiActivityDistanceFunction ,'_eventsSize', roiActivityPeakSize, '_numofTreeDepth', num2str(length(classesM))]);
    
    f_name = fieldnames(resultsT);
    for t = 1:length(f_name)
        writetable(array2table(resultsT.(f_name{t})),fullfile(outputpath, ['ActivityDistVSDendriticDistForROI_asTable_part_' num2str(t) '_numofTreeDepth', num2str(length(classesM)) '.xls']),'Sheet',f_name{t});
    end
    
    
    %     coutI = 1;
    nodesColor = zeros(length(gRoi.Nodes.Name),3);
    for clr = 1:length(classesM)
        for i = 1:length(mainTreeBranchROI)
            if mainTreeBranchROI(i) == classesM(clr)
                locRoi = find(strcmp(gRoi.Nodes.Name, selectedRoi(i)));
                nodesColor(locRoi, :) = classesColor{clr, clr};
%                 coutI = coutI + 1;
            end
        end
    end
     
    figGraph = figure;
    plot(gRoi, 'EdgeLabel',gRoi.Edges.Weight, 'NodeColor', nodesColor);
    mysave(figGraph, [outputpath, '\GraphWithROI_' num2str(length(classesM))]);
   
    
    if do_corrtest            
    %     Cals positive corr between ROI tree and activity distance
         [RHO,PVAL] = corr(corrMatrixForROI,'type','Pearson');
         [RHO_InsideTheMainBranch,PVAL_InsideTheMainBranch] = corr(corrMatrixForROIInsideTheMainBranch,'type','Pearson');

        save([outputpath, '\CorrEventsDistVSDendriticDist_' roiActivityDistanceFunction ,'_eventsSize', roiActivityPeakSize, '_numofTreeDepth', num2str(length(classesM))], 'RHO', 'PVAL', 'RHO_InsideTheMainBranch', 'PVAL_InsideTheMainBranch');
    end  
end