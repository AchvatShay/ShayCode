function SimulationResultsToTPANew_1308(simFolderResults, outputpath, ExpName, type,  dosaturator, saturatorValue)
    if strcmp(type, 'V_1308')
        mkdir([outputpath, '\V_1308\', ExpName, '_SR50']);
        SimulationResultsToTPA_V([simFolderResults, ExpName], [outputpath, '\V_1308\', ExpName, '_SR50']);
    elseif strcmp(type, 'Cai_1308')        
        mkdir([outputpath, '\Cai_1308\', ExpName, '_', num2str(dosaturator),'_', num2str(saturatorValue), '_SR50']);
        SimulationResultsToTPA_Cai([simFolderResults, ExpName], [outputpath, '\Cai_1308\', ExpName, '_', num2str(dosaturator),'_', num2str(saturatorValue), '_SR50'],  dosaturator, saturatorValue);
    elseif strcmp(type, 'F_1308') 
        mkdir([outputpath, '\F_1308\', ExpName, '_SR50']);
        SimulationResultsToTPA_FNew([simFolderResults, ExpName], [outputpath, '\F_1308\', ExpName, '_SR50']);
    end
end

function SimulationResultsToTPA_V(simFolderResults, outputpath)
    listSimFiles = dir([simFolderResults , '\matlab_SimulationResults_*.mat']);
    
    for i = 1:length(listSimFiles)
        load(fullfile(listSimFiles(i).folder, listSimFiles(i).name), 'Cai', 'F', 'V', 'names');
        
        strROI = {};
        for roiIndex = 1:size(V, 1)
            strROI{roiIndex} = TPA_RoiManager();
            
            if contains(names(roiIndex, :), 'apic')
                strROI{roiIndex}.Name = sprintf('roi%05d', sscanf(names(roiIndex, :), 'apic[%d]'));
            elseif contains(names(roiIndex, :), 'ep')
                strROI{roiIndex}.Name = sprintf('roi%05d', sscanf(names(roiIndex, :), 'ep%d'));
            elseif contains(names(roiIndex, :), 'bp')
                strROI{roiIndex}.Name = sprintf('roi%05d', sscanf(names(roiIndex, :), 'bp%d'));
            elseif contains(names(roiIndex, :), 'roi')
                strROI{roiIndex}.Name = sprintf('roi%05d', sscanf(names(roiIndex, :), 'roi%05d'));
            end
            
            samplingRate = 500;
            changeSR = 50;
            SR = floor(samplingRate / changeSR);
      
            strROI{roiIndex}.Data = zeros(ceil((size(V, 2)) / SR), 2);
            
            V(roiIndex, 1) = V(roiIndex, 2);
            
            F0 = abs(mean(V(roiIndex, 1:100)));
            
            strROI{roiIndex}.Data(:, 2) = (V(roiIndex,  1:SR:end) + F0)';
                  
            strROI{roiIndex}.xyInd = zeros(30, 2);
            strShift = zeros(ceil((size(V, 2))/ SR), 2);
        end

        save(fullfile(outputpath, sprintf('TPA_SimulationResults_%05d', i)), 'strROI', 'strShift');
    end
end

function SimulationResultsToTPA_Cai(simFolderResults, outputpath, dosaturator, saturatorValue)
    listSimFiles = dir([simFolderResults , '\matlab_SimulationResults_*.mat']);
    
    for i = 1:length(listSimFiles)
        load(fullfile(listSimFiles(i).folder, listSimFiles(i).name), 'Cai', 'F', 'V', 'names');
        
        
        strROI = {};
        for roiIndex = 1:size(Cai, 1)
            
            strROI{roiIndex} = TPA_RoiManager();
            
            if contains(names(roiIndex, :), 'apic')
                strROI{roiIndex}.Name = sprintf('roi%05d', sscanf(names(roiIndex, :), 'apic[%d]'));
            elseif contains(names(roiIndex, :), 'ep')
                strROI{roiIndex}.Name = sprintf('roi%05d', sscanf(names(roiIndex, :), 'ep%d'));
                
            elseif contains(names(roiIndex, :), 'bp')
                strROI{roiIndex}.Name = sprintf('roi%05d', sscanf(names(roiIndex, :), 'bp%d'));
                
            elseif contains(names(roiIndex, :), 'roi')
                strROI{roiIndex}.Name = sprintf('roi%05d', sscanf(names(roiIndex, :), 'roi%05d'));
                
            end
            
            samplingRate = 500;
            changeSR = 50;
            SR = floor(samplingRate / changeSR);
            
            strROI{roiIndex}.Data = zeros(ceil((size(Cai, 2)) / SR), 2);
            
            F0 = mean(Cai(roiIndex, 1:10));

            strROI{roiIndex}.Data(:, 2) = (Cai(roiIndex, 1:SR:end) - F0)';
            
            if dosaturator
                strROI{roiIndex}.Data(strROI{roiIndex}.Data(:, 2) < 0, 2) = 0;
                strROI{roiIndex}.Data(:, 2) = realpow(strROI{roiIndex}.Data(:, 2), saturatorValue);
            end
            
            
            strROI{roiIndex}.xyInd = zeros(30, 2);
            strShift = zeros(ceil((size(Cai, 2))/ SR), 2);
        end

        save(fullfile(outputpath, sprintf('TPA_SimulationResults_%05d', i)), 'strROI', 'strShift');
    end
end

function SimulationResultsToTPA_FNew(simFolderResults, outputpath, dosaturator, saturatorValue)
    listSimFiles = dir([simFolderResults , '\matlab_SimulationResults_*.mat']);
    
    for i = 1:length(listSimFiles)
        load(fullfile(listSimFiles(i).folder, listSimFiles(i).name), 'Cai', 'F', 'V', 'names');
        
        strROI = {};
        for roiIndex = 1:size(F, 1)
           
            strROI{roiIndex} = TPA_RoiManager();
            
            if contains(names(roiIndex, :), 'apic')
                strROI{roiIndex}.Name = sprintf('roi%05d', sscanf(names(roiIndex, :), 'apic[%d]'));
            elseif contains(names(roiIndex, :), 'ep')
                strROI{roiIndex}.Name = sprintf('roi%05d', sscanf(names(roiIndex, :), 'ep%d'));
                
            elseif contains(names(roiIndex, :), 'bp')
                strROI{roiIndex}.Name = sprintf('roi%05d', sscanf(names(roiIndex, :), 'bp%d'));
                
            elseif contains(names(roiIndex, :), 'roi')
                strROI{roiIndex}.Name = sprintf('roi%05d', sscanf(names(roiIndex, :), 'roi%05d'));
                
            end
            
            samplingRate = 500;
            changeSR = 50;
            SR = floor(samplingRate / changeSR);
            
            strROI{roiIndex}.Data = zeros(ceil((size(F, 2)) / SR), 2);
            
            F0 = mean(F(roiIndex, 1:10));
            strROI{roiIndex}.Data(:, 2) = (F(roiIndex, 1:SR:end) - F0)' ./ F0;
            
            strROI{roiIndex}.xyInd = zeros(30, 2);
            strShift = zeros(ceil((size(F, 2))/ SR), 2);
        end

        save(fullfile(outputpath, sprintf('TPA_SimulationResults_%05d', i)), 'strROI', 'strShift');
    end
end