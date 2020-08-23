function color = getTreeColor(methodT, treeNum)
    switch methodT
        case 'main'
            color = [1, 0, 0];
        case 'between'
            color = [0, 0, 1];
        case 'within'
            switch treeNum
                case 1
                    color = [34,139,34] ./ 255;
                case 2
                    color = [50,205,50] ./ 255;
                case 3
                    color = [0,128,128] ./ 255;
                case 4
                    color = [0,255,255] ./ 255;
                case 5
                    color = [106,90,205] ./ 255;
                case 6
                    color = [128,0,128] ./ 255;
                case 7
                    color = [255,20,147] ./ 255;
                case 8
                    color = [210,105,30] ./ 255;
                case 9
                    color = [112,128,144] ./ 255; 
                case 10
                    color = [188,143,143] ./ 255;
                otherwise
                    color = [0,0,0];
            end
    end
end
