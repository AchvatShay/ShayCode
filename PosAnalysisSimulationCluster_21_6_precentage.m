function PosAnalysisSimulationCluster_21_6()
    AnimalName = '4481_N3';
    DateAnimal = '25.8Control_1000ms_60log30_scaTuft_0.6_80BackL_all';
    DateAnimalReg = '25.8Control_1000ms_60log30_scaTuft_0.6_80BackL_all';
    NeuronName = 'N1';
    RunNumber = 'Run2';
    outputPath = sprintf('\\\\jackie-analysis\\e\\Shay\\Simulation\\%s\\Cai_1308\\%s_0_0_SR50\\Analysis\\%s\\Structural_VS_Functional\\final\\%s\\no_behave\\Pearson\\SP\\', AnimalName, DateAnimal,NeuronName, RunNumber);
    simEventsList = [outputPath, 'eventsCaSummary.csv'];
    synTotalTime = 1.5;
    simResultsReg = sprintf('\\\\jackie-analysis\\e\\ShayCode\\pythonProject\\larkumEtAl2009_2\\Simulation\\%s\\%s\\', AnimalName, DateAnimalReg);
    
    simResults = sprintf('\\\\jackie-analysis\\e\\ShayCode\\pythonProject\\larkumEtAl2009_2\\Simulation\\%s\\%s\\', AnimalName, DateAnimal);

    namesLocationInList = sprintf('\\\\jackie-analysis\\e\\ShayCode\\pythonProject\\larkumEtAl2009_2\\Simulation\\%s\\namesLocationInList.mat', AnimalName);
    load(namesLocationInList, 'namesLocationInList');

    eventsList = readtable(simEventsList);
%     hotZoneNames = {'bp344', 'bp72'};
%     hotZoneNames = {'bp1676', 'bp138'};
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
    caSpikeClusterCountHt1 = zeros(5, 4);
    caSpikeClusterCountHt2 = zeros(4, 4);
    caSpikeClusterCountHt1_end = zeros(5, 4);
    caSpikeClusterCountHt1_start = zeros(5, 4);
    caSpikeClusterCountHt2_end = zeros(4, 4);
    caSpikeClusterCountHt2_start = zeros(4, 4);
    
    nmdaSpikeClusterCount = zeros(1, 4);
    nmdaSpikeClusterNumber = zeros(1, 4);
    ApClusterCount = zeros(1, 4);
    SumAPNotPass = zeros(1,4);
    countAPNotPass = zeros(1,4);
    
    synCountTotal = zeros(1,4);
    synGmaxTotal = zeros(1,4);
    synCountSide0 = zeros(1,4);
    synCountSide1 = zeros(1,4);
    synSizeSumSide0 = zeros(1,4);
    synSizeSumSide1 = zeros(1,4);
    onlySynOnOneSize = zeros(1,4);
    ratioMin2MaxSyn = zeros(1,4);
    ratioMin2MaxGmax = zeros(1,4);
    OnlyHt2CaSpike = zeros(1,4);
    OnlyHt1CaSpike = zeros(1,4);
    resultsSynDist = zeros(4,9);
    gNMDA = zeros(1, 4);
    resultsSynDist_count = zeros(1,4);

    synDistributionDepth3 = zeros(1, 4);
        
    AllResults.gNMDA.c1 = [];
    AllResults.gNMDA.c2 = [];
    AllResults.gNMDA.c3 = [];
    AllResults.gNMDA.c4 = [];
    
    AllResults.somaV.c1 = [];
    AllResults.somaV.c2 = [];
    AllResults.somaV.c3 = [];
    AllResults.somaV.c4 = [];
    
    
    AllResults.nexusV.c1 = [];
    AllResults.nexusV.c2 = [];
    AllResults.nexusV.c3 = [];
    AllResults.nexusV.c4 = [];
    
    AllResults.totalSyn.c1 = [];
    AllResults.totalSyn.c2 = [];
    AllResults.totalSyn.c3 = [];
    AllResults.totalSyn.c4 = [];
    
    AllResults.nmdaBranches.c1 = [];
    AllResults.nmdaBranches.c2 = [];
    AllResults.nmdaBranches.c3 = [];
    AllResults.nmdaBranches.c4 = [];
    
    
    allMatFilesListReg = dir([simResultsReg, '\matlab_SimulationResults*']);
    allMatFilesList = dir([simResults, '\matlab_SimulationResults*']);
    
    for i_e = 1:size(eventsList, 1)
        trial_location = eventsList.tr_index(i_e) - 1;
        
        
%         load_v_reg = load(fullfile(allMatFilesListReg(trial_location+1).folder, allMatFilesListReg(trial_location+1).name), 'selectedSYNSectionName', 'selectedSYNSectionGmax', 'SelectedSynSectionSeg');        
%         load_v = load(fullfile(allMatFilesList(trial_location+1).folder, allMatFilesList(trial_location+1).name), 'V', 'selectedSYNSectionName', 'SelectedsynGNMDA', 'selectedsynTiming', 'selectedSYNSectionGmax', 'SelectedSynSectionSeg', 'names');        
        
        load_v_reg = load([simResultsReg, sprintf('\\matlab_SimulationResults_%05d.mat', trial_location)], 'selectedSYNSectionName', 'selectedSYNSectionGmax', 'SelectedSynSectionSeg');        
        load_v = load([simResults, sprintf('\\matlab_SimulationResults_%05d.mat', trial_location)], 'V', 'Cai', 'selectedSYNSectionName','SelectedsynGNMDA', 'selectedsynTiming', 'selectedSYNSectionGmax', 'SelectedSynSectionSeg', 'names');        
%         load_v2 = load([simResults2, sprintf('\\matlab_SimulationResults_%03d.mat', trial_location)],'SelectedsynGNMDA');
%         
        load_v.selectedSYNSectionName = load_v_reg.selectedSYNSectionName;
        load_v.selectedSYNSectionGmax = load_v_reg.selectedSYNSectionGmax;
        load_v.SelectedSynSectionSeg = load_v_reg.SelectedSynSectionSeg;
        
        
        A = zeros(size(load_v.selectedsynTiming));
        B = zeros(size(load_v.selectedsynTiming));

        for i = 1:(size(load_v.selectedsynTiming,2)-1)
            locationIndexL = find(load_v.selectedsynTiming(:,i) == 1);
            if ~isempty(locationIndexL)
                A(locationIndexL,i) = A(locationIndexL,i)+load_v.selectedSYNSectionGmax(locationIndexL)';
                B(locationIndexL,i) = B(locationIndexL,i)+load_v.selectedSYNSectionGmax(locationIndexL)';
            end

            A(:,i+1) = A(:,i)-A(:,i)/50;
            B(:,i+1) = B(:,i)-B(:,i)/2;
        end
        
        synActiveTest = load_v.selectedsynTiming;
        load_v.selectedsynTiming = load_v.selectedsynTiming(:, 1:2:size(load_v.selectedsynTiming,2));
        A = A(:, 1:2:size(A,2));
        B = B(:, 1:2:size(B,2));
        
        indexLocationStart = max(1, round((eventsList.start(i_e) - (eventsList.tr_index(i_e) - 1)*(50*synTotalTime))*10)-20);
        
        if i_e < size(eventsList, 1) && eventsList.tr_index(i_e+1) == eventsList.tr_index(i_e)
            indexLocationEnd = max(1, round((eventsList.start(i_e+1) - (eventsList.tr_index(i_e+1) - 1)*(50*synTotalTime))*10)-20);        
        else
            indexLocationEnd = size(load_v.V, 2);
        end
   
        load_v.V = load_v.V(:, indexLocationStart:indexLocationEnd);
        load_v.Cai = load_v.Cai(:, indexLocationStart:indexLocationEnd);
        load_v.selectedsynTiming = load_v.selectedsynTiming(:, (indexLocationStart):(indexLocationEnd));
        load_v.SelectedsynGNMDA = load_v.SelectedsynGNMDA(:, indexLocationStart:indexLocationEnd);
        A = A(:, indexLocationStart:indexLocationEnd);
        B = B(:, indexLocationStart:indexLocationEnd);
        
        synActive = any(synActiveTest(:,(indexLocationStart*2):(indexLocationEnd*2)) == 1, 2);
        
        
        curHt2_e = 0;
        curHt2_s = 0;
        curHt2 = 0;
        curHt1_e = 0;
        curHt1_s = 0;
        curHt1 = 0;
        
        totalS1 = 0;
        totalS0 = 0;
        gMaxS1 = 0;
        gMaxS0 = 0;
        
        synIndexNode = [];
%         synDistributionDepth3Temp = zeros(4, length(depth3Clusters));
        totalSAll = 0;
        
        for syn = 1:size(load_v.selectedSYNSectionName, 1)
            if ~synActive(syn)
                continue;
            end
            
            synNameL = find(ismember(load_v.names, load_v.selectedSYNSectionName(syn ,:), 'rows'));
            synSide = namesLocationInList(synNameL);
            
            segLocation1 = floor(load_v.SelectedSynSectionSeg(syn)*9);
            nameR1 = getRoiName(load_v.selectedSYNSectionName(syn, :));
            nameR1 = sprintf('%s%d', nameR1, segLocation1);
            
%             nodeIndex1 = find(strcmp(gRoi.Nodes.Name,nameR1));
%             isclusterd = find(depth3Clusters == selectedROISplitDepth3(nodeIndex1));
%             
%             if ~isempty(isclusterd)
%                 synDistributionDepth3Temp(eventsList.clusterByRoiPrecantage(i_e), isclusterd) = synDistributionDepth3Temp(eventsList.clusterByRoiPrecantage(i_e), isclusterd) + 1;
%             end
%             
            totalSAll = totalSAll + 1;
            
%             synIndexNode(end+1) = nodeIndex1;
            
            synCountTotal(eventsList.clusterByRoiPrecantage(i_e)) = synCountTotal(eventsList.clusterByRoiPrecantage(i_e)) + 1;
            synGmaxTotal(eventsList.clusterByRoiPrecantage(i_e)) = synGmaxTotal(eventsList.clusterByRoiPrecantage(i_e)) + load_v.selectedSYNSectionGmax(syn);
 
            if synSide == 0
                totalS0 = totalS0 + 1;
                gMaxS0 = gMaxS0 + load_v.selectedSYNSectionGmax(syn);
                synCountSide0(eventsList.clusterByRoiPrecantage(i_e)) = synCountSide0(eventsList.clusterByRoiPrecantage(i_e)) + 1;
                synSizeSumSide0(eventsList.clusterByRoiPrecantage(i_e)) = synSizeSumSide0(eventsList.clusterByRoiPrecantage(i_e)) + load_v.selectedSYNSectionGmax(syn);
            else
                totalS1 = totalS1 + 1;
                gMaxS1 = gMaxS1 + load_v.selectedSYNSectionGmax(syn);
                synCountSide1(eventsList.clusterByRoiPrecantage(i_e)) = synCountSide1(eventsList.clusterByRoiPrecantage(i_e)) + 1;
                synSizeSumSide1(eventsList.clusterByRoiPrecantage(i_e)) = synSizeSumSide1(eventsList.clusterByRoiPrecantage(i_e)) + load_v.selectedSYNSectionGmax(syn);
            end
        end
        
        AllResults.totalSyn.(sprintf('c%d', eventsList.clusterByRoiPrecantage(i_e)))(end+1) = totalSAll;
        
        if totalS0 == 0 || totalS1 == 0
            onlySynOnOneSize(eventsList.clusterByRoiPrecantage(i_e)) = onlySynOnOneSize(eventsList.clusterByRoiPrecantage(i_e))  + 1; 
        end
        
        tempR = max(load_v.SelectedsynGNMDA,[], 2) ./ max(A - B,[], 2);
        tempR(max(A-B, [],2) == 0) = 0;
        
        gNMDA(eventsList.clusterByRoiPrecantage(i_e)) = gNMDA(eventsList.clusterByRoiPrecantage(i_e)) + mean(tempR, 'omitnan');
        
        AllResults.gNMDA.(sprintf('c%d', eventsList.clusterByRoiPrecantage(i_e)))(end+1) = mean(tempR, 'omitnan');
        
        ratioMin2MaxSyn(eventsList.clusterByRoiPrecantage(i_e)) = ratioMin2MaxSyn(eventsList.clusterByRoiPrecantage(i_e)) +  min([totalS0, totalS1]) / max([totalS0, totalS1]);
        ratioMin2MaxGmax(eventsList.clusterByRoiPrecantage(i_e)) = ratioMin2MaxGmax(eventsList.clusterByRoiPrecantage(i_e)) +  min([gMaxS0, gMaxS1]) / max([gMaxS0, gMaxS1]);
        
        ht1 = find(ismember(load_v.names, hotZoneNames{1}, 'rows'));
        ht1_end = find(ismember(load_v.names, [hotZoneNames{1}, '_end'], 'rows'));
        ht1_start = find(ismember(load_v.names, [hotZoneNames{1}, '_start'], 'rows'));
       
        ht2 = find(ismember(load_v.names, hotZoneNames{2}, 'rows'));
        ht2_end = find(ismember(load_v.names, [hotZoneNames{2}, '_end'], 'rows'));
        ht2_start = find(ismember(load_v.names, [hotZoneNames{2}, '_start'], 'rows'));
        soma = find(ismember(load_v.names, 'apic[0]', 'rows'));
        
        caS1 = load_v.V(ht1, :) > CaSpikeAmp;
        caS1_l_s = find(caS1(1:end-1)==0 & caS1(2:end)==1);
        caS1_l_e = find(caS1(1:end-1)==1 & caS1(2:end)==0);
        
        if caS1(1) == 1
           caS1_l_s = [1, caS1_l_s]; 
        end

        if caS1(end) == 1
           caS1_l_e = [caS1_l_e, size(load_v.V, 2)]; 
        end
        
        caS1_end = load_v.V(ht1_end, :) > CaSpikeAmp;
        caS1_l_end_s = find(caS1_end(1:end-1)==0 & caS1_end(2:end)==1);
        caS1_l_end_e = find(caS1_end(1:end-1)==1 & caS1_end(2:end)==0);
        
        if caS1_end(1) == 1
            caS1_l_end_s = [1, caS1_l_end_s]; 
        end

        if caS1_end(end) == 1
           caS1_l_end_e = [caS1_l_end_e, size(load_v.V, 2)]; 
        end
        
        caS1_start = load_v.V(ht1_start, :) > CaSpikeAmp;
        caS1_l_start_s = find(caS1_start(1:end-1)==0 & caS1_start(2:end)==1);
        caS1_l_start_e = find(caS1_start(1:end-1)==1 & caS1_start(2:end)==0);
         
        if caS1_start(1) == 1
            caS1_l_start_s = [1, caS1_l_start_s]; 
        end

        if caS1_start(end) == 1
           caS1_l_start_e = [caS1_l_start_e, size(load_v.V, 2)]; 
        end
        
        caS2 = load_v.V(ht2, :) > CaSpikeAmp;
        caS2_l_s = find(caS2(1:end-1) ==0 & caS2(2:end) == 1);
        caS2_l_e = find(caS2(1:end-1) == 1 & caS2(2:end) == 0);
               
        if caS2(1) == 1
            caS2_l_s = [1, caS2_l_s]; 
        end

        if caS2(end) == 1
           caS2_l_e = [caS2_l_e, size(load_v.V, 2)]; 
        end
                 
        caS2_end = load_v.V(ht2_end, :) > CaSpikeAmp;
        caS2_l_end_s = find(caS2_end(1:end-1)==0 & caS2_end(2:end)==1);
        caS2_l_end_e = find(caS2_end(1:end-1)==1 & caS2_end(2:end)==0);
               
        if caS2_end(1) == 1
            caS2_l_end_s = [1, caS2_l_end_s]; 
        end

        if caS2_end(end) == 1
           caS2_l_end_e = [caS2_l_end_e, size(load_v.V, 2)]; 
        end
         
        caS2_start = load_v.V(ht2_start, :) > CaSpikeAmp;
        caS2_l_start_s = find(caS2_start(1:end-1)==0 & caS2_start(2:end)==1);
        caS2_l_start_e = find(caS2_start(1:end-1)==1 & caS2_start(2:end)==0);
               
        if caS2_start(1) == 1
            caS2_l_start_s = [1, caS2_l_start_s]; 
        end

        if caS2_start(end) == 1
           caS2_l_start_e = [caS2_l_start_e, size(load_v.V, 2)]; 
        end
         
        Ap1 = load_v.V(soma, :) > -10;
        Ap1_l_s = find(Ap1(1:end-1)==0 & Ap1(2:end)==1);
        Ap1_l_e = find(Ap1(1:end-1)==1 & Ap1(2:end)==0);
               
        if Ap1(1) == 1
            Ap1_l_s = [1, Ap1_l_s]; 
        end

        if Ap1(end) == 1
           Ap1_l_e = [Ap1_l_e, size(load_v.V, 2)]; 
        end
        
        if ~isempty(Ap1_l_s)
            Ap1_l_calc = samplingFactor .* (Ap1_l_e - Ap1_l_s);
            if any(Ap1_l_calc > APMS)
                ApClusterCount(eventsList.clusterByRoiPrecantage(i_e)) = ApClusterCount(eventsList.clusterByRoiPrecantage(i_e)) + 1;
            end
        else
            SumAPNotPass(eventsList.clusterByRoiPrecantage(i_e)) = SumAPNotPass(eventsList.clusterByRoiPrecantage(i_e)) +  max(load_v.V(soma, :));
            
            AllResults.somaV.(sprintf('c%d', eventsList.clusterByRoiPrecantage(i_e)))(end+1) = max(load_v.V(soma, :));
            countAPNotPass(eventsList.clusterByRoiPrecantage(i_e)) = countAPNotPass(eventsList.clusterByRoiPrecantage(i_e)) +  1;
        end
        
       
        if ~isempty(caS1_l_s)
            caS1_l_calc = samplingFactor .* (caS1_l_e - caS1_l_s);
            if any(caS1_l_calc > CaSpikeMS)
                curHt1 = 1;
                caSpikeClusterCountHt1(1, eventsList.clusterByRoiPrecantage(i_e)) = caSpikeClusterCountHt1(1, eventsList.clusterByRoiPrecantage(i_e)) + 1;
            end
        end
        
        if curHt1
            caSpikeClusterCountHt1(2, eventsList.clusterByRoiPrecantage(i_e)) = caSpikeClusterCountHt1(2, eventsList.clusterByRoiPrecantage(i_e)) +  max(load_v.V(ht1, :));
        else
            caSpikeClusterCountHt1(3, eventsList.clusterByRoiPrecantage(i_e)) = caSpikeClusterCountHt1(3, eventsList.clusterByRoiPrecantage(i_e)) +  max(load_v.V(ht1, :));
        end
        
        caSpikeClusterCountHt1(4, eventsList.clusterByRoiPrecantage(i_e)) = caSpikeClusterCountHt1(4, eventsList.clusterByRoiPrecantage(i_e)) +  max(load_v.V(ht1, :));
        caSpikeClusterCountHt1(5, eventsList.clusterByRoiPrecantage(i_e)) = caSpikeClusterCountHt1(5, eventsList.clusterByRoiPrecantage(i_e)) +  max([max(load_v.V(ht1, :)), max(load_v.V(ht2, :))]);
      
        AllResults.nexusV.(sprintf('c%d', eventsList.clusterByRoiPrecantage(i_e)))(end+1) = max([max(load_v.V(ht1, :)), max(load_v.V(ht2, :))]);
            
        
        if ~isempty(caS1_l_end_s)
            caS1_l_calc_end = samplingFactor .* (caS1_l_end_e - caS1_l_end_s);
            if any(caS1_l_calc_end > CaSpikeMS)
                curHt1_e = 1;
                caSpikeClusterCountHt1_end(1, eventsList.clusterByRoiPrecantage(i_e)) = caSpikeClusterCountHt1_end(1, eventsList.clusterByRoiPrecantage(i_e)) + 1;
            end
        end
        
        if curHt1_e
            caSpikeClusterCountHt1_end(2, eventsList.clusterByRoiPrecantage(i_e)) = caSpikeClusterCountHt1_end(2, eventsList.clusterByRoiPrecantage(i_e)) +  max(load_v.V(ht1_end, :));
        else
            caSpikeClusterCountHt1_end(3, eventsList.clusterByRoiPrecantage(i_e)) = caSpikeClusterCountHt1_end(3, eventsList.clusterByRoiPrecantage(i_e)) +  max(load_v.V(ht1_end, :));
        end
        
        caSpikeClusterCountHt1_end(4, eventsList.clusterByRoiPrecantage(i_e)) = caSpikeClusterCountHt1_end(4, eventsList.clusterByRoiPrecantage(i_e)) +  max(load_v.V(ht1_end, :));
        caSpikeClusterCountHt1_end(5, eventsList.clusterByRoiPrecantage(i_e)) = caSpikeClusterCountHt1_end(5, eventsList.clusterByRoiPrecantage(i_e)) +  max([max(load_v.V(ht1_end, :)), max(load_v.V(ht2_end, :))]);
      
        if ~isempty(caS1_l_start_s)
            caS1_l_calc_start = samplingFactor .* (caS1_l_start_e - caS1_l_start_s);
            if any(caS1_l_calc_start > CaSpikeMS)
                curHt1_s = 1;
                caSpikeClusterCountHt1_start(1, eventsList.clusterByRoiPrecantage(i_e)) = caSpikeClusterCountHt1_start(1, eventsList.clusterByRoiPrecantage(i_e)) + 1;
            end
        end
        
        if curHt1_s
            caSpikeClusterCountHt1_start(2, eventsList.clusterByRoiPrecantage(i_e)) = caSpikeClusterCountHt1_start(2, eventsList.clusterByRoiPrecantage(i_e)) +  max(load_v.V(ht1_start, :));
        else
            caSpikeClusterCountHt1_start(3, eventsList.clusterByRoiPrecantage(i_e)) = caSpikeClusterCountHt1_start(3, eventsList.clusterByRoiPrecantage(i_e)) +  max(load_v.V(ht1_start, :));
        end
        
        caSpikeClusterCountHt1_start(4, eventsList.clusterByRoiPrecantage(i_e)) = caSpikeClusterCountHt1_start(4, eventsList.clusterByRoiPrecantage(i_e)) +  max(load_v.V(ht1_start, :));
        caSpikeClusterCountHt1_start(5, eventsList.clusterByRoiPrecantage(i_e)) = caSpikeClusterCountHt1_start(5, eventsList.clusterByRoiPrecantage(i_e)) +  max([max(load_v.V(ht1_start, :)), max(load_v.V(ht2_start, :))]);
      
        if ~isempty(caS2_l_end_s)
            caS2_l_calc_end = samplingFactor .* (caS2_l_end_e - caS2_l_end_s);
            if any(caS2_l_calc_end > CaSpikeMS)
                curHt2_e = 1;
                caSpikeClusterCountHt2_end(1, eventsList.clusterByRoiPrecantage(i_e)) = caSpikeClusterCountHt2_end(1, eventsList.clusterByRoiPrecantage(i_e)) + 1;
            end
        end
        
        if curHt2_e
            caSpikeClusterCountHt2_end(2, eventsList.clusterByRoiPrecantage(i_e)) = caSpikeClusterCountHt2_end(2, eventsList.clusterByRoiPrecantage(i_e)) +  max(load_v.V(ht2_end, :));
        else
            caSpikeClusterCountHt2_end(3, eventsList.clusterByRoiPrecantage(i_e)) = caSpikeClusterCountHt2_end(3, eventsList.clusterByRoiPrecantage(i_e)) +  max(load_v.V(ht2_end, :));
        end
        
        caSpikeClusterCountHt2_end(4, eventsList.clusterByRoiPrecantage(i_e)) = caSpikeClusterCountHt2_end(4, eventsList.clusterByRoiPrecantage(i_e)) +  max(load_v.V(ht2_end, :));
        
        if ~isempty(caS2_l_start_s)
            caS2_l_calc_start = samplingFactor .* (caS2_l_start_e - caS2_l_start_s);
            if any(caS2_l_calc_start > CaSpikeMS)
                curHt2_s = 1;
                caSpikeClusterCountHt2_start(1, eventsList.clusterByRoiPrecantage(i_e)) = caSpikeClusterCountHt2_start(1, eventsList.clusterByRoiPrecantage(i_e)) + 1;
            end
        end 
        
        
        if curHt2_s
            caSpikeClusterCountHt2_start(2, eventsList.clusterByRoiPrecantage(i_e)) = caSpikeClusterCountHt2_start(2, eventsList.clusterByRoiPrecantage(i_e)) +  max(load_v.V(ht2_start, :));
        else
            caSpikeClusterCountHt2_start(3, eventsList.clusterByRoiPrecantage(i_e)) = caSpikeClusterCountHt2_start(3, eventsList.clusterByRoiPrecantage(i_e)) +  max(load_v.V(ht2_start, :));
        end
        
        caSpikeClusterCountHt2_start(4, eventsList.clusterByRoiPrecantage(i_e)) = caSpikeClusterCountHt2_start(4, eventsList.clusterByRoiPrecantage(i_e)) +  max(load_v.V(ht2_start, :));
        
         if ~isempty(caS2_l_s)
            caS2_l_calc = samplingFactor .* (caS2_l_e - caS2_l_s);
            if any(caS2_l_calc > CaSpikeMS)
                curHt2 = 1;
                caSpikeClusterCountHt2(1, eventsList.clusterByRoiPrecantage(i_e)) = caSpikeClusterCountHt2(1, eventsList.clusterByRoiPrecantage(i_e)) + 1;
            end
         end
         
        if curHt2
            caSpikeClusterCountHt2(2, eventsList.clusterByRoiPrecantage(i_e)) = caSpikeClusterCountHt2(2, eventsList.clusterByRoiPrecantage(i_e)) +  max(load_v.V(ht2, :));
        else
            caSpikeClusterCountHt2(3, eventsList.clusterByRoiPrecantage(i_e)) = caSpikeClusterCountHt2(3, eventsList.clusterByRoiPrecantage(i_e)) +  max(load_v.V(ht2, :));
        end
        
        caSpikeClusterCountHt2(4, eventsList.clusterByRoiPrecantage(i_e)) = caSpikeClusterCountHt2(4, eventsList.clusterByRoiPrecantage(i_e)) +  max(load_v.V(ht2, :));
        
         if curHt2_e == 1 && ...
                 curHt1_e == 0 && ...
                 curHt1_s == 0 && ...
                 curHt1 == 0
            OnlyHt2CaSpike(eventsList.clusterByRoiPrecantage(i_e)) = OnlyHt2CaSpike(eventsList.clusterByRoiPrecantage(i_e)) + 1;
         end
         
         if curHt1_e == 1 && ...
                 curHt2_e == 0 && ...
                 curHt2_s == 0 && ...
                 curHt2 == 0
            OnlyHt1CaSpike(eventsList.clusterByRoiPrecantage(i_e)) = OnlyHt1CaSpike(eventsList.clusterByRoiPrecantage(i_e)) + 1;
         end
        
         sumNMDASpike = 0;
         for roi_i = 1:size(load_v.names, 1)
%              if contains(load_v.names(roi_i, :), 'roi')
                nmda = load_v.V(roi_i, :) > NMDASpikeAmp;
                nmda_start = find(nmda(1:end-1)==0 & nmda(2:end)==1);
                nmda_end = find(nmda(1:end-1)==1 & nmda(2:end)==0);
                
                if nmda(1) == 1
                   nmda_start = [1, nmda_start]; 
                end
                
                if nmda(end) == 1
                   nmda_end = [nmda_end, size(load_v.V, 2)]; 
                end
                
                if ~isempty(nmda_start)
                    nmda_l_calc = samplingFactor .* (nmda_end - nmda_start);
                    if any(nmda_l_calc >= nmdaSpikeMS)
                        sumNMDASpike = sumNMDASpike + 1;
                    end
                end
%              end          
         end
         
         if sumNMDASpike > 0
             nmdaSpikeClusterCount(eventsList.clusterByRoiPrecantage(i_e)) = nmdaSpikeClusterCount(eventsList.clusterByRoiPrecantage(i_e)) + 1;
             nmdaSpikeClusterNumber(eventsList.clusterByRoiPrecantage(i_e)) = nmdaSpikeClusterNumber(eventsList.clusterByRoiPrecantage(i_e)) + sumNMDASpike;
         end
         
         AllResults.nmdaBranches.(sprintf('c%d', eventsList.clusterByRoiPrecantage(i_e)))(end+1) = sumNMDASpike;
        
    end
    
    for i_c = 1:4
        clusterCount = sum(eventsList.clusterByRoiPrecantage == i_c);
        
        if caSpikeClusterCountHt1(1, i_c) ~= 0
            caSpikeClusterCountHt1(2, i_c) = caSpikeClusterCountHt1(2, i_c) ./ max([1, caSpikeClusterCountHt1(1, i_c)]);
        else
            caSpikeClusterCountHt1(2, i_c) = nan;
        end
        
        if caSpikeClusterCountHt1_end(1, i_c) ~= 0
            caSpikeClusterCountHt1_end(2, i_c) =  caSpikeClusterCountHt1_end(2, i_c) ./ max([1, caSpikeClusterCountHt1_end(1, i_c)]);
        else
            caSpikeClusterCountHt1_end(2, i_c) = nan;
        end
        
        if caSpikeClusterCountHt1_start(1, i_c) ~= 0
            caSpikeClusterCountHt1_start(2, i_c) = caSpikeClusterCountHt1_start(2, i_c) ./ max([1, caSpikeClusterCountHt1_start(1, i_c)]);
        else
            caSpikeClusterCountHt1_start(2, i_c) = nan;
        end
        
        if caSpikeClusterCountHt2(1, i_c) ~= 0
            caSpikeClusterCountHt2(2, i_c) = caSpikeClusterCountHt2(2, i_c) ./ max([1, caSpikeClusterCountHt2(1, i_c)]);
        else
            caSpikeClusterCountHt2(2, i_c) = nan;
        end
        
        if caSpikeClusterCountHt2_end(1, i_c) ~= 0
            caSpikeClusterCountHt2_end(2, i_c) = caSpikeClusterCountHt2_end(2, i_c) ./ max([1, caSpikeClusterCountHt2_end(1, i_c)]);
        else
            caSpikeClusterCountHt2_end(2, i_c) = nan;
        end
        
        if caSpikeClusterCountHt2_start(1, i_c) ~= 0
            caSpikeClusterCountHt2_start(2, i_c) = caSpikeClusterCountHt2_start(2, i_c) ./ max([1, caSpikeClusterCountHt2_start(1, i_c)]);
        else
            caSpikeClusterCountHt2_start(2, i_c) = nan;
        end
        
        if (clusterCount - caSpikeClusterCountHt1(1, i_c)) ~= 0 
            caSpikeClusterCountHt1(3, i_c) = caSpikeClusterCountHt1(3, i_c) ./ max([1, (clusterCount - caSpikeClusterCountHt1(1, i_c))]);
        else
            caSpikeClusterCountHt1(3, i_c) = nan;
        end
        
        if (clusterCount - caSpikeClusterCountHt1_end(1, i_c)) ~= 0
            caSpikeClusterCountHt1_end(3, i_c) = caSpikeClusterCountHt1_end(3, i_c) ./ max([1, (clusterCount - caSpikeClusterCountHt1_end(1, i_c))]);
        else
            caSpikeClusterCountHt1_end(3, i_c) = nan;
        end
        
        if (clusterCount - caSpikeClusterCountHt1_start(1, i_c)) ~= 0 
            caSpikeClusterCountHt1_start(3, i_c) = caSpikeClusterCountHt1_start(3, i_c) ./ max([1, (clusterCount - caSpikeClusterCountHt1_start(1, i_c))]);
        else
            caSpikeClusterCountHt1_start(3, i_c) = nan;
        end
        
        if (clusterCount - caSpikeClusterCountHt2(1, i_c)) ~= 0 
            caSpikeClusterCountHt2(3, i_c) = caSpikeClusterCountHt2(3, i_c) ./ max([1, (clusterCount - caSpikeClusterCountHt2(1, i_c))]);
        else
            caSpikeClusterCountHt2(3, i_c) = nan;
        end
        
        if (clusterCount - caSpikeClusterCountHt2_end(1, i_c)) ~= 0 
            caSpikeClusterCountHt2_end(3, i_c) = caSpikeClusterCountHt2_end(3, i_c) ./ max([1, (clusterCount - caSpikeClusterCountHt2_end(1, i_c))]);
        else
            caSpikeClusterCountHt2_end(3, i_c) = nan;
        end
        
        if (clusterCount - caSpikeClusterCountHt2_start(1, i_c)) ~= 0 
            caSpikeClusterCountHt2_start(3, i_c) = caSpikeClusterCountHt2_start(3, i_c) ./ max([1, (clusterCount - caSpikeClusterCountHt2_start(1, i_c))]);
        else
            caSpikeClusterCountHt2_start(3, i_c) = nan;
        end
        
        caSpikeClusterCountHt1(4, i_c) = caSpikeClusterCountHt1(4, i_c) / clusterCount;
        caSpikeClusterCountHt1_end(4, i_c) = caSpikeClusterCountHt1_end(4, i_c) / clusterCount;
        caSpikeClusterCountHt1_start(4, i_c) = caSpikeClusterCountHt1_start(4, i_c) / clusterCount;
        caSpikeClusterCountHt2(4, i_c) = caSpikeClusterCountHt2(4, i_c) / clusterCount;
        caSpikeClusterCountHt2_end(4, i_c) = caSpikeClusterCountHt2_end(4, i_c) / clusterCount;
        caSpikeClusterCountHt2_start(4, i_c) = caSpikeClusterCountHt2_start(4, i_c) / clusterCount;
        
        caSpikeClusterCountHt1(5, i_c) = caSpikeClusterCountHt1(5, i_c) / clusterCount;
        caSpikeClusterCountHt1_end(5, i_c) = caSpikeClusterCountHt1_end(5, i_c) / clusterCount;
        caSpikeClusterCountHt1_start(5, i_c) = caSpikeClusterCountHt1_start(5, i_c) / clusterCount;
         
        caSpikeClusterCountHt1(1, i_c) = caSpikeClusterCountHt1(1, i_c) / clusterCount;
        caSpikeClusterCountHt1_end(1, i_c) = caSpikeClusterCountHt1_end(1, i_c) / clusterCount;
        caSpikeClusterCountHt1_start(1, i_c) = caSpikeClusterCountHt1_start(1, i_c) / clusterCount;
        caSpikeClusterCountHt2(1, i_c) = caSpikeClusterCountHt2(1, i_c) / clusterCount;
        caSpikeClusterCountHt2_end(1, i_c) = caSpikeClusterCountHt2_end(1, i_c) / clusterCount;
        caSpikeClusterCountHt2_start(1, i_c) = caSpikeClusterCountHt2_start(1, i_c) / clusterCount;
        
        nmdaSpikeClusterCount(i_c) = nmdaSpikeClusterCount(i_c) / clusterCount;
        nmdaSpikeClusterNumber(i_c) = nmdaSpikeClusterNumber(i_c) / clusterCount;
        ApClusterCount(i_c) = ApClusterCount(i_c) / clusterCount;
        SumAPNotPass(i_c) = SumAPNotPass(i_c) / countAPNotPass(i_c);
        
        synCountTotal(i_c) = synCountTotal(i_c)/ clusterCount;
        synGmaxTotal(i_c) = synGmaxTotal(i_c)/ clusterCount;
        synCountSide0(i_c) = synCountSide0(i_c)/ clusterCount;
        synCountSide1(i_c) = synCountSide1(i_c) / clusterCount;
        synSizeSumSide0(i_c) = synSizeSumSide0(i_c)/ clusterCount;
        synSizeSumSide1(i_c) = synSizeSumSide1(i_c)/ clusterCount;
        ratioMin2MaxSyn(i_c) = ratioMin2MaxSyn(i_c) / clusterCount;
        ratioMin2MaxGmax(i_c) = ratioMin2MaxGmax(i_c) / clusterCount;
        onlySynOnOneSize(i_c) = onlySynOnOneSize(i_c) / clusterCount; 
        OnlyHt1CaSpike(i_c) = OnlyHt1CaSpike(i_c) / clusterCount;
        OnlyHt2CaSpike(i_c) = OnlyHt2CaSpike(i_c) / clusterCount;
        gNMDA(i_c) = gNMDA(i_c) / clusterCount;
        resultsSynDist(i_c, :) = resultsSynDist(i_c, :) / resultsSynDist_count(i_c);
        synDistributionDepth3(i_c) = synDistributionDepth3(i_c) ./ clusterCount;
    end
    
    
    save([outputPath, '\synDistDepth3_allevent01prec.mat'], 'synDistributionDepth3');
    
    tResults = table(caSpikeClusterCountHt1(1,:)', caSpikeClusterCountHt1_start(1,:)', caSpikeClusterCountHt1_end(1,:)',...
        caSpikeClusterCountHt2(1,:)', caSpikeClusterCountHt2_start(1,:)', caSpikeClusterCountHt2_end(1,:)',...
        caSpikeClusterCountHt1(2,:)', caSpikeClusterCountHt1_start(2,:)', caSpikeClusterCountHt1_end(2,:)',...
        caSpikeClusterCountHt2(2,:)', caSpikeClusterCountHt2_start(2,:)', caSpikeClusterCountHt2_end(2,:)',...
        caSpikeClusterCountHt1(3,:)', caSpikeClusterCountHt1_start(3,:)', caSpikeClusterCountHt1_end(3,:)',...
        caSpikeClusterCountHt2(3,:)', caSpikeClusterCountHt2_start(3,:)', caSpikeClusterCountHt2_end(3,:)',...
        caSpikeClusterCountHt1(4,:)', caSpikeClusterCountHt1_start(4,:)', caSpikeClusterCountHt1_end(4,:)',...
        caSpikeClusterCountHt2(4,:)', caSpikeClusterCountHt2_start(4,:)', caSpikeClusterCountHt2_end(4,:)',...
        caSpikeClusterCountHt1(5,:)', caSpikeClusterCountHt1_start(5,:)', caSpikeClusterCountHt1_end(5,:)',...
        nmdaSpikeClusterCount',nmdaSpikeClusterNumber', ApClusterCount', SumAPNotPass',...
        synCountTotal',synGmaxTotal', synCountSide0',synSizeSumSide0',synCountSide1', synSizeSumSide1', onlySynOnOneSize', ratioMin2MaxSyn', ratioMin2MaxGmax', OnlyHt1CaSpike', OnlyHt2CaSpike', gNMDA', resultsSynDist(:, 1), resultsSynDist(:, 2), resultsSynDist(:, 3), resultsSynDist(:, 4),resultsSynDist(:, 5), resultsSynDist(:, 6), resultsSynDist(:, 7), resultsSynDist(:, 8),...
        'RowNames', {'Cluster1', 'Cluster2', 'Cluster3', 'Cluster4'},...
        'VariableNames',...
        {'CaSpike_side1', 'CaSpike_side1_start', 'CaSpike_side1_end',...
        'CaSpike_side2','CaSpike_side2_start', 'CaSpike_side2_end',...
        'CaSpike_side1_Voltage', 'CaSpike_side1_start_Voltage', 'CaSpike_side1_end_Voltage',...
        'CaSpike_side2_Voltage','CaSpike_side2_start_Voltage', 'CaSpike_side2_end_Voltage',...
        'NoCaSpike_side1_Voltage', 'No_CaSpike_side1_start_Voltage', 'No_CaSpike_side1_end_Voltage',...
        'No_CaSpike_side2_Voltage','No_CaSpike_side2_start_Voltage', 'No_CaSpike_side2_end_Voltage',...
        'Nexus_side1_Voltage', 'Nexus_side1_start_Voltage', 'Nexus_side1_end_Voltage',...
        'Nexus_side2_Voltage','Nexus_side2_start_Voltage', 'Nexus_side2_end_Voltage',...
        'Nexus_Max_Voltage', 'Nexus_Max_start_Voltage', 'Nexus_Max_end_Voltage',...
        'NMDA_precentage', 'NMDA_number', 'AP', 'NearSoma_NotPassAPMean', ...
        'SynTotalCount', 'SynTotalGmax', 'SynSide0Count', 'SynSide0Gmax', 'SynSide1Count', 'SynSide1Gmax', 'OnlyOneSideSyn', 'ratioMin2MaxSyn', 'ratioMin2MaxGmax', 'OnlySide1Ca', 'OnlySide2Ca', 'gNMDA', 'SynDistributionCluster50', 'SynDistributionSyn50', 'SynDistributionCluster100', 'SynDistributionSyn100', 'SynDistributionCluster150', 'SynDistributionSyn150', 'SynDistributionCluster200', 'SynDistributionSyn200'});
    writetable(tResults, [outputPath, 'SimResultsPostAnalysisFinal_allevent01prec.csv'])


    f = figure; hold on;
    boxplot([AllResults.gNMDA.c1, AllResults.gNMDA.c2,AllResults.gNMDA.c3,AllResults.gNMDA.c4], ...
        [repmat({'cluster1'},1,length(AllResults.gNMDA.c1)),repmat({'cluster2'},1,length(AllResults.gNMDA.c2)),...
        repmat({'cluster3'},1,length(AllResults.gNMDA.c3)),repmat({'cluster4'},1,length(AllResults.gNMDA.c4))]);
    title('gNMDA');
    mysave(f, [outputPath,'GNMDA_BOXPLOT']);
    
    
    f = figure; hold on;
    boxplot([AllResults.nexusV.c1, AllResults.nexusV.c2,AllResults.nexusV.c3,AllResults.nexusV.c4], ...
        [repmat({'cluster1'},1,length(AllResults.nexusV.c1)),repmat({'cluster2'},1,length(AllResults.nexusV.c2)),...
        repmat({'cluster3'},1,length(AllResults.nexusV.c3)),repmat({'cluster4'},1,length(AllResults.nexusV.c4))]);
    
    title('nexusV');
    mysave(f, [outputPath,'nexusV_BOXPLOT']);
    
    
    f = figure; hold on;
    boxplot([AllResults.somaV.c1, AllResults.somaV.c2,AllResults.somaV.c3,AllResults.somaV.c4], ...
        [repmat({'cluster1'},1,length(AllResults.somaV.c1)),repmat({'cluster2'},1,length(AllResults.somaV.c2)),...
        repmat({'cluster3'},1,length(AllResults.somaV.c3)),repmat({'cluster4'},1,length(AllResults.somaV.c4))]);
    
    title('somaV');
    mysave(f, [outputPath,'somaV_BOXPLOT']);
    
    meanNexusV.c1 = mean(AllResults.nexusV.c1);
    stdNexusV.c1 = std(AllResults.nexusV.c1);
    meanSomaV.c1 = mean(AllResults.somaV.c1);
    stdSomaV.c1 = std(AllResults.somaV.c1);
    meangnmda.c1 = mean(AllResults.gNMDA.c1);
    stdgnmda.c1 = std(AllResults.gNMDA.c1);
    meanNexusV.c2 = mean(AllResults.nexusV.c2);
    stdNexusV.c2 = std(AllResults.nexusV.c2);
    meanSomaV.c2 = mean(AllResults.somaV.c2);
    stdSomaV.c2 = std(AllResults.somaV.c2);
    meangnmda.c2 = mean(AllResults.gNMDA.c2);
    stdgnmda.c2 = std(AllResults.gNMDA.c2);
    meanNexusV.c3 = mean(AllResults.nexusV.c3);
    stdNexusV.c3 = std(AllResults.nexusV.c3);
    meanSomaV.c3 = mean(AllResults.somaV.c3);
    stdSomaV.c3 = std(AllResults.somaV.c3);
    meangnmda.c3 = mean(AllResults.gNMDA.c3);
    stdgnmda.c3 = std(AllResults.gNMDA.c3);
    meanNexusV.c4 = mean(AllResults.nexusV.c4);
    stdNexusV.c4 = std(AllResults.nexusV.c4);
    meanSomaV.c4 = mean(AllResults.somaV.c4);
    stdSomaV.c4 = std(AllResults.somaV.c4);
    meangnmda.c4 = mean(AllResults.gNMDA.c4);
    stdgnmda.c4 = std(AllResults.gNMDA.c4);
    
    save([outputPath,'meanAndSTD'], 'meangnmda', 'meanNexusV', 'meanSomaV', 'stdgnmda', 'stdSomaV', 'stdNexusV');
end

function re = getRoiName(names)
    if contains(names, 'apic')
       re = sprintf('roi%05d', sscanf(names, 'apic[%d]'));
    elseif contains(names, 'ep')
       re = sprintf('roi%05d', sscanf(names, 'ep%d'));
    elseif contains(names, 'bp')
       re = sprintf('roi%05d', sscanf(names, 'bp%d'));
    elseif contains(names, 'roi')
       re = sprintf('roi%05d', sscanf(names, 'roi%05d'));
    end
end

function re2 = getSynDistanceDist(synIndexNode, SPMatrix)
    re3 = zeros(length(synIndexNode), length(synIndexNode));
    re = [];
    for i = 1:length(synIndexNode)
        for k = (i+1):length(synIndexNode)
            re3(i,k) = SPMatrix(synIndexNode(i), synIndexNode(k));
            re3(k,i) = re3(i,k);
            re(end+1) = re3(i,k);
        end
    end
    
    idx = dbscan(re3,50,4,'Distance','precomputed');
    clustersR = max(unique(idx));
    if clustersR == -1
        clustersR = 0;
        binCount = 0;
    else
        idx(idx==-1) = [];
        [binCount,~] = histc(idx,unique(idx));
%         binCount = binCount(2:end);
        clustersR = length(unique(idx));
    end
   
    re2(1) = clustersR;
    re2(2) = mean(binCount);
    
    idx = dbscan(re3,100,4,'Distance','precomputed');
    clustersR = max(unique(idx));
    if clustersR == -1
        clustersR = 0;
        binCount = 0;
    else
        idx(idx==-1) = [];
        [binCount,~] = histc(idx,unique(idx));
%         binCount = binCount(2:end);
        clustersR = length(unique(idx));
    end
    
    re2(3) = clustersR;    
    re2(4) = mean(binCount);
%     
%     l = linkage(re, 'single');
%     c = cluster(l,'cutoff',100, 'criterion', 'distance');
%     uR = unique(c);
%     
%     clustersR = length(uR);
%     
%     [binCount,~] = histc(c,uR);

    idx = dbscan(re3,150,4,'Distance','precomputed');
    clustersR = max(unique(idx));
    if clustersR == -1
        clustersR = 0;
        binCount = 0;
    else
        
        idx(idx==-1) = [];
        [binCount,~] = histc(idx,unique(idx));
%         binCount = binCount(2:end);
        clustersR = length(unique(idx));
    end
   
    re2(5) = clustersR;
    re2(6) = mean(binCount);
    
    idx = dbscan(re3,200,4,'Distance','precomputed');
    clustersR = max(unique(idx));
    if clustersR == -1
        clustersR = 0;
        binCount = 0;
    else
        
        idx(idx==-1) = [];
        [binCount,~] = histc(idx,unique(idx));
%         binCount = binCount(2:end);
        clustersR = length(unique(idx));
    end
   
    re2(7) = clustersR;
    re2(8) = mean(binCount);
    
    re2(9) = sum(re <= 50) ./ length(re);
end