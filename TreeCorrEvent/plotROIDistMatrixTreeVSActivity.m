function plotROIDistMatrixTreeVSActivity(gRoi, outputpath, mainTreeBranchROI, roiTreeDistanceMatrix, roiActivityDistanceMatrix, do_corrtest, roiActivityDistanceFunction, roiActivityPeakSize)
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
    legColor = []; 
    classesM = unique(mainTreeBranchROI);
    
    for index = 1:length(classesM)     
        for secIndex = index:length(classesM)
            classesColor(index, secIndex) = {rand(3,1)};
            leg(end+1) = plot(0,0, 'color', classesColor{index, secIndex}, 'LineWidth', 2.5);
            
            
            if (classesM(index) == -1 && classesM(secIndex) == -1)
                legColor{end + 1} = 'NotInDepth&NotInDepth';
            elseif (classesM(index) == -1 && classesM(secIndex) ~= -1)
                nameSecIndex = gRoi.Nodes(classesM(secIndex),:).Name{1};
                nameSecIndex(nameSecIndex == '_') = '-';

                legColor{end + 1} = [nameSecIndex '&NotInDepth'];
            elseif (classesM(index) ~= -1 && classesM(secIndex) == -1)
                nameIndex = gRoi.Nodes(classesM(index),:).Name{1};
                nameIndex(nameIndex == '_') = '-';
            
                legColor{end + 1} = [nameIndex '&NotInDepth'];
            else
                nameIndex = gRoi.Nodes(classesM(index),:).Name{1};
                nameIndex(nameIndex == '_') = '-';
                nameSecIndex = gRoi.Nodes(classesM(secIndex),:).Name{1};
                nameSecIndex(nameSecIndex == '_') = '-';

                legColor{end + 1} = [nameIndex '&' nameSecIndex];
            end
        end
    end
    
    corrIndexMatrix = 1;   
    corrIndexMatrixInsideMainBranch = 1;
    for index = 1: size(roiTreeDistanceMatrix, 2)
        for secIndex = (index + 1): size(roiTreeDistanceMatrix, 2)
            for clr = 1:length(classesM)
                if (mainTreeBranchROI(index) == mainTreeBranchROI(secIndex) && mainTreeBranchROI(secIndex) == classesM(clr))
                    color = classesColor{clr, clr};
                    corrMatrixForROIInsideTheMainBranch(corrIndexMatrixInsideMainBranch, :) = [roiTreeDistanceMatrix(index, secIndex), roiActivityDistanceMatrix(index, secIndex)];
                    corrIndexMatrixInsideMainBranch = corrIndexMatrixInsideMainBranch + 1;
                    break;
                else
                    for clr2 = clr:length(classesM)
                        if (mainTreeBranchROI(index) == classesM(clr) && mainTreeBranchROI(secIndex) == classesM(clr2)) || ...
                                (mainTreeBranchROI(index) == classesM(clr2) && mainTreeBranchROI(secIndex) == classesM(clr))
                            color = classesColor{clr, clr2};
                            break;
                        end
                    end
                end
            end
            
            hold on;
            corrMatrixForROI(corrIndexMatrix, :) = [roiTreeDistanceMatrix(index, secIndex), roiActivityDistanceMatrix(index, secIndex)];
            corrIndexMatrix = corrIndexMatrix + 1;
            scatter(roiTreeDistanceMatrix(index, secIndex), roiActivityDistanceMatrix(index, secIndex), 'filled', 'MarkerFaceColor', color);
        end
    end

    legend(leg, legColor);
    
    mysave(fig, [outputpath, '\ActivityDistVSDendriticDistForROI_' roiActivityDistanceFunction ,'_eventsSize', roiActivityPeakSize, '_numofTreeDepth', num2str(length(classesM))]);
    
    
    if do_corrtest            
    %     Cals positive corr between ROI tree and activity distance
         [RHO,PVAL] = corr(corrMatrixForROI,'type','Pearson');
         [RHO_InsideTheMainBranch,PVAL_InsideTheMainBranch] = corr(corrMatrixForROIInsideTheMainBranch,'type','Pearson');

        save([outputpath, '\CorrEventsDistVSDendriticDist_' roiActivityDistanceFunction ,'_eventsSize', roiActivityPeakSize, '_numofTreeDepth', num2str(length(classesM))], 'RHO', 'PVAL', 'RHO_InsideTheMainBranch', 'PVAL_InsideTheMainBranch');
    end
end