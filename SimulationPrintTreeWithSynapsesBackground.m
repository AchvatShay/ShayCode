 function SimulationPrintTreeWithSynapsesBackground()
    graphR = 'E:\ShayCode\Layer2-3Code\Palmer_et_al Model 2014\Simulation\BackgroundTest_9_020822\treeGraph.mat';
    simTrialResults = 'E:\ShayCode\Layer2-3Code\Palmer_et_al Model 2014\Simulation\BackgroundTest_11_030822\matlab_SimulationRandSynInfoBackG.mat';
    outputPath = 'E:\ShayCode\Layer2-3Code\Palmer_et_al Model 2014\Simulation\BackgroundTest_11_030822\';
    

%     graphR = '\\jackie-analysis\e\ShayCode\pythonProject\larkumEtAl2009_2\Simulation\SM03_N1\4.5_ReconstractExample\treeGraph.mat';
%     simTrialResults = '\\jackie-analysis\e\ShayCode\pythonProject\larkumEtAl2009_2\Simulation\SM03_N1\4.5_ReconstractExample\matlab_SimulationResults_185.mat';
%     outputPath = '\\jackie-analysis\e\ShayCode\pythonProject\larkumEtAl2009_2\Simulation\SM03_N1\4.5_ReconstractExample\';
    
    fName = 'SynDist_00_all';
    load(graphR, 'gRoi');
    load(simTrialResults, 'synSegmentLocation1', 'synSegmentLocation2', 'synSectionName1', 'synSectionName2');
    

    figTree = figure();

       % Create axes
    axes1 = axes('Parent',figTree);
    hold(axes1,'on');

    % Create zlabel
    zlabel({'Z'});

    % Create ylabel
    ylabel({'Y'});

    % Create xlabel
    xlabel({'X'});

    % Create title
    title({'Neuron Tree'});
    view(axes1,[16.146803833781867,26.952301919507775]);
    axes1.CameraViewAngleMode = 'manual';
    axes1.CameraViewAngle = 7.452379366322371;
      
    axes1.XColor = 'None';
    axes1.YColor = 'None';
    axes1.ZColor = 'None';
    figTree.Color = [1,1,1];
    segCount = 9;

%     axes1.ZDir = 'reverse';

    plotTreeNoROIOnlyStruct(gRoi)

    for syn = 1:size(synSegmentLocation2, 1)
        segLocation1 = floor(synSegmentLocation2(syn)*9);
        nameR1 = replace(synSectionName2(syn, :), ' ', '');

        indexSec = find(contains(gRoi.Nodes.Name, nameR1));

        if isempty(indexSec) || length(indexSec) == 1
            continue;
        end

        [~, totalDist] = shortestpath(gRoi, indexSec(1), indexSec(end));
        segJump = 0:(totalDist / segCount):totalDist;

        currentDist = segJump(segLocation1+1);

        sumDist = 0;

        for j = 1:length(indexSec)-1
            idxOut = findedge(gRoi,indexSec(j),indexSec(j+1));
            if sumDist + gRoi.Edges.Weight(idxOut) >= currentDist
                scatter3([gRoi.Nodes.X(indexSec(j))],...
                    [gRoi.Nodes.Z(indexSec(j))],...
                    [gRoi.Nodes.Y(indexSec(j))], 'MarkerFaceColor', [0,0,1], 'MarkerEdgeColor', [0,0,1], 'SizeData', 15, 'MarkerFaceAlpha', 0.5, 'MarkerEdgeAlpha', 0.5);
                break;
            else
                sumDist = sumDist + gRoi.Edges.Weight(idxOut);
                continue;
            end
        end
    end
    
    for syn = 1:size(synSegmentLocation1, 1)
        segLocation1 = floor(synSegmentLocation1(syn)*9);
        nameR1 = replace(synSectionName1(syn, :), ' ', '');

        indexSec = find(contains(gRoi.Nodes.Name, nameR1));

        if isempty(indexSec) || length(indexSec) == 1
            continue;
        end

        [~, totalDist] = shortestpath(gRoi, indexSec(1), indexSec(end));
        segJump = 0:(totalDist / segCount):totalDist;

        currentDist = segJump(segLocation1+1);

        sumDist = 0;

        for j = 1:length(indexSec)-1
            idxOut = findedge(gRoi,indexSec(j),indexSec(j+1));
            if sumDist + gRoi.Edges.Weight(idxOut) >= currentDist
                scatter3([gRoi.Nodes.X(indexSec(j))],...
                    [gRoi.Nodes.Z(indexSec(j))],...
                    [gRoi.Nodes.Y(indexSec(j))], 'MarkerFaceColor', [1,0,0], 'MarkerEdgeColor', [1,0,0], 'SizeData', 15, 'MarkerFaceAlpha', 0.5, 'MarkerEdgeAlpha', 0.5);
                break;
            else
                sumDist = sumDist + gRoi.Edges.Weight(idxOut);
                continue;
            end
        end
    end

    mysave(figTree, [outputPath, fName]);          
 end

function plotTreeNoROIOnlyStruct(gRoi)    
    recursivePlotNOROI(gRoi)
end

function recursivePlotNOROI(gRoi)       
  for index = 1:size(gRoi.Edges.EndNodes,1)
    fNode = gRoi.Nodes(findnode(gRoi,gRoi.Edges.EndNodes(index, 1)), :);
    sNode = gRoi.Nodes(findnode(gRoi,gRoi.Edges.EndNodes(index, 2)), :);
    color = [0,0,0];
    
    p = plot3([fNode.X(1), sNode.X(1)], [fNode.Z(1), sNode.Z(1)],[fNode.Y(1), sNode.Y(1)], 'color', color, 'HandleVisibility','off'); 
    p.LineWidth = 1;
  end
end
