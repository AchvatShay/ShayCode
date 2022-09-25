% correlation test

clear all;

TPAFolder = '\\jackie-analysis\F\Layer II-III\Analysis\Bas-M2-Sa1\08.15.22-N1-ETL\';
SWCFIle = '\\jackie-analysis\F\Layer II-III\Analysis\Bas-M2-Sa1\08.15.22-N1-ETL\swcFiles\neuron_1.swc';
outputpath = '\\jackie-analysis\F\Layer II-III\Analysis\Bas-M2-Sa1\08.15.22-N1-ETL\Results\N1\ActivityVsStructure_new6\';

somaROIName = 'roi00022';

tuftRoisNames = 1:10;
basalRoisNames = 11:21;

tuftIndexRoi = [];
basalIndexRoi = [];

tuftdepth = 4;
basaldepth = 2;

excludeRoi = [];

mkdir(outputpath);
mkdir([outputpath, '\subGroups']);

[gRoi, rootNodeID, selectedROITable] = loadSwcFile(SWCFIle, outputpath, false);
selectedROITable = sortrows(selectedROITable, 2);

for i = 1:length(excludeRoi)
    ex_results = contains(selectedROITable.Name, sprintf('roi%05d', excludeRoi(i)));

    if sum(ex_results) == 1
        selectedROITable(ex_results, :) = [];
    end
end

for i = 1:size(selectedROITable, 1)
    currR = find(tuftRoisNames == sscanf(selectedROITable.Name{i}, 'roi%05d'), 1);  
    if ~isempty(currR)
        tuftIndexRoi(end+1) = i;
    end
    currR = find(basalRoisNames == sscanf(selectedROITable.Name{i}, 'roi%05d'), 1);  
    if ~isempty(currR)
        basalIndexRoi(end+1) = i;
    end
end


selectedROI = selectedROITable.Name;

selectedROIWithSoma = selectedROI;
selectedROIWithSoma(end+1) = {somaROIName};
[roiActivity, roiActivityNames, tr_frame_count] = loadActivityFileFromTPA(TPAFolder, selectedROIWithSoma, outputpath);


distFromSoma = zeros(1, length(selectedROI));
for i = 1:length(selectedROI)
    [~, distFromSoma(i)] = shortestpath(gRoi, selectedROITable.ID(i), rootNodeID, 'Method', 'positive');
    corrValue = corr([roiActivity(:, i), roiActivity(:, end)]);
    matrixAllActivity(i) = corrValue(1, 2);
     
    if any(tuftIndexRoi == i)
        distFromSoma(i) = distFromSoma(i) * -1;
    end
end

selectedROISplitDepth2 = ones(length(selectedROI), 1) * -1;
selectedROISplitDepth2 = getSelectedROISplitBranchID(gRoi, tuftdepth, selectedROISplitDepth2, selectedROI, rootNodeID);
selectedROISplitDepth2(basalIndexRoi) = -1;
selectedROISplitDepth2 = getSelectedROISplitBranchID(gRoi, basaldepth, selectedROISplitDepth2, selectedROI, rootNodeID);

classesSplit = unique(selectedROISplitDepth2);
classesSplit(classesSplit == -1) = 1;
selectedROISplitDepth2(selectedROISplitDepth2 == -1) = 1;

colorMatrix1 = zeros(length(selectedROISplitDepth2), 3);
indexLabel = cell(length(selectedROISplitDepth2), 1);
for d_i = 1:length(selectedROISplitDepth2)
    if selectedROISplitDepth2(d_i) == -1
        colorMatrix1(d_i, :) = [0,0,0];
    else
        colorMatrix1(d_i, :) = getTreeColor('within', find(classesSplit == selectedROISplitDepth2(d_i)), true);
    end
    
    indexLabel(d_i) = gRoi.Nodes.Name(selectedROISplitDepth2(d_i));
end


f = figure;
scatter(distFromSoma,matrixAllActivity, 'filled', 'SizeData', 30, 'CData', colorMatrix1);
hold on;
titleToFig = {};
titleToFig(1) = {'Pearson correlation from soma'};

if ~isempty(tuftIndexRoi)
    mdAll_tuft = fitglm(distFromSoma(tuftIndexRoi)',matrixAllActivity(tuftIndexRoi)');
    yfitAll_tuft = predict(mdAll_tuft, distFromSoma(tuftIndexRoi)');
    plot(distFromSoma(tuftIndexRoi)', yfitAll_tuft, 'LineWidth', 1, 'Color', [0,0,0]);
    titleToFig(end+1) = {sprintf('Tuft R2 = %03f', mdAll_tuft.Rsquared.Adjusted)}; 
end

if ~isempty(basalIndexRoi)
    mdAll_B = fitglm(distFromSoma(basalIndexRoi)',matrixAllActivity(basalIndexRoi)');
    yfitAll_B = predict(mdAll_B, distFromSoma(basalIndexRoi)');
    plot(distFromSoma(basalIndexRoi)', yfitAll_B, 'LineWidth', 1, 'Color', [0,0,0]);
    titleToFig(end+1) = {sprintf('Basal R2 = %03f', mdAll_B.Rsquared.Adjusted)};
end

ylim([0,1]);
title(titleToFig);
xlabel('dist from soma');
ylabel('Correlation');

mysave(f, [outputpath, 'CorrelationvsDistanceFromSoma']);

f = figure;
hold on;
title('Correlation To Soma Group by structure');
for i = 1:length(classesSplit)
    boxchart(categorical(indexLabel(selectedROISplitDepth2 == classesSplit(i))),matrixAllActivity(selectedROISplitDepth2 == classesSplit(i)), 'BoxFaceColor', getTreeColor('within', i, true));
end
ylabel('Correlation');
ylim([0,1]);
mysave(f, [outputpath, 'CorrelationFromSomaBoxPlotByGroup']);
