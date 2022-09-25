function PosAnalysisSimulationCluster()
    AnimalName = '4481_N3_sm';
    DateAnimal = 'Comb_Control';
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
    gNMDA = zeros(1, 4);
    
   
%     eventsList.tr_index(eventsList.tr_index >= 239) = eventsList.tr_index(eventsList.tr_index >= 239) + 1; 
    
    for i_e = 1:size(eventsList, 1)
        trial_location = eventsList.tr_index(i_e) - 1;
        
        load_v = load([simResults, sprintf('\\matlab_SimulationResults_%05d.mat', trial_location)], 'V', 'selectedSYNSectionName', 'selectedSYNSectionGmax', 'names');
        
        
        indexLocationStart = max(1, round((eventsList.start(i_e) - (eventsList.tr_index(i_e) - 1)*(50*2.18))*10)-20);
        
        if i_e < size(eventsList, 1) && eventsList.tr_index(i_e+1) == eventsList.tr_index(i_e)
            indexLocationEnd = max(1, round((eventsList.start(i_e+1) - (eventsList.tr_index(i_e+1) - 1)*(50*2.18))*10)-20);        
        else
            indexLocationEnd = size(load_v.V, 2);
        end
        
%         indexLocationToCheckVoltage = max(1, indexLocationToCheckVoltage -10):(indexLocationToCheckVoltage+10);
%         
        load_v.V = load_v.V(:, indexLocationStart:indexLocationEnd);
        
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
        for syn = 1:size(load_v.selectedSYNSectionName, 1)
            synNameL = find(ismember(load_v.names, load_v.selectedSYNSectionName(syn ,:), 'rows'));
            synSide = namesLocationInList(synNameL);
            
            synCountTotal(eventsList.clusterByH(i_e)) = synCountTotal(eventsList.clusterByH(i_e)) + 1;
            synGmaxTotal(eventsList.clusterByH(i_e)) = synGmaxTotal(eventsList.clusterByH(i_e)) + load_v.selectedSYNSectionGmax(syn);
            
            if synSide == 0
                totalS0 = totalS0 + 1;
                gMaxS0 = gMaxS0 + load_v.selectedSYNSectionGmax(syn);
                synCountSide0(eventsList.clusterByH(i_e)) = synCountSide0(eventsList.clusterByH(i_e)) + 1;
                synSizeSumSide0(eventsList.clusterByH(i_e)) = synSizeSumSide0(eventsList.clusterByH(i_e)) + load_v.selectedSYNSectionGmax(syn);
            else
                totalS1 = totalS1 + 1;
                gMaxS1 = gMaxS1 + load_v.selectedSYNSectionGmax(syn);
                synCountSide1(eventsList.clusterByH(i_e)) = synCountSide1(eventsList.clusterByH(i_e)) + 1;
                synSizeSumSide1(eventsList.clusterByH(i_e)) = synSizeSumSide1(eventsList.clusterByH(i_e)) + load_v.selectedSYNSectionGmax(syn);
            end
        end
        
        if totalS0 == 0 || totalS1 == 0
            onlySynOnOneSize(eventsList.clusterByH(i_e)) = onlySynOnOneSize(eventsList.clusterByH(i_e))  + 1; 
        end
        
        ratioMin2MaxSyn(eventsList.clusterByH(i_e)) = ratioMin2MaxSyn(eventsList.clusterByH(i_e)) +  min([totalS0, totalS1]) / max([totalS0, totalS1]);
        ratioMin2MaxGmax(eventsList.clusterByH(i_e)) = ratioMin2MaxGmax(eventsList.clusterByH(i_e)) +  min([gMaxS0, gMaxS1]) / max([gMaxS0, gMaxS1]);
        
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
                ApClusterCount(eventsList.clusterByH(i_e)) = ApClusterCount(eventsList.clusterByH(i_e)) + 1;
            end
        else
            SumAPNotPass(eventsList.clusterByH(i_e)) = SumAPNotPass(eventsList.clusterByH(i_e)) +  max(load_v.V(soma, :));
            countAPNotPass(eventsList.clusterByH(i_e)) = countAPNotPass(eventsList.clusterByH(i_e)) +  1;
        end
        
       
        if ~isempty(caS1_l_s)
            caS1_l_calc = samplingFactor .* (caS1_l_e - caS1_l_s);
            if any(caS1_l_calc > CaSpikeMS)
                curHt1 = 1;
                caSpikeClusterCountHt1(1, eventsList.clusterByH(i_e)) = caSpikeClusterCountHt1(1, eventsList.clusterByH(i_e)) + 1;
            end
        end
        
        if curHt1
            caSpikeClusterCountHt1(2, eventsList.clusterByH(i_e)) = caSpikeClusterCountHt1(2, eventsList.clusterByH(i_e)) +  max(load_v.V(ht1, :));
        else
            caSpikeClusterCountHt1(3, eventsList.clusterByH(i_e)) = caSpikeClusterCountHt1(3, eventsList.clusterByH(i_e)) +  max(load_v.V(ht1, :));
        end
        
        caSpikeClusterCountHt1(4, eventsList.clusterByH(i_e)) = caSpikeClusterCountHt1(4, eventsList.clusterByH(i_e)) +  max(load_v.V(ht1, :));
        caSpikeClusterCountHt1(5, eventsList.clusterByH(i_e)) = caSpikeClusterCountHt1(5, eventsList.clusterByH(i_e)) +  max([max(load_v.V(ht1, :)), max(load_v.V(ht2, :))]);
      
        if ~isempty(caS1_l_end_s)
            caS1_l_calc_end = samplingFactor .* (caS1_l_end_e - caS1_l_end_s);
            if any(caS1_l_calc_end > CaSpikeMS)
                curHt1_e = 1;
                caSpikeClusterCountHt1_end(1, eventsList.clusterByH(i_e)) = caSpikeClusterCountHt1_end(1, eventsList.clusterByH(i_e)) + 1;
            end
        end
        
        if curHt1_e
            caSpikeClusterCountHt1_end(2, eventsList.clusterByH(i_e)) = caSpikeClusterCountHt1_end(2, eventsList.clusterByH(i_e)) +  max(load_v.V(ht1_end, :));
        else
            caSpikeClusterCountHt1_end(3, eventsList.clusterByH(i_e)) = caSpikeClusterCountHt1_end(3, eventsList.clusterByH(i_e)) +  max(load_v.V(ht1_end, :));
        end
        
        caSpikeClusterCountHt1_end(4, eventsList.clusterByH(i_e)) = caSpikeClusterCountHt1_end(4, eventsList.clusterByH(i_e)) +  max(load_v.V(ht1_end, :));
        caSpikeClusterCountHt1_end(5, eventsList.clusterByH(i_e)) = caSpikeClusterCountHt1_end(5, eventsList.clusterByH(i_e)) +  max([max(load_v.V(ht1_end, :)), max(load_v.V(ht2_end, :))]);
      
        if ~isempty(caS1_l_start_s)
            caS1_l_calc_start = samplingFactor .* (caS1_l_start_e - caS1_l_start_s);
            if any(caS1_l_calc_start > CaSpikeMS)
                curHt1_s = 1;
                caSpikeClusterCountHt1_start(1, eventsList.clusterByH(i_e)) = caSpikeClusterCountHt1_start(1, eventsList.clusterByH(i_e)) + 1;
            end
        end
        
        if curHt1_s
            caSpikeClusterCountHt1_start(2, eventsList.clusterByH(i_e)) = caSpikeClusterCountHt1_start(2, eventsList.clusterByH(i_e)) +  max(load_v.V(ht1_start, :));
        else
            caSpikeClusterCountHt1_start(3, eventsList.clusterByH(i_e)) = caSpikeClusterCountHt1_start(3, eventsList.clusterByH(i_e)) +  max(load_v.V(ht1_start, :));
        end
        
        caSpikeClusterCountHt1_start(4, eventsList.clusterByH(i_e)) = caSpikeClusterCountHt1_start(4, eventsList.clusterByH(i_e)) +  max(load_v.V(ht1_start, :));
        caSpikeClusterCountHt1_start(5, eventsList.clusterByH(i_e)) = caSpikeClusterCountHt1_start(5, eventsList.clusterByH(i_e)) +  max([max(load_v.V(ht1_start, :)), max(load_v.V(ht2_start, :))]);
      
        if ~isempty(caS2_l_end_s)
            caS2_l_calc_end = samplingFactor .* (caS2_l_end_e - caS2_l_end_s);
            if any(caS2_l_calc_end > CaSpikeMS)
                curHt2_e = 1;
                caSpikeClusterCountHt2_end(1, eventsList.clusterByH(i_e)) = caSpikeClusterCountHt2_end(1, eventsList.clusterByH(i_e)) + 1;
            end
        end
        
        if curHt2_e
            caSpikeClusterCountHt2_end(2, eventsList.clusterByH(i_e)) = caSpikeClusterCountHt2_end(2, eventsList.clusterByH(i_e)) +  max(load_v.V(ht2_end, :));
        else
            caSpikeClusterCountHt2_end(3, eventsList.clusterByH(i_e)) = caSpikeClusterCountHt2_end(3, eventsList.clusterByH(i_e)) +  max(load_v.V(ht2_end, :));
        end
        
        caSpikeClusterCountHt2_end(4, eventsList.clusterByH(i_e)) = caSpikeClusterCountHt2_end(4, eventsList.clusterByH(i_e)) +  max(load_v.V(ht2_end, :));
        
        if ~isempty(caS2_l_start_s)
            caS2_l_calc_start = samplingFactor .* (caS2_l_start_e - caS2_l_start_s);
            if any(caS2_l_calc_start > CaSpikeMS)
                curHt2_s = 1;
                caSpikeClusterCountHt2_start(1, eventsList.clusterByH(i_e)) = caSpikeClusterCountHt2_start(1, eventsList.clusterByH(i_e)) + 1;
            end
        end 
        
        
        if curHt2_s
            caSpikeClusterCountHt2_start(2, eventsList.clusterByH(i_e)) = caSpikeClusterCountHt2_start(2, eventsList.clusterByH(i_e)) +  max(load_v.V(ht2_start, :));
        else
            caSpikeClusterCountHt2_start(3, eventsList.clusterByH(i_e)) = caSpikeClusterCountHt2_start(3, eventsList.clusterByH(i_e)) +  max(load_v.V(ht2_start, :));
        end
        
        caSpikeClusterCountHt2_start(4, eventsList.clusterByH(i_e)) = caSpikeClusterCountHt2_start(4, eventsList.clusterByH(i_e)) +  max(load_v.V(ht2_start, :));
        
         if ~isempty(caS2_l_s)
            caS2_l_calc = samplingFactor .* (caS2_l_e - caS2_l_s);
            if any(caS2_l_calc > CaSpikeMS)
                curHt2 = 1;
                caSpikeClusterCountHt2(1, eventsList.clusterByH(i_e)) = caSpikeClusterCountHt2(1, eventsList.clusterByH(i_e)) + 1;
            end
         end
         
        if curHt2
            caSpikeClusterCountHt2(2, eventsList.clusterByH(i_e)) = caSpikeClusterCountHt2(2, eventsList.clusterByH(i_e)) +  max(load_v.V(ht2, :));
        else
            caSpikeClusterCountHt2(3, eventsList.clusterByH(i_e)) = caSpikeClusterCountHt2(3, eventsList.clusterByH(i_e)) +  max(load_v.V(ht2, :));
        end
        
        caSpikeClusterCountHt2(4, eventsList.clusterByH(i_e)) = caSpikeClusterCountHt2(4, eventsList.clusterByH(i_e)) +  max(load_v.V(ht2, :));
        
         if curHt2_e == 1 && ...
                 curHt1_e == 0 && ...
                 curHt1_s == 0 && ...
                 curHt1 == 0
            OnlyHt2CaSpike(eventsList.clusterByH(i_e)) = OnlyHt2CaSpike(eventsList.clusterByH(i_e)) + 1;
         end
         
         if curHt1_e == 1 && ...
                 curHt2_e == 0 && ...
                 curHt2_s == 0 && ...
                 curHt2 == 0
            OnlyHt1CaSpike(eventsList.clusterByH(i_e)) = OnlyHt1CaSpike(eventsList.clusterByH(i_e)) + 1;
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
             nmdaSpikeClusterCount(eventsList.clusterByH(i_e)) = nmdaSpikeClusterCount(eventsList.clusterByH(i_e)) + 1;
             nmdaSpikeClusterNumber(eventsList.clusterByH(i_e)) = nmdaSpikeClusterNumber(eventsList.clusterByH(i_e)) + sumNMDASpike;
         end
    end
    
    for i_c = 1:4
        clusterCount = sum(eventsList.clusterByH == i_c);
        
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
    end
    
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
        synCountTotal',synGmaxTotal', synCountSide0',synSizeSumSide0',synCountSide1', synSizeSumSide1', onlySynOnOneSize', ratioMin2MaxSyn', ratioMin2MaxGmax', OnlyHt1CaSpike', OnlyHt2CaSpike',...
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
        'SynTotalCount', 'SynTotalGmax', 'SynSide0Count', 'SynSide0Gmax', 'SynSide1Count', 'SynSide1Gmax', 'OnlyOneSideSyn', 'ratioMin2MaxSyn', 'ratioMin2MaxGmax', 'OnlySide1Ca', 'OnlySide2Ca'});
    writetable(tResults, [outputPath, 'SimResultsPostAnalysisFinal_V2.csv'])
end