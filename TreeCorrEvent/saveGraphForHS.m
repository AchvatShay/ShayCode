function saveGraphForHS(gRoi, rootNodeID, outputpath, color1, color2, selectedRoiT)
    matrixForHS = getMatrixForDistanceHS(gRoi, rootNodeID); 
    matrixForHS_2 = getMatrixForDistanceHS_NoFix(gRoi, rootNodeID); 
    matrixForSP = getMatrixForDistanceSP(gRoi); 
    depthToSave = ceil(log2(size(gRoi.Nodes, 1) + 1));
    depthToSaveReal = (log2(size(gRoi.Nodes, 1) + 1));
    baches = size(gRoi.Nodes, 1);
    points_name = char(gRoi.Nodes.Name);
    
    colorMatrix1 = zeros(size(gRoi.Nodes, 1), 3);
    colorMatrix1(selectedRoiT.ID, :) = color1;
    
    colorMatrix2 = zeros(size(gRoi.Nodes, 1), 3);
    colorMatrix2(selectedRoiT.ID, :) = color2;
    
    save([outputpath, '\GraphAsMatrix.mat'], 'matrixForHS', 'depthToSave', 'baches', 'depthToSaveReal', 'points_name', 'matrixForSP', 'colorMatrix1', 'colorMatrix2');
    save([outputpath, '\GraphAsMatrix2.mat'], 'matrixForHS_2', 'depthToSave', 'baches', 'depthToSaveReal', 'points_name', 'matrixForSP', 'colorMatrix1', 'colorMatrix2');   
end