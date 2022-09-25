function BoxPlotFromXls()
    outputpath = '\\jackie-analysis\e\TestShay\';
    outputfileName = 'fig3B_scaterplotsT';
    
    inputDataLocation = '\\jackie-analysis\e\TestShay\fig3B_scaterplots.xlsx';
    inputDataShitName = 'fig3B_scaterplot';
    
%     mainSubTypes = {'intralayer', 'interlayer'};
%     coloredSubTypes = {'Spontanous', 'Evoked'};
%     coloredSubColors = [192,205,234;255,128,128] ./ 255;
    
%     mainSubTypes = {'Piezzo', 'Artifical whisking'};
%     coloredSubTypes = {'Spontanous', 'Evoked'};
%     coloredSubColors = [170,170,170;255,128,128] ./ 255;

%      mainSubTypes = {'Artifical whisking'}; 
%      coloredSubTypes = {'Spontanous', 'Evoked'};
%     coloredSubColors = [192,205,234;255,128,128] ./ 255;
    
%      mainSubTypes = {'Ratio'}; 
%      coloredSubTypes = {'intralayer', 'interlayer'};
%     coloredSubColors = [170,170,170;170,170,170] ./ 255;
    
     mainSubTypes = {'Ratio'}; 
     coloredSubTypes = {'L2 3','L4','L5'};
    coloredSubColors = [170,170,170;170,170,170;170,170,170] ./ 255;
    

    %Pearson
%     titleFig = "Pearson's coeficient";
%     ylimFig = [0,0.5];
%     ylableFig = "Pearson's correlation coeficient";
% 

% %         ------Conectivity index-------
        titleFig = "";
        ylimFig = [0,1];
        ylableFig = "Relative desynchronization";
    
%         ------Conectivity index-------
%         titleFig = "Connectivity index";
%         ylimFig = [0,800];
%         ylableFig = "Distance";
        
        boxfacevalue = 0.5;
%   -----------------------------------------
%   Code
%   -----------------------------------------

    tableData = readtable(inputDataLocation, 'Sheet', inputDataShitName);
    
    f = figure; hold on;
    f.Color = [1,1,1];
    % Create line
    annotation(f,'line',[0.52 0.52],[0.1,0.9], 'LineStyle', '--');
    
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
            b.BoxFaceAlpha=boxfacevalue;
           
            hold on;
        end
    end 
    
    yl.Position(1) = 0.13;
    mysave(f, fullfile(outputpath, outputfileName));
end