function [bda_vector_matrix] = getBDAVector(BDA_listFolder, labelingData)
    addpath('')
    
    listBDA = dir(sprintf('%s\\BDA_*', BDA_listFolder));
    
    for index = 1:length(listBDA)
        currentBDA = load(fullfile(listBDA(index).folder, listBDA(index).name));
        strE = currentBDA.strEvent;
        
        bda_vector_matrix(index, :) = ones(1, size(strE{1}.Data, 1)) * -1;
        
        for e_i = 1:length(strE)
            nameWithoutNumber = strsplit(strE{e_i}.Name, ':');
            labelingName = find(contains(labelingData, lower(nameWithoutNumber{1})));
            
            if ~isempty(labelingName)
                bda_vector_matrix(index, strE{e_i}.Data == 1) = labelingName;
            end
        end
    end
end