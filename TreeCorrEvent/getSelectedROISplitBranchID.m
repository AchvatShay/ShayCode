function selectedROISplit = getSelectedROISplitBranchID(gRoi, depthForSplit, selectedROISplit, selectedROIName)
    mainTreeSplite = gRoi.Nodes(gRoi.Nodes.Depth(: ,1) == depthForSplit, :);
    
    alreadyPast = [];
    for index = 1:size(mainTreeSplite, 1)
        [selectedROISplit,alreadyPast]  = setMainTreeSplit(gRoi, selectedROISplit,  mainTreeSplite(index, :).ID, selectedROIName, mainTreeSplite(index, :).ID, alreadyPast);
    end 
end


function [selectedROISplit, alreadyPast] = setMainTreeSplit(gRoi, selectedROISplit, currentID, selectedROIName, rootID, alreadyPast)
    
    alreadyPast(end + 1) = currentID;
    indexSelectedROI = find(contains(selectedROIName, gRoi.Nodes(currentID, :).Name));
    if ~isempty(indexSelectedROI) && selectedROISplit(indexSelectedROI(1)) == -1
        selectedROISplit(indexSelectedROI(1)) = rootID;
    end
    
    nid = neighbors(gRoi,currentID); 
    
    for index = 1:length(nid)        
        if (sum (alreadyPast == nid(index)) == 0) && (gRoi.Nodes(nid(index), :).Depth(1) >= gRoi.Nodes(currentID, :).Depth(1))
            [selectedROISplit, alreadyPast] = setMainTreeSplit(gRoi, selectedROISplit, nid(index), selectedROIName, rootID, alreadyPast);  
        end
    end
end