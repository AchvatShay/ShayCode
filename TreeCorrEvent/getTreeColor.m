function color = getTreeColor(methodT, treeNum)
    switch methodT
        case 'ND'
            color = [0,0,0];
        case 'main'
            color = [1, 0, 0];
        case 'between'
            color = [0, 0, 1];
        case 'within'
            switch treeNum
                case 1
                    color = [1.00,0.60,0.20];
                case 2
                    color = [0.44,0.75,0.43];
                case 3
                    color = [0.68,0.44,0.71];
                case 4
                    color = [0.69,0.40,0.24];
                case 5
                    color = [0.87,0.81,0.43]; 
                case 6
                    color = [0.97,0.56,0.77];
                otherwise
                    color = [0,0,0];
            end
    end
end
