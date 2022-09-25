function SimulationResultsToTPA(simFolderResults, outputpath, ExpName, type,  dosaturator, saturatorValue)
    if strcmp(type, 'V')
        mkdir([outputpath, '\V\', ExpName, '_SR50']);
        SimulationResultsToTPA_V([simFolderResults, ExpName], [outputpath, '\V\', ExpName, '_SR50']);
    elseif strcmp(type, 'Cai2')
        
        mkdir([outputpath, '\Cai2\', ExpName, '_', num2str(dosaturator),'_', num2str(saturatorValue), '_SR50']);
        SimulationResultsToTPA_Cai([simFolderResults, ExpName], [outputpath, '\Cai2\', ExpName, '_', num2str(dosaturator),'_', num2str(saturatorValue), '_SR50'],  dosaturator, saturatorValue);
    elseif strcmp(type, 'Cai3')
        
        mkdir([outputpath, '\Cai3\', ExpName, '_', num2str(dosaturator),'_', num2str(saturatorValue), '_SR50']);
        SimulationResultsToTPA_CaiNew([simFolderResults, ExpName], [outputpath, '\Cai3\', ExpName, '_', num2str(dosaturator),'_', num2str(saturatorValue), '_SR50'],  dosaturator, saturatorValue);
    elseif strcmp(type, 'F_new')
        
        mkdir([outputpath, '\F_new\', ExpName, '_SR50']);
        SimulationResultsToTPA_FNew([simFolderResults, ExpName], [outputpath, '\F_new\', ExpName, '_SR50']);
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
            F0 = abs(mean(V(roiIndex, 1:7)));
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
            if dosaturator
                Cai(roiIndex, Cai(roiIndex,:)<0) = 0;
                Cai(roiIndex, :) = realpow(Cai(roiIndex, :), saturatorValue);
            end
            
            
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
            
            F0 = mean(Cai(roiIndex, 1:7));
%             strROI{roiIndex}.Data(:, 2) = (Cai(roiIndex, :) - F0)' ./ F0;
         
%             strROI{roiIndex}.Data(:, 2) = (Cai(roiIndex, :) - F0)';
            
            strROI{roiIndex}.Data(:, 2) = (Cai(roiIndex, 1:SR:end) - F0)';
            
%             strROI{roiIndex}.Data(:, 2) = (Cai(roiIndex, 1:SR:end) - F0)' ./ F0;
            
            strROI{roiIndex}.xyInd = zeros(30, 2);
            strShift = zeros(ceil((size(Cai, 2))/ SR), 2);
        end

        save(fullfile(outputpath, sprintf('TPA_SimulationResults_%05d', i)), 'strROI', 'strShift');
    end
end


function SimulationResultsToTPA_CaiNew(simFolderResults, outputpath, dosaturator, saturatorValue)
    listSimFiles = dir([simFolderResults , '\matlab_SimulationResults_*.mat']);
    
    for i = 1:length(listSimFiles)
        load(fullfile(listSimFiles(i).folder, listSimFiles(i).name), 'Cai', 'F', 'V', 'names');
        
        strROI = {};
        for roiIndex = 1:size(Cai, 1)
            if dosaturator
                Cai(roiIndex, Cai(roiIndex,:)<0) = 0;
                Cai(roiIndex, :) = realpow(Cai(roiIndex, :), saturatorValue);
            end
            
            
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
            
            F0 = mean(Cai(roiIndex, 90:190));
%             strROI{roiIndex}.Data(:, 2) = (Cai(roiIndex, :) - F0)' ./ F0;
         
%             strROI{roiIndex}.Data(:, 2) = (Cai(roiIndex, :) - F0)';
            
            strROI{roiIndex}.Data(:, 2) = (Cai(roiIndex, 1:SR:end) - F0)';
            
%             strROI{roiIndex}.Data(:, 2) = (Cai(roiIndex, 1:SR:end) - F0)' ./ F0;
            
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
            
            F0 = mean(F(roiIndex, 90:190));
%             strROI{roiIndex}.Data(:, 2) = (Cai(roiIndex, :) - F0)' ./ F0;
         
%             strROI{roiIndex}.Data(:, 2) = (Cai(roiIndex, :) - F0)';
            
            strROI{roiIndex}.Data(:, 2) = (F(roiIndex, 1:SR:end) - F0)';
%             strROI{roiIndex}.Data(:, 2) = (F(roiIndex, 1:SR:end) - F0)' ./ F0;
            
%             strROI{roiIndex}.Data(:, 2) = (Cai(roiIndex, 1:SR:end) - F0)' ./ F0;
            
            strROI{roiIndex}.xyInd = zeros(30, 2);
            strShift = zeros(ceil((size(F, 2))/ SR), 2);
        end

        save(fullfile(outputpath, sprintf('TPA_SimulationResults_%05d', i)), 'strROI', 'strShift');
    end
end

function SimulationResultsToTPA_F(simFolderResults, outputpath)
    listSimFiles = dir([simFolderResults , '\matlab_SimulationResults_*.mat']);
    
    for i = 1:length(listSimFiles)
        load(fullfile(listSimFiles(i).folder, listSimFiles(i).name), 'Cai', 'F', 'V', 'names');
        
        strROI = {};
        for roiIndex = 1:size(F, 1)
            strROI{roiIndex} = TPA_RoiManager();
            strROI{roiIndex}.Name = sprintf('roi%05d', sscanf(names(roiIndex, :), 'apic[%d]'));
            strROI{roiIndex}.Data = zeros((size(F, 2)), 2);
            
%             V(roiIndex, 1) = V(roiIndex, 2);
%             F0 = abs(mean(V(roiIndex, 1:7)));
%             strROI{roiIndex}.Data(:, 2) = (V(roiIndex, :) + F0)' ./ F0;
%              
            F(roiIndex, 1) = F(roiIndex, 2);
            F0 = mean(F(roiIndex, 1:7));
            strROI{roiIndex}.Data(:, 2) = (F(roiIndex, :) - F0)' ./ F0;
             
            strROI{roiIndex}.xyInd = zeros(30, 2);
            strShift = zeros((size(F, 2)), 2);
        end

        save(fullfile(outputpath, sprintf('TPA_SimulationResults_%05d', i)), 'strROI', 'strShift');
    end
end