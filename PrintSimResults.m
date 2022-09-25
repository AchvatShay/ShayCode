function PrintSimResults()
    mainFolder = 'E:\ShayCode\pythonProject\larkumEtAl2009_2\Simulation\SM03_N1\';
    simFolder = {'4.5_ControlDepth1_FixBias'};
    swcFile = 'E:\Shay\Simulation\SM03_N1\Cai2\Swc\cell_N1_SM03_onlyTuft_6-0d_noObliq_subP.swc';
    TypeToPrint = 'V'; %V OR Cai, Time
    outputPath = [mainFolder, '\4.5__compareControlDepth1\'];
    mkdir(outputPath);
 
    timedelta = 10;
    
    [gRoi, rootNodeID, selectedROITable] = loadSwcFile(swcFile, outputPath, false);
    selectedROI = gRoi.Nodes.Name;
    
    simFolderColor = zeros(4,3);
    simFolderColor(1, :) = [1,0,0];
    simFolderColor(2, :) = [0,1,0];
    simFolderColor(3, :) = [0,0,1];

    trialsSelected = [8,16,32,54,64,74,95,107,108];
    doPlot = true;
     
    for i = trialsSelected
        minC = -1;
        maxC = -1;
        
        for j = 1:length(simFolder)
            load_v = load([mainFolder, '\',simFolder{j}, '\', sprintf('matlab_SimulationResults_%03d.mat', i)]);
             
            for k = 1:size(load_v.names, 1)
                if contains(load_v.names(k, :), 'apic')
                    load_v.names(k, 1:8) = sprintf('roi%05d', sscanf(load_v.names(k, :), 'apic[%d]'));
                elseif contains(load_v.names(k, :), 'ep')
                    load_v.names(k, 1:8) = sprintf('roi%05d', sscanf(load_v.names(k, :), 'ep%d'));
                elseif contains(load_v.names(k, :), 'bp')
                    load_v.names(k, 1:8) = sprintf('roi%05d', sscanf(load_v.names(k, :), 'bp%d'));
                elseif contains(load_v.names(k, :), 'roi')
                   load_v.names(k, 1:8) = sprintf('roi%05d', sscanf(load_v.names(k, :), 'roi%05d'));
                end
%                 load_v.names(k, 9:end) = '';
            end
            load_v.names(:, 9:end) = '';
            
            writerObj = VideoWriter([outputPath, '\', simFolder{j}, '_tr', num2str(i), 'T_', TypeToPrint,'.avi']);
            writerObj.FrameRate = 10;
            open(writerObj);
            
            if strcmp(TypeToPrint, 'Cai')
                valuesToPrint = load_v.Cai;
            elseif strcmp(TypeToPrint, 'V')
                valuesToPrint = load_v.V;
            elseif strcmp(TypeToPrint, 'Time')
                valuesToPrint = load_v.selectedsynTiming;
            else
                error('No Type ToPrint');
            end
            
            if maxC == -1
                minC = min(valuesToPrint, [],'all');
                maxC = max(valuesToPrint, [],'all');
            end
            
            rgbColors = vals2colormap(valuesToPrint(:), 'jet', [minC, maxC]);
            rgbColors2 = reshape(rgbColors, [size(valuesToPrint),3]);
            for k = 1:timedelta:size(valuesToPrint, 2)
                
                nodesColor = zeros(length(gRoi.Nodes.Name),3);
                
                if strcmp(TypeToPrint, 'Time')
                     for index = 1:length(gRoi.Nodes.Name)
                        locRoi = find(ismember(load_v.selectedSYNSectionName, gRoi.Nodes.Name(index), 'rows'));
                        if ~isempty(locRoi)
                            nodesColor(index, :) = rgbColors2(locRoi(1),k, :);
                        end
                    end
                else
                    for index = 1:length(gRoi.Nodes.Name)
                        locRoi = find(ismember(load_v.names, gRoi.Nodes.Name(index), 'rows'));
                        if ~isempty(locRoi)
                            nodesColor(index, :) = rgbColors2(locRoi(1),k, :);
                        end
                    end
                end
                 f = plotGraphWithROI(gRoi, [outputPath, '\test'], nodesColor, {'Roi ByActivity cluster By H '});
                 caxis([minC, maxC]);
                 colorbar;
                 
                 frame = getframe(f);    
                 writeVideo(writerObj, frame);
                 close(f);
            end
            
            close(writerObj); 
            
            if doPlot
                f = figure;hold on;
                for k = 1:size(load_v.V, 1)
                    plot(load_v.V(k, :),'k');
                end

                mysave(f, [outputPath, '\', simFolder{j}, '_tr', num2str(i),'_V']);

                f = figure;hold on;
                imagesc(load_v.Cai);
                colorbar;
                caxis([min(load_v.Cai, [],'all'), max(load_v.Cai, [],'all')]);
                yticks(1:size(load_v.Cai, 1));
                yticklabels(load_v.names);
                mysave(f, [outputPath, '\AllActivityFig_', simFolder{j}, 'tr_' num2str(i)]);
            end
        end              
    end
end