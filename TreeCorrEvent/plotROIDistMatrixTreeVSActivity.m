function pictureNames = plotROIDistMatrixTreeVSActivity(event_count, gRoi, outputpath, firstBranchROI,mainTreeBranchROI, roiTreeDistanceMatrix, roiActivityDistanceMatrix, do_corrtest, roiActivityDistanceFunction, roiActivityPeakSize, selectedRoi, index_apical, distType, clusterType)
    classesM = unique(mainTreeBranchROI);
    classesF = unique(firstBranchROI);
      
    
    nodesColor = zeros(length(gRoi.Nodes.Name),3);
    tempC = zeros(length(classesM(classesM ~= -1)), 3);
    tempC_2 = zeros(length(classesF(classesF ~= -1)), 3);
    
    be_c = getTreeColor('between');
    ma_c = getTreeColor('main');
    
    tempC(:, 1) = be_c(:, 1);
    tempC(:, 2) = be_c(:, 2);
    tempC(:, 3) = be_c(:, 3);
    
    tempC_2(:, 1) = ma_c(:, 1);
    tempC_2(:, 2) = ma_c(:, 2);
    tempC_2(:, 3) = ma_c(:, 3);
     
    for clr = 1:length(classesM)
        for i = 1:length(mainTreeBranchROI)
            if mainTreeBranchROI(i) == classesM(clr) && classesM(clr) ~= -1
                locRoi = find(strcmp(gRoi.Nodes.Name, selectedRoi(i)));
                nodesColor(locRoi, :) = getTreeColor('within', (clr));
%                 coutI = coutI + 1;
            end
        end
    end
    
    nodesColor(classesM(classesM ~= -1), :) = tempC;
    nodesColor(classesF(classesF ~= -1), :) = tempC_2;
     
    titlePG = {'Number of subtree ', num2str(length(classesM))};
    fileName2 = [outputpath, '\GraphWithROI_' num2str(length(classesM))];
    plotGraphWithROI(gRoi, fileName2, nodesColor, titlePG)
 
    
    %     Plot ROI Activity VS Tree Distance
    fig = figure;
    hold on;
    % Create ylabel
    ylabel({'Calcium Event ' distType, ['(', num2str(event_count),')']});

    % Create xlabel
    xlabel({'Dendritic distance'});

    title({'ROI Activity VS Tree Distance'});
%     leg = zeros(3, 1);
    leg = [];
%     legColor = []; 
    
    
    index_classes = 1;   
    classesColorName = {};

    for index = 1: size(roiTreeDistanceMatrix, 2)
        for secIndex = (index + 1): size(roiTreeDistanceMatrix, 2)
            
            fMainName = 'ND';
            secMainName = 'ND';
            
            fFirstName = 'ND';
            secFirstName = 'ND';
            
            if mainTreeBranchROI(index) ~= -1
                fMainName = gRoi.Nodes(mainTreeBranchROI(index),:).Name{1};
            end
            
            if mainTreeBranchROI(secIndex) ~= -1
                secMainName = gRoi.Nodes(mainTreeBranchROI(secIndex),:).Name{1};
            end
            
            if firstBranchROI(index) ~= -1
                fFirstName = gRoi.Nodes(firstBranchROI(index),:).Name{1};
            end
            
            if firstBranchROI(secIndex) ~= -1
                secFirstName = gRoi.Nodes(firstBranchROI(secIndex),:).Name{1};
            end
            
            if strcmp(fFirstName, 'ND') || strcmp(secFirstName, 'ND')
                color = getTreeColor('ND', -1);
                colorName = {'NotInDepth'};
            elseif ~strcmp(fFirstName, secFirstName)
                colorName = {'BetweenMainDepth'};
                color = getTreeColor('main');
            elseif strcmp(fMainName, 'ND') || strcmp(secMainName, 'ND')
                color = getTreeColor('ND', -1);
                colorName = {'NotInDepth'};
            elseif ~strcmp(fMainName, secMainName)
                colorName = {'BetweenSecondDepth'};
                color = getTreeColor('between');
            else
                color = getTreeColor('within', find(classesM == mainTreeBranchROI(index)));
                colorName = {fMainName};
            end
               
            hold on;
            
            if sum((index_apical == index) | (index_apical == secIndex)) > 0
                scat = scatter(roiTreeDistanceMatrix(index, secIndex), roiActivityDistanceMatrix(index, secIndex), '*', 'MarkerEdgeColor', color);
            else
                scat = scatter(roiTreeDistanceMatrix(index, secIndex), roiActivityDistanceMatrix(index, secIndex), 20, 'filled', 'MarkerFaceColor', color);
            end
            
            scat.set('UserData', [selectedRoi{index} 'x' selectedRoi{secIndex}])

            colorName = colorName{1};
            colorName = replace(colorName,{'&','-', '_'}, 'x'); 
                
            if isempty(classesColorName) || ...
                    (sum(strcmp(classesColorName, colorName)) == 0)
                classesColorName(index_classes) = {colorName};
                classesColor(index_classes) = {color};
                
                leg(index_classes) = plot(0,0, 'color', color, 'LineWidth', 2.5);
                legColor(index_classes) = {colorName};
                
                resultsT.(colorName) = [];
                index_classes = index_classes + 1;
            end
            
                
            resultsT.(colorName)(end + 1, :) = [roiTreeDistanceMatrix(index, secIndex), roiActivityDistanceMatrix(index, secIndex)];
        end
    end

    dcm_obj = datacursormode(fig);
    set(dcm_obj,'UpdateFcn',{@myupdatefcn})
    
    legend(leg, legColor);
    legend('Location','bestoutside')
    fig.Position = [fig.Position(1), fig.Position(2), fig.Position(3) + 200, fig.Position(4) + 100];
    roiwithstar = '*';
    
    for in = 1:length(index_apical)
       roiwithstar = [roiwithstar ' ' selectedRoi{index_apical(in)}]; 
    end
    
    annotation('textbox', [0, 0.2, 0, 0], 'string', roiwithstar, 'FitBoxToText','on')
%     ylim([0,1]);
       
    fileName1 = [outputpath, '\ActivityDistVSDendriticDistForROI_' roiActivityDistanceFunction ,'_eventsSize', roiActivityPeakSize, '_numofTreeDepth', num2str(length(classesM))];
    mysave(fig, fileName1);

    plotAndCalcStatisticTest(classesColorName, classesColor, resultsT, leg, legColor, outputpath, classesM, clusterType, roiActivityPeakSize, distType);
 
% ------------------------------------------------------------------------------
    f_name = fieldnames(resultsT);
    for t = 1:length(f_name)
        if isempty(resultsT.(f_name{t}))
            continue;
        end
        
        writetable(array2table(resultsT.(f_name{t})),fullfile(outputpath, ['ActivityVSDendriticForROI_' num2str(t) '_Depth', num2str(length(classesM)) '.xls']),'Sheet',f_name{t});
    end
    
    %     coutI = 1;
    pictureNames = {fileName1, fileName2};
    
    snapnow;
    fclose('all');
    close all;
    clear resultsT;
end