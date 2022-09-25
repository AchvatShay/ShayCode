function SimulationPrintTreeWithValues(trList, typeP, titleValue)
%     trList = [0];
    graphR = 'E:\ShayCode\Layer2-3Code\Palmer_et_al Model 2014\Simulation\BackgroundTest_9_020822\treeGraph.mat';
    outputPath = 'E:\ShayCode\Layer2-3Code\Palmer_et_al Model 2014\Simulation\BackgroundTest_11_030822\';
    
    for j = 1:length(trList)
       simTrialResults = sprintf('E:\\ShayCode\\Layer2-3Code\\Palmer_et_al Model 2014\\Simulation\\BackgroundTest_11_030822\\matlab_SimulationResults_%05d.mat', trList(j));
%         typeP = 'Cai';
        fName = [num2str(trList(j)), '_' typeP, '_onlyBack'];
        load(graphR, 'gRoi');
        load(simTrialResults, 'Cai', 'V', 'Name');
        names = Name;
        Cai = log(Cai);

        writerObj = VideoWriter([outputPath, '\', fName,'.avi']);
        writerObj.FrameRate = 30;
        writerObj.Quality = 95;
        open(writerObj);

        for t = 100:275
    %     for t = 1:1:size(Cai,2)
            timeSelect = t;

            figTree = figure('visible','off');

               % Create axes
            axes1 = axes('Parent',figTree);
            hold(axes1,'on');
            
            % Create zlabel
%             zlabel({'Z'});

            % Create ylabel
%             ylabel({'Y'});

            % Create xlabel
%             xlabel({'X'});

            % Create title
            title({titleValue});
            view(axes1,[16.146803833781867,26.952301919507775]);
            axes1.CameraViewAngleMode = 'manual';
            axes1.CameraViewAngle = 7.452379366322371;
            
            axes1.XColor = 'None';
            axes1.YColor = 'None';
            axes1.ZColor = 'None';
            figTree.Color = [1,1,1];
            segCount = 9;

            if strcmp(typeP, 'Cai')
    %            minC =0;
    %            maxC = 0.03;
%                minC = min(Cai, [],'all');
%                maxC = max(Cai, [],'all');
%                
               minC = -10;
               maxC = -1.74;
               
               rgbColors = vals2colormap(Cai(:, timeSelect), 'jet', [minC, maxC]);  
            else
%                 minC = min(V, [],'all');
%                 maxC = max(V, [],'all');
%                 
                minC = -60;
                maxC = 0;
                
                rgbColors = vals2colormap(V(:, timeSelect), 'jet', [minC, maxC]);  
            end
        %     minC = min(Cai(:, timeSelect), [],'all');
        %     maxC = max(Cai(:, timeSelect), [],'all');
        %     
%             axes1.ZDir = 'reverse';
            EdgeColor = zeros(length(gRoi.Edges.Weight),3);
            isPass = zeros(1, length(gRoi.Nodes.Name));
            for i = 1:size(names, 1)
                secName = split(names(i, :), '_');
                locationSeg = str2num(secName{2}) + 1;
                secName = secName(1);

                indexSec = find(contains(gRoi.Nodes.Name, secName));

                if isempty(indexSec) || length(indexSec) == 1
                    continue;
                end

                [~, totalDist] = shortestpath(gRoi, indexSec(1), indexSec(end));
                segJump = 0:(totalDist / segCount):totalDist;

                currentDist = segJump(locationSeg+1);

                sumDist = 0;

                for j = 1:length(indexSec)-1
                    idxOut = findedge(gRoi,indexSec(j),indexSec(j+1));
                    if sumDist + gRoi.Edges.Weight(idxOut) <= currentDist && isPass(indexSec(j)) == 0
                        plot3([gRoi.Nodes.X(indexSec(j)), gRoi.Nodes.X(indexSec(j+1))],...
                            [gRoi.Nodes.Z(indexSec(j)), gRoi.Nodes.Z(indexSec(j+1))],...
                            [gRoi.Nodes.Y(indexSec(j)), gRoi.Nodes.Y(indexSec(j+1))],'Color', rgbColors(i,:), 'UserData', gRoi.Nodes.Name{indexSec(j)});
                        sumDist = sumDist + gRoi.Edges.Weight(idxOut);
                        EdgeColor(idxOut, :) = rgbColors(i,:);
                        isPass(indexSec(j)) = 1;
                    else
                        sumDist = sumDist + gRoi.Edges.Weight(idxOut);
                        continue;
                    end
                end
            end

            for idxOut = 1:length(gRoi.Edges.Weight)
                if all(EdgeColor(idxOut, :) == 0)
                    edgPrev = find(contains(gRoi.Edges.EndNodes(:,2), gRoi.Edges.EndNodes(idxOut, 1)));
                    
                    if isempty(edgPrev)
                        continue;
                    end
                    
                    EdgeColor(idxOut, :) = EdgeColor(edgPrev, :);
                    id1 = find(contains(gRoi.Nodes.Name, gRoi.Edges.EndNodes(idxOut, 1)));

                    id2 = find(contains(gRoi.Nodes.Name, gRoi.Edges.EndNodes(idxOut, 2)));

                    plot3([gRoi.Nodes.X(id1), gRoi.Nodes.X(id2)],...
                            [gRoi.Nodes.Z(id1), gRoi.Nodes.Z(id2)],...
                            [gRoi.Nodes.Y(id1), gRoi.Nodes.Y(id2)], 'Color', EdgeColor(idxOut, :));
                end
            end

            frame = getframe(figTree);    
            writeVideo(writerObj, frame);
            close(figTree);

    %         mysave(figTree, ['\\jackie-analysis\e\ShayCode\pythonProject\larkumEtAl2009_2\Simulation\4481_N3\4.5_ReconstractExample\', fName]);
        end

        close(writerObj); 

    end        
end