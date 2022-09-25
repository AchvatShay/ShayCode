[gRoi, rootNodeID] = loadSwcFileForTraces('\\jackie-analysis\F\Layer II-III\Imaging\Bas-S1-1\05.17.22_reconstracture\S1-1_N2.swc',...
    '\\jackie-analysis\F\Layer II-III\Imaging\Bas-S1-1\05.17.22_reconstracture\Res');

outputpath = '\\jackie-analysis\F\Layer II-III\Imaging\Bas-S1-1\05.17.22_reconstracture\Res';
mkdir(outputpath);

selectedROISplitDepth1 = ones(length(gRoi.Nodes.Name), 1) * -1;
selectedROISplitDepth1 = getSelectedROISplitBranchID(gRoi, 1, selectedROISplitDepth1, gRoi.Nodes.Name, 1);
fig = plotTreeNoROIOnlyStruct(gRoi, outputpath, selectedROISplitDepth1)
fig.Color = [1,1,1]
axi1 = fig.Children
axi1.ZDir = 'reverse';
axi1.ZColor = 'None';
axi1.XColor = 'None';
axi1.YColor = 'None';
axi1.Color = 'None';
axi1.ZLim = [-100,700];
title('');
fig.Position(3:4) = [208,241];
axi1.Position = [0,0,1,1];
mysave(fig, [outputpath, '\SM04_8_18_N2_Final2'])