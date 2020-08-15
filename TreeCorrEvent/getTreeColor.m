function color = getTreeColor(treeNum)
    switch treeNum
        case 1
            color = [0.2,1,0.6];
        case 2
            color = [0.2,1,1];
        case 3
            color = [0.2,0.6,1];
        case 4
            color = [0.2,0.2,1];
        case 5
            color = [0.6,0.2,1];
        case 6
            color = [1,0.2,1];
        case 7
            color = [1,0.2,0.6];
        case 8
            color = [1,0.6,0.2];
        otherwise
            color = [0,0,0];
    end
end
