function pictureNames = plotROIDistMatrixTreeVSActivity(event_count, gRoi, outputpath, firstBranchROI,mainTreeBranchROI, roiTreeDistanceMatrix, roiActivityDistanceMatrix, do_corrtest, roiActivityDistanceFunction, roiActivityPeakSize, selectedRoi, index_apical, distType)
    if nargin < 13
        distType = 'Correlation';
    end

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
    classesM = unique(mainTreeBranchROI);
    classesF = unique(firstBranchROI);
    
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
                scat = scatter(roiTreeDistanceMatrix(index, secIndex), roiActivityDistanceMatrix(index, secIndex), 'filled', 'MarkerFaceColor', color);
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
    legend('Location','northwestoutside')
    
    roiwithstar = '*';
    
    for in = 1:length(index_apical)
       roiwithstar = [roiwithstar ' ' selectedRoi{index_apical(in)}]; 
    end
    
    annotation('textbox', [0, 0.2, 0, 0], 'string', roiwithstar, 'FitBoxToText','on')
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
    colorsG = [];
    anovaY = [];
    anovaGr = {};
    indexGroup = 1;
    for clr1 = 1:length(classesColorName)
        tempR = resultsT.(classesColorName{clr1});

        if isempty(tempR)
            continue;
        end

        anovaY((end+1):(end+ size(tempR, 1))) = tempR(:, 2);
        anovaGr((end+1):(end+ size(tempR, 1))) = classesColorName(clr1);
        
        matR = [matR; tempR(:,2)];
        groupR = [groupR; ones(size(tempR(:,2)))*indexGroup];

        indexGroup = indexGroup + 1;

        labelsR{end + 1} = classesColorName{clr1};
        colorsG(end+1, :) = classesColor{clr1};
    end
    
    boxplot(matR, groupR, 'Labels', labelsR, 'Colors', colorsG);        
    xtickangle(90);   
    
    fileName4 = [outputpath, '\DendriticDistVSActivityDistForROIBOXPlot_' roiActivityDistanceFunction ,'_eventsSize', roiActivityPeakSize, '_numofTreeDepth', num2str(length(classesM))];
    mysave(fig3, fileName4);
%     --------------------------------------------------------------------------
%  Ttest Results
    formatSpec = '\n SubTrees compared: %s vs %s, ttest results: \n h = %d, pValue = %d \n\r\n ';
    ttest_results_str = '';
    
    params.sig = -1;
    params.bootForce = 1;
    params.shuff = 10;
    
    for clr1 = 1:length(classesColorName)
        temp_1 = resultsT.(classesColorName{clr1})(:,2);
        for clr2 = (clr1+1):length(classesColorName)
            temp_2 = resultsT.(classesColorName{clr2})(:,2);
            
            [h,p] = ttest2(temp_1, temp_2);
            ttest_results_str = strcat(ttest_results_str,...
                sprintf(formatSpec, classesColorName{clr1}, classesColorName{clr2}, h, p));
            
%             mmd_test_r = mmdTestBoot(temp_1, temp_2, 0.05, params);
        end
    end

    import mlreportgen.ppt.*
    ppt = Presentation([outputpath '\TtestResultsPresentation_numofTreeDepth', num2str(length(classesM))], 'AnalysisTtest.potm');
    open(ppt);
    currentResultsSlide= add(ppt, 'TtestLyout');
    
    replace(currentResultsSlide.Children(2), Picture([fileName4 '.tif']));       
    replace(currentResultsSlide.Children(1), Paragraph(ttest_results_str)); 
    replace(currentResultsSlide.Children(3), Paragraph(['Ttest Results']));       
     
%     ------------------------------------------------------------------------------
%  one way anova

    if (length(labelsR) > 1)
        [~,~,anova_stats] = anova1(anovaY, anovaGr);
        if anova_stats.df ~= 0
            [c,~,h,gnames] = multcompare(anova_stats);
            ttest_results_str = '';

            formatSpecAnova = '\n SubTrees compared: %s vs %s, low_CI = %d mean diff = %d upper_CI = %d pValue = %d \n\r\n ';
            for c_ind = 1:size(c, 1)
                ttest_results_str = strcat(ttest_results_str,...
                        sprintf(formatSpecAnova, gnames{c(c_ind, 1)}, gnames{c(c_ind, 2)}, c(c_ind, 3), c(c_ind, 4), c(c_ind, 5), c(c_ind, 6)));       
            end

            fileName5 = [outputpath, '\DendriticDistVSActivityDistForROIAnovaPlot_' roiActivityDistanceFunction ,'_eventsSize', roiActivityPeakSize, '_numofTreeDepth', num2str(length(classesM))];
            mysave(h, fileName5);

            currentResultsSlide= add(ppt, 'AnovaLyout');

            replace(currentResultsSlide.Children(2), Picture([fileName5 '.tif']));       
            replace(currentResultsSlide.Children(1), Paragraph(ttest_results_str)); 
            replace(currentResultsSlide.Children(3), Paragraph('Anova one way Results')); 
            replace(currentResultsSlide.Children(4), Picture([fileName4 '.tif']));       
        end
    end
    
    close(ppt);
   
% ------------------------------------------------------------------------------
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
      
    plotGraphWithROI(gRoi, fileName2, nodesColor, titlePG)
 
    
    pictureNames = {fileName1, fileName2};
    
    fclose('all');
    close all;
    clear resultsT;
end