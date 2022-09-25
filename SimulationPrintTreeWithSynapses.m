 function SimulationPrintTreeWithSynapses()
    graphR = '\\jackie-analysis\e\ShayCode\pythonProject\larkumEtAl2009_2\Simulation\4481_N3\4.5_ReconstractExample\treeGraph.mat';
    simTrialResults = '\\jackie-analysis\e\ShayCode\pythonProject\larkumEtAl2009_2\Simulation\4481_N3\24.8Control_1000ms_60log30_scaTuft_0.6_80BackL_1\matlab_SimulationResults_00050.mat';
    outputPath = '\\jackie-analysis\e\ShayCode\pythonProject\larkumEtAl2009_2\Simulation\4481_N3\12.9_ReconstractExample\';
    

%     graphR = '\\jackie-analysis\e\ShayCode\pythonProject\larkumEtAl2009_2\Simulation\SM03_N1\4.5_ReconstractExample\treeGraph.mat';
%     simTrialResults = '\\jackie-analysis\e\ShayCode\pythonProject\larkumEtAl2009_2\Simulation\SM03_N1\4.5_ReconstractExample\matlab_SimulationResults_185.mat';
%     outputPath = '\\jackie-analysis\e\ShayCode\pythonProject\larkumEtAl2009_2\Simulation\SM03_N1\4.5_ReconstractExample\';
    
    fName = 'SynDist_20_all';
    load(graphR, 'gRoi');
    load(simTrialResults, 'selectedSYNSectionName', 'SelectedSynSectionSeg');
    

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
    view(axes1,[-91.83749999992375,5.564438839731007]);

    segCount = 9;

    axes1.ZDir = 'reverse';

    plotTreeNoROIOnlyStruct(gRoi)

    for syn = 1:size(SelectedSynSectionSeg, 1)
        segLocation1 = floor(SelectedSynSectionSeg(syn)*9);
        nameR1 = replace(selectedSYNSectionName(syn, :), ' ', '');

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
                    [gRoi.Nodes.Y(indexSec(j))],...
                    [gRoi.Nodes.Z(indexSec(j))], 'MarkerFaceColor', [1,0,0], 'MarkerEdgeColor', [1,0,0], 'SizeData', 25);
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
    
    p = plot3([fNode.X(1), sNode.X(1)], [fNode.Y(1), sNode.Y(1)], [fNode.Z(1), sNode.Z(1)], 'color', color, 'HandleVisibility','off'); 
    p.LineWidth = 1;
  end
end
