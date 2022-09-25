mantelRunnerLocation = '\\jackie-analysis\e\Shay\RunnersLocationSummary.xlsx';
sheetName = 'RunOnlyTuftPrecentageType1';
tableResults1 = readtable(mantelRunnerLocation,'Sheet',sheetName);
sheetName = 'RunOnlyTuftPrecentageType2';
tableResults2 = readtable(mantelRunnerLocation,'Sheet',sheetName);
outputfolder = '\\jackie-analysis\e\Shay\StatisticSummary\ByPrecentage_new\';

Mantel(1) = {[tableResults1.R_cluster1,tableResults1.R_cluster2,tableResults1.R_cluster3,tableResults1.R_cluster4]};
Mantel(2) = {[tableResults2.R_cluster1,tableResults2.R_cluster2,tableResults2.R_cluster3,tableResults2.R_cluster4]};

f = figure;hold on;
title('R2')
groupsBox1 = {};
groupsBox1(end+1:end+size(Mantel{1}, 1)) = {'Big-Cluster1'};
groupsBox1(end+1:end+size(Mantel{1}, 1)) = {'Big-Cluster2'};
groupsBox1(end+1:end+size(Mantel{1}, 1)) = {'Big-Cluster3'};
groupsBox1(end+1:end+size(Mantel{1}, 1)) = {'Big-Cluster4'};
groupsBox2 = {};
groupsBox2(end+1:end+size(Mantel{2}, 1)) = {'Small-Cluster1'};
groupsBox2(end+1:end+size(Mantel{2}, 1)) = {'Small-Cluster2'};
groupsBox2(end+1:end+size(Mantel{2}, 1)) = {'Small-Cluster3'};
groupsBox2(end+1:end+size(Mantel{2}, 1)) = {'Small-Cluster4'};

meanAll(1:4) = mean(Mantel{1});
meanAll(5:8) = mean(Mantel{2});

bC = boxchart(categorical(groupsBox1),[Mantel{1}(:,1); Mantel{1}(:,2); Mantel{1}(:,3); Mantel{1}(:,4)]);

bC2 = boxchart(categorical(groupsBox2),[Mantel{2}(:,1); Mantel{2}(:,2); Mantel{2}(:,3); Mantel{2}(:,4)]);


bC.BoxFaceColor = [0,0,0];
bC.BoxFaceAlpha = 0.4;
bC.MarkerColor = [0,0,0];
bC2.BoxFaceColor = [0,0,255] ./ 255;
bC2.MarkerColor = [0,0,255] ./ 255;
bC2.BoxFaceAlpha = 0.4;

plot(meanAll, '-*k');

mysave(f, fullfile(outputfolder, 'R2_All_BigAndSmall'));

[p1, h1] = ranksum(Mantel{1}(:,1),  Mantel{2}(:,1));
[p2, h2] = ranksum(Mantel{1}(:,2),  Mantel{2}(:,2));
[p3, h3] = ranksum(Mantel{1}(:,3),  Mantel{2}(:,3));
[p4, h4] = ranksum(Mantel{1}(:,4), Mantel{2}(:,4));

text = '';
text = strcat(text, sprintf('Cluster1 h1 %f, p %f \\n', h1,p1));
text = strcat(text, sprintf('Cluster2 h1 %f, p %f \\n', h2,p2));
text = strcat(text, sprintf('Cluster3 h1 %f, p %f \\n', h3,p3));
text = strcat(text, sprintf('Cluster4 h1 %f, p %f \\n', h4,p4));

fid=fopen(fullfile(outputfolder, 'statisticranksumR2SmallVsBig.txt'),'w');
fprintf(fid, text);
fclose(fid);



% ////////////////////////////////////////////////////////////////////////////////////////////////////

arrayT = [tableResults2.R_cluster1,tableResults2.R_cluster2,tableResults2.R_cluster3,tableResults2.R_cluster4];
ylabelName = 'Slope';
colorType = [0,0,0];
TitleV = 'Slope';
f = figure; hold on;
b = boxchart(arrayT);
ylim([0,1]);
xticklabels({'Cluster1', 'Cluster2', 'Cluster3', 'Cluster4'});
b.BoxFaceColor = colorType;
b.BoxFaceAlpha = 0.4;
b.MarkerColor = colorType;
ylabel(ylabelName);
plot(mean(arrayT), '-*k');
mysave(f, fullfile(outputfolder, TitleV));
mResult = mean(arrayT);
stdR = std(arrayT);
textAnova = '';

textAnova = strcat(textAnova, sprintf('cluster1 mean: %.4f, std: %.4f \\n ', mResult(1), stdR(1)));
textAnova = strcat(textAnova, sprintf('cluster2 mean: %.4f, std: %.4f \\n ', mResult(2), stdR(2)));
textAnova = strcat(textAnova, sprintf('cluster3 mean: %.4f, std: %.4f \\n ', mResult(3), stdR(3)));
textAnova = strcat(textAnova, sprintf('cluster4 mean: %.4f, std: %.4f \\n ', mResult(4), stdR(4)));             

fid=fopen(fullfile(outputfolder, ['summaryMandstd_', TitleV,'.txt']),'w');
fprintf(fid, textAnova);
fclose(fid);

textAnova = '';
[p,~,statsM] = anova1(arrayT, {'Cluster1', 'Cluster2', 'Cluster3', 'Cluster4'}, 'off');
if p < 0.05
    [c,~,~,groupnames] = multcompare(statsM, 'Display', 'off');
    for j = 1:size(c, 1)
        textAnova = strcat(textAnova, sprintf('%s vs %s - pValue : %.4f, mean Diff : %.4f, CI_L : %.4f, CI_H : %.4f \\n ', ...
            groupnames{c(j, 1)}, groupnames{c(j, 2)}, c(j, 6), c(j, 4), c(j, 3), c(j, 5)));
    end
end

fid=fopen(fullfile(outputfolder, ['statistic_', TitleV,'.txt']),'w');
fprintf(fid, textAnova);
fclose(fid);

% //////////////////////////////

for i = 1:size(tableResults, 1)
    cluster1File = [tableResults.RunLocation{i}, '\cluster1\ByP\BetweenAndWithinSubTrees\AVSD*_Depth2_*.csv'];
    fileList = dir(cluster1File);
    xVals = [];
    yVals = [];
    for j = 1:size(fileList, 1)
        tableR = readtable(fullfile(fileList(j).folder,fileList(j).name));
        xVals(end+1:end+length(tableR.Var1)) = tableR.Var1;
        yVals(end+1:end+length(tableR.Var2)) = tableR.Var2;
    end

    mdAll1 = fitglm(xVals ./ max(xVals), yVals);
    tableResults.b1_cluster1((i)) = mdAll1.Coefficients.Estimate(2);
    tableResults.R_cluster1((i)) = mdAll1.Rsquared.Ordinary;
    
    
    cluster2File = [tableResults.RunLocation{(i)}, '\cluster2\ByP\BetweenAndWithinSubTrees\AVSD*_Depth2_*.csv'];
    fileList = dir(cluster2File);
    xVals = [];
    yVals = [];
    for j = 1:size(fileList, 1)
        tableR = readtable(fullfile(fileList(j).folder,fileList(j).name));
        xVals(end+1:end+length(tableR.Var1)) = tableR.Var1;
        yVals(end+1:end+length(tableR.Var2)) = tableR.Var2;
    end
    mdAll1 = fitglm(xVals ./ max(xVals), yVals);

    tableResults.b1_cluster2((i)) = mdAll1.Coefficients.Estimate(2);
    tableResults.R_cluster2((i)) = mdAll1.Rsquared.Ordinary;

    cluster3File = [tableResults.RunLocation{(i)}, '\cluster3\ByP\BetweenAndWithinSubTrees\AVSD*_Depth2_*.csv'];
    fileList = dir(cluster3File);

    xVals = [];
    yVals = [];
    for j = 1:size(fileList, 1)
        tableR = readtable(fullfile(fileList(j).folder,fileList(j).name));

        xVals(end+1:end+length(tableR.Var1)) = tableR.Var1;
        yVals(end+1:end+length(tableR.Var2)) = tableR.Var2;
    end
    mdAll1 = fitglm(xVals ./ max(xVals), yVals);

    tableResults.b1_cluster3((i)) = mdAll1.Coefficients.Estimate(2);
    tableResults.R_cluster3((i)) = mdAll1.Rsquared.Ordinary;

    cluster4File = [tableResults.RunLocation{(i)}, '\cluster4\ByP\BetweenAndWithinSubTrees\AVSD*_Depth2_*.csv'];
    fileList = dir(cluster4File);

    xVals = [];
    yVals = [];

    for j = 1:size(fileList, 1)
        tableR = readtable(fullfile(fileList(j).folder,fileList(j).name));

        xVals(end+1:end+length(tableR.Var1)) = tableR.Var1;
        yVals(end+1:end+length(tableR.Var2)) = tableR.Var2;
    end

    mdAll1 = fitglm(xVals ./ max(xVals), yVals);
    b1_cluster4 = mdAll1.Coefficients.Estimate(2);

    tableResults.b1_cluster4((i)) = mdAll1.Coefficients.Estimate(2);
    tableResults.R_cluster4((i)) = mdAll1.Rsquared.Ordinary;
end

% ////////////////////

for i = 1:size(tableResults, 1)
    clusterImageLocation = tableResults.RunLocation{i};
    clusterV = '\\cluster%d\\ByP\\BetweenAndWithinSubTrees\\DistMatrixActivity_WindoEventToPeakPearson_eventsSizecluster%d.fig';
    distaneImageLocation = '\DistMatrixROIStructure.fig';

    for ci = 1:4
        f = openfig([clusterImageLocation, sprintf(clusterV, ci, ci)]);
        f2 = openfig([clusterImageLocation, distaneImageLocation]);

        DataActivity = f.Children(2).Children(1).CData;
        DataStacture = f2.Children(2).Children(1).CData;

        if sum(isnan(DataActivity), 'all') < (size(DataActivity(:), 1) - size(DataActivity, 1)) && ...
           sum((DataActivity < 0), 'all') < (size(DataActivity(:), 1) - size(DataActivity, 1)) && ...
           size(DataActivity, 1) > 2


           roiActivityDistanceMatrixByHNO_nan = DataActivity;
           roiActivityDistanceMatrixByHNO_nan(isnan(DataActivity)) = 0;
           roiActivityDistanceMatrixByHNO_nan(DataActivity < 0) = 0;

           [outM, pValM] = bramila_mantel(1 - abs(roiActivityDistanceMatrixByHNO_nan), DataStacture, 5000, 'pearson');
        else
           outM  = 0;
           pValM = 1;
        end
        

        tableResults.(sprintf('MantelVcluster%d', ci))(i) = outM;
        tableResults.(sprintf('MantelPcluster%d', ci))(i) = pValM;

        close all;
    end
end