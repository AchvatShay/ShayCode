function TPA2Python(TPAFolder, outputFolder)
    tpafiles = dir([TPAFolder, '\TPA*.mat']);
    
    dataTraceAll = []; 
    for i = 1:length(tpafiles)
        currData = load(fullfile(tpafiles(i).folder,tpafiles(i).name));
        
        dataTrace = [];
        NameROI = {};
        for k = 1:length(currData.strROI)
            NameROI(k) = {currData.strROI{k}.Name};
            dataTrace(k, :) = currData.strROI{k}.Data(:,2);
        end   
        
        dataTraceAll(:, end+1:end+size(dataTrace,2)) = dataTrace;
        
        save(fullfile(outputFolder, tpafiles(i).name), 'dataTrace', 'NameROI');
    end
    
    save(fullfile(outputFolder, 'All_Data'), 'dataTraceAll', 'NameROI');
end