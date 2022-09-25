function PosAnalysisSimulationClusterGvalues()
    AnimalName = '4481_N3';
    DateAnimal = '12.6Syn50Size0.7';
    NeuronName = 'N1';
    RunNumber = 'Run1';
    outputPath = sprintf('\\\\jackie-analysis\\e\\Shay\\Simulation\\%s\\Cai2\\%s_SR50\\Analysis\\%s\\Structural_VS_Functional\\final\\%s\\no_behave\\Pearson\\SP\\', AnimalName, DateAnimal,NeuronName, RunNumber);
    simEventsList = [outputPath, 'eventsCaSummary.csv'];
    simResults = sprintf('\\\\jackie-analysis\\e\\ShayCode\\pythonProject\\larkumEtAl2009_2\\Simulation\\%s\\%s\\', AnimalName, DateAnimal);
   
    namesLocationInList = sprintf('\\\\jackie-analysis\\e\\ShayCode\\pythonProject\\larkumEtAl2009_2\\Simulation\\%s\\namesLocationInList.mat', AnimalName);
    load(namesLocationInList, 'namesLocationInList');
    eventsList = readtable(simEventsList);
%     hotZoneNames = {'bp145', 'bp2868'};
   
%     hotZoneNames = {'bp124', 'bp1059'};

  hotZoneNames = {'bp132', 'bp3169'};
 
    samplingR = 500;
    CaSpikeMS = 15;
    nmdaSpikeMS = 20;
    APMS = 0;
    CaSpikeAmp = -40;
    NMDASpikeAmp = -40;
   
    samplingFactor = 1000 / samplingR;
    gNMDA = zeros(1, 4);
   
%     eventsList.tr_index(eventsList.tr_index >= 239) = eventsList.tr_index(eventsList.tr_index >= 239) + 1; 
    distTril= zeros(4, 0);
    timingMean = zeros(4, 2180);
    clusterCount = zeros(4, 1);
    for i_e = 1:size(eventsList, 1)
        fR = find(eventsList.tr_index, eventsList.tr_index(i_e));
        if length(fR) > 1
%             continue;
        end
        
        trial_location = eventsList.tr_index(i_e) - 1;
        
        load_v = load([simResults, sprintf('\\matlab_SimulationResults_%03d.mat', trial_location)], 'V', 'selectedSYNSectionName', 'selectedSYNSectionGmax', 'selectedsynTiming', 'names', 'SelectedsynGAmpa');
        
        distMat = load([simResults, sprintf('\\synDist\\matlab_SynDist_%03d.mat', trial_location)], 'resultsR');
       
        for k = 1:size(distMat.resultsR, 1)
            for j = (k+1):size(distMat.resultsR, 1)
                distTril(eventsList.clusterByH(i_e), end+1) = distMat.resultsR(k, j);
            end
        end
        
        indexLocationStart = max(1, round((eventsList.start(i_e) - (eventsList.tr_index(i_e) - 1)*(50*2.18))*10)-20);
        
        if i_e < size(eventsList, 1) && eventsList.tr_index(i_e+1) == eventsList.tr_index(i_e)
            indexLocationEnd = max(1, round((eventsList.start(i_e+1) - (eventsList.tr_index(i_e+1) - 1)*(50*2.18))*10)-20);        
        else
            indexLocationEnd = size(load_v.V, 2);
        end
        
        load_v.V = load_v.V(:, indexLocationStart:indexLocationEnd);
        load_v.SelectedsynGAmpa = load_v.SelectedsynGAmpa(:, indexLocationStart:indexLocationEnd);
        
        timingMean(eventsList.clusterByH(i_e), :) = timingMean(eventsList.clusterByH(i_e), :) + mean(load_v.selectedsynTiming);
        clusterCount(eventsList.clusterByH(i_e)) = clusterCount(eventsList.clusterByH(i_e)) + 1;
        gNMDA(eventsList.clusterByH(i_e)) = gNMDA(eventsList.clusterByH(i_e)) + mean(max(load_v.SelectedsynGAmpa, [], 2));           
    end
    
    for i_c = 1:4
        timingMean(i_c, :) = timingMean(i_c, :) ./ clusterCount(i_c); 
        gNMDA(i_c) = gNMDA(i_c) / clusterCount(i_c);
    end
    
    f = figure; hold on;
    histogram(distTril(1, :), 'Normalization', 'probability', 'DisplayName', 'Cluster 1');
    histogram(distTril(2, :), 'Normalization', 'probability', 'DisplayName', 'Cluster 2');
    histogram(distTril(3, :), 'Normalization', 'probability', 'DisplayName', 'Cluster 3');
    histogram(distTril(4, :), 'Normalization', 'probability', 'DisplayName', 'Cluster 4');
    
    mysave(f, [outputPath, 'SimResultsSynDistanceDistribution']);
    
    f = figure; hold on;
    plot(timingMean(1, :), 'DisplayName', 'Cluster 1');
    plot(timingMean(2, :), 'DisplayName', 'Cluster 2');
    plot(timingMean(3, :), 'DisplayName', 'Cluster 3');
    plot(timingMean(4, :), 'DisplayName', 'Cluster 4');
    
    mysave(f, [outputPath, 'SimResultsSynTiming']);
    
    
    tResults = table(gNMDA',...
        'RowNames', {'Cluster1', 'Cluster2', 'Cluster3', 'Cluster4'},...
        'VariableNames',...
        {'GNMDA'});
    writetable(tResults, [outputPath, 'SimResultsPostAnalysisGNMDA_GMAXPart.csv'])
end