function [gRoi, rootNodeID] = loadSwcFileForTraces(neuronTreeFile, outputpath)
    data = importdata(neuronTreeFile);
    rootNodeID = [];

    % create nodes
    edgeIndex = 1;
    lengthArrays = (size(data.data,1)) - 1;
    nodesX = zeros(1, lengthArrays);
    nodesY = zeros(1, lengthArrays);
    nodesZ = zeros(1, lengthArrays);
    nodesType = zeros(1, lengthArrays);
    nodesID = zeros(1, lengthArrays);
    nodesDepth = zeros(lengthArrays, 2);
   
    for index = 1:(size(data.data,1))
        nodesX(index) = data.data(index, 3);
        nodesY(index) = data.data(index, 4);
        nodesZ(index) = data.data(index, 5);
        nodesType(index) = data.data(index,2);
        nodesID(index) = data.data(index,1);
        nodesDepth(index, :) = [-1, -1];
       
        parent = data.data(data.data(:, 1) == data.data(index,7), :);
        if  ~isempty(parent)
            edgeArray(edgeIndex, :) = [(parent(1)), (data.data(index,1))];
            edgeDistFromParent(edgeIndex) = norm([nodesX(index), nodesY(index), nodesZ(index)] - [(parent(3)), (parent(4)), (parent(5))]);
            edgeIndex = edgeIndex + 1;
        else
            rootNodeID = nodesID(index);
        end
    end
    
    EdgeTable = table(edgeArray, edgeDistFromParent','VariableNames',{'EndNodes', 'Weight'});
    NodeTable = table(nodesID', nodesX', nodesY', nodesZ', nodesType', nodesDepth,'VariableNames',{'ID', 'X', 'Y', 'Z', 'Type', 'Depth'});
    gRoi = graph(EdgeTable, NodeTable);
    
    segmentList{1} = [];
    [gRoi, segmentList] = setDepth(gRoi, rootNodeID, 0, 1, 1, segmentList);
   
%     the seg list is not ID of Nodes is the location in the Nodes List
    
    
    gRoi.Nodes.X = (gRoi.Nodes.X - mean(gRoi.Nodes.X)) ./ 2;
    gRoi.Nodes.Y = (gRoi.Nodes.Y - mean(gRoi.Nodes.Y)) ./ 2;
    gRoi.Nodes.Z = (gRoi.Nodes.Z - mean(gRoi.Nodes.Z)) .* 3;
     
    for segIndex = 1:length(segmentList)
        [gRoi.Nodes.X(segmentList{segIndex}), gRoi.Nodes.Y(segmentList{segIndex}), gRoi.Nodes.Z(segmentList{segIndex})] = ...
            smooth_segment_gauss(gRoi.Nodes.X(segmentList{segIndex}), gRoi.Nodes.Y(segmentList{segIndex}), gRoi.Nodes.Z(segmentList{segIndex}), 3);
    
%         [gRoi.Nodes.X(segmentList{segIndex}), gRoi.Nodes.Y(segmentList{segIndex}), gRoi.Nodes.Z(segmentList{segIndex})] = ...
%             smooth_segment_spline(gRoi.Nodes.X(segmentList{segIndex}), gRoi.Nodes.Y(segmentList{segIndex}), gRoi.Nodes.Z(segmentList{segIndex}));
%     
    end
    
    plotTree(gRoi, outputpath);
end

function [gRoi, segmentList] = setDepth(gRoi, rootNodeID, depthBefore, indexB, indexSeg, segmentList)
    nid = neighbors(gRoi,rootNodeID);
    nid = nid(gRoi.Nodes(nid, :).Depth(: ,1) == -1);
   
    if (length(nid) == 1)
         gRoi.Nodes(rootNodeID, :).Depth = [depthBefore, indexB];
    else
        gRoi.Nodes(rootNodeID, :).Depth = [depthBefore + 1, indexB];
    end
    
    rootNodeID_graph_index = find(gRoi.Nodes.ID == rootNodeID);
    
    segmentList{indexSeg} = [segmentList{indexSeg}, rootNodeID_graph_index];
    for index = 1:length(nid)
        if (length(nid) == 1)
            [gRoi, segmentList] = setDepth(gRoi, nid(index), depthBefore, index, indexSeg, segmentList);
        else
            indexSeg = length(segmentList) + 1;            
            segmentList{indexSeg} = [];
            segmentList{indexSeg} = [segmentList{indexSeg}, rootNodeID_graph_index];
            [gRoi, segmentList] = setDepth(gRoi, nid(index), depthBefore + 1, index, indexSeg, segmentList);    
        end
    end
end

function plotTree(gRoi, outputpath)
    figTree = figure;
    
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

    view(axes1,[-39.6 18.8]);
    box(axes1,'on');
    grid(axes1,'on');
    
    recursivePlot(gRoi)
    
    [leg, legColor] = getSwcLegPlot();
    legend(leg, legColor);
    %TODO------------------------------
    % Save Tree Plot
    mysave(figTree, [outputpath, '\3DTreeWithROI']);
    %TODO------------------------------
end

function [leg, legColor] = getSwcLegPlot()
    leg = zeros(5, 1);
    leg(1) = plot(0,0, 'color', [0,0,0]);
    leg(2) = plot(0,0,'color', [1,0.6,0.6]);
    leg(3) = plot(0,0,'color', [0.6,0.6,1]);
    leg(4) = plot(0,0,'color', [0.6,1,1]);
    leg(5) = plot(0,0,'color', [0.6,1,0.6]);
    legColor = {'undefined', 'soma', 'axon', '(basal) dendrite', 'apical dendrite'};
end

function [color, name] = getSwcTypeColor(type)
    switch type
        case 0
            color = [0,0,0];
            name = 'undefined';
        case 1
            color = [1,0.6,0.6];
            name = 'soma';
        case 2
            color = [0.6,0.6,1];
            name = 'axon';
        case 3
            color = [0.6,1,1];
            name = '(basal) dendrite';
        case 4
            color = [0.6,1,0.6];
            name = 'apical dendrite';
    end
end

function recursivePlot(gRoi)   
  for index = 1:size(gRoi.Edges.EndNodes,1)
    fNode = gRoi.Nodes(findnode(gRoi,gRoi.Edges.EndNodes(index, 1)), :);
    sNode = gRoi.Nodes(findnode(gRoi,gRoi.Edges.EndNodes(index, 2)), :);
    
    [color, ~] = getSwcTypeColor(sNode.Type(1));
    plot3([fNode.X(1), sNode.X(1)], [fNode.Y(1), sNode.Y(1)], [fNode.Z(1), sNode.Z(1)], 'color', color, 'HandleVisibility','off'); 
  end
end