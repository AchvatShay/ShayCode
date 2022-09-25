% correlation test

clear all;

TPAFolder = '\\jackie-analysis\F\Layer II-III\Analysis\Bas-M2-Sa1\08.18.22-N1-Tuft\';
SWCFIle = '\\jackie-analysis\F\Layer II-III\Analysis\Bas-M2-Sa1\08.18.22-N1-Tuft\swcFiles\neuron_1.swc';
outputpath = '\\jackie-analysis\F\Layer II-III\Analysis\Bas-M2-Sa1\08.18.22-N1-Tuft\Results\N1\ActivityVsStructure_new3\';

excludeRoi = [];

mkdir(outputpath);
mkdir([outputpath, '\subGroups']);
secDepth = 4;

[gRoi, rootNodeID, selectedROITable] = loadSwcFile(SWCFIle, outputpath, false);

selectedROITable = sortrows(selectedROITable, 2);

for i = 1:length(excludeRoi)
    ex_results = contains(selectedROITable.Name, sprintf('roi%05d', excludeRoi(i)));

    if sum(ex_results) == 1
        selectedROITable(ex_results, :) = [];
    end
end

selectedROI = selectedROITable.Name;

[roiActivity, roiActivityNames, tr_frame_count] = loadActivityFileFromTPA(TPAFolder, selectedROI, outputpath);

selectedROISplitDepth1 = ones(length(selectedROI), 1) * -1;
selectedROISplitDepth1 = getSelectedROISplitBranchID(gRoi, 1, selectedROISplitDepth1, selectedROI, rootNodeID);

selectedROISplitDepth2 = ones(length(selectedROI), 1) * -1;
selectedROISplitDepth2 = getSelectedROISplitBranchID(gRoi, secDepth, selectedROISplitDepth2, selectedROI, rootNodeID);

classesSplit = unique(selectedROISplitDepth2);
classesSplit(classesSplit == -1) = 1;

[roiTreeDistanceMatrix2, roiSortedByCluster2, l2] = calcROIDistanceInTree_ShortestPathType2(gRoi, gRoi.Nodes(classesSplit, :), [outputpath, '\subGroups'], classesSplit, false);

for i = 1:length(classesSplit)
    meanActivity(i, :) = mean(roiActivity(:, selectedROISplitDepth2 == classesSplit(i)), 2);
end

for i = 1:length(classesSplit)
    for j = (i+1):length(classesSplit)
        corrValue = corr([meanActivity(i, :)', meanActivity(j, :)']);
        matrixActivity(i, j) = corrValue(1, 2);
        matrixActivity(j, i) = corrValue(1, 2);
    end
end

figDist = figure;
hold on;
xticks(1:length(classesSplit));
yticks(1:length(classesSplit));
m = imagesc(matrixActivity(roiSortedByCluster2, roiSortedByCluster2));
colorbar
cmap = jet();
colormap(cmap);
namesL = gRoi.Nodes.Name(classesSplit);
yticklabels(namesL(roiSortedByCluster2))
xticklabels(namesL(roiSortedByCluster2))
xtickangle(45);

mysave(figDist, fullfile([outputpath, '\subGroups'], 'correlationSubGroups'));

print(figDist, fullfile([outputpath, '\subGroups'], 'correlationSubGroups'), '-depsc', '-cmyk', '-painters', '-r600');

for i = 1:length(selectedROI)
    for j = (i+1):length(selectedROI)
        corrValue = corr([roiActivity(:, i), roiActivity(:, j)]);
        matrixAllActivity(i, j) = corrValue(1, 2);
        matrixAllActivity(j, i) = corrValue(1, 2);
    end
end

[roiTreeDistanceMatrix, roiSortedByCluster, l] = calcROIDistanceInTree_ShortestPathType2(gRoi, selectedROITable, outputpath, selectedROISplitDepth1, false);


figDist = figure;
hold on;
xticks(1:length(selectedROI));
yticks(1:length(selectedROI));
m = imagesc(matrixAllActivity(roiSortedByCluster, roiSortedByCluster));
colorbar
cmap = jet();
colormap(cmap);
namesL = selectedROI;
yticklabels(namesL(roiSortedByCluster))
xticklabels(namesL(roiSortedByCluster))
xtickangle(45);

mysave(figDist, fullfile(outputpath, 'correlationAll'));
print(figDist, fullfile([outputpath], 'correlationAll'), '-depsc', '-cmyk', '-painters', '-r600');


[pcares.embedding, ~, vals] = pca(roiActivity);
pcares.effectiveDim = max(getEffectiveDim(vals, 0.95), 3);
pcares.eigs = vals;
embedding = pcares.embedding(:,1:2);

[T, ACC2D_depth1] = evalc("svmClassifyAndRand(embedding, selectedROISplitDepth2, selectedROISplitDepth2, 10, '', 1, 0)");

chanceCalc = hist(selectedROISplitDepth2, unique(selectedROISplitDepth2));
chanceCalc = chanceCalc/sum(chanceCalc);

figPCA = figure;
hold on;

leg = [];
for k = 1:length(classesSplit)
    leg(k) = plot(0,0, 'Color', getTreeColor('within',k, true), 'LineWidth', 1.5);
    legColor(k) = gRoi.Nodes.Name(classesSplit(k));
end

colorMatrix1 = zeros(length(selectedROISplitDepth2), 3);
for d_i = 1:length(selectedROISplitDepth2)
     
        if selectedROISplitDepth2(d_i) == -1
            colorMatrix1(d_i, :) = [0,0,0];
        else
            colorMatrix1(d_i, :) = getTreeColor('within', find(classesSplit == selectedROISplitDepth2(d_i)), true);
        end
    
end

for c = 1:length(roiActivityNames)
    
    scatter(pcares.embedding(c, 1), pcares.embedding(c,2), 'filled', 'MarkerEdgeColor', colorMatrix1(c, :), 'MarkerFaceColor', colorMatrix1(c, :), 'SizeData', 20);
end

xlabel('PC1');
ylabel('PC2');
title({sprintf('PCA All'),  sprintf('accuracy mean %f, std %f, chance %f,', ACC2D_depth1.mean, ACC2D_depth1.std, max(chanceCalc))});
legend(leg, legColor);
legend('Location', 'best')

mysave(figPCA, [outputpath, '\PcaResults']);     

