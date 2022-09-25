function BoxPlotFromXls()
    outputpath = '\\jackie-analysis\e\TestShay\';
    outputfileName = 'PanelH_connectivity';
    
    inputDataLocation = '\\jackie-analysis\e\TestShay\figure 1 tables_for scatterplots creation.xlsx';
    inputDataShitName = 'panel h-connectivity index';
    
    mainSubTypes = {'Piezzo', 'Artifical whisking'};
    coloredSubTypes = {'Spontanous', 'Evoked'};
    coloredSubColors = [170,170,170;255,128,128] ./ 255;
    
    isPearson = 0;
    
    %Pearson
    if isPearson
        titleFig = "Pearson's coeficient";
        ylimFig = [0,1];
        ylableFig = "Pearson's correlation coeficient";
    else
        titleFig = "Connectivity index";
        ylimFig = [0,1];
        ylableFig = "Connectivity index";
    end

%   -----------------------------------------
%   Code
%   -----------------------------------------

    tableData = readtable(inputDataLocation, 'Sheet', inputDataShitName);
    
    f = figure; hold on;
    f.Color = [1,1,1];
    % Create line
    annotation(f,'line',[0.52 0.52],[ylimFig(1)+0.1, ylimFig(2)-0.1], 'LineStyle', '--');
    
    sgtitle(titleFig);   
    for i = 1:length(mainSubTypes) 
        sb = subplot(1, length(mainSubTypes), i);
        ylim(ylimFig);
        
        if i ~= 1
            sb.YColor = [1,1,1];
        else
            yl = ylabel(ylableFig);
        end
        
        hold on;
        title(mainSubTypes{i});
        for j = 1:length(coloredSubTypes)
            varName = contains(tableData.Properties.VariableNames, replace(mainSubTypes{i}, ' ', ''),'IgnoreCase',true) & contains(tableData.Properties.VariableNames, coloredSubTypes{j},'IgnoreCase',true);
            groupsBox1(1:size(tableData,1)) = coloredSubTypes(j);
            meanR = mean(tableData.(tableData.Properties.VariableNames{varName}), 'omitnan');
            b = boxchart(categorical(groupsBox1), tableData.(tableData.Properties.VariableNames{varName}));
            scatter(categorical(coloredSubTypes(j)), meanR, '*', 'MarkerEdgeColor', coloredSubColors(j,:));
            b.BoxFaceColor = coloredSubColors(j,:);
            b.MarkerColor = coloredSubColors(j,:);
           
            hold on;
        end
    end 
    
    yl.Position(1) = 0.13;
    mysave(f, fullfile(outputpath, outputfileName));
end