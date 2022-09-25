function simulationPostAllSummary()
    AnimalName = '4482_N1';
    DateAnimal = '11.5_LogN_50_20';
    NeuronName = 'N1';
    RunNumber = 'Run1';
    outputPath = sprintf('\\\\jackie-analysis\\e\\Shay\\Simulation\\%s\\Cai2\\%s_SR50\\Analysis\\%s\\Structural_VS_Functional\\final\\%s\\no_behave\\Pearson\\SP\\', AnimalName, DateAnimal,NeuronName, RunNumber);
    simResults = sprintf('\\\\jackie-analysis\\e\\ShayCode\\pythonProject\\larkumEtAl2009_2\\Simulation\\%s\\%s\\', AnimalName, DateAnimal);
    
%     hotZoneNames = {'bp145', 'bp2868'};
    
%     hotZoneNames = {'bp132', 'bp3169'};
 
    hotZoneNames = {'bp124', 'bp1059'};
 
    samplingR = 500;
    CaSpikeMS = 15;
    nmdaSpikeMS = 20;
    APMS = 0;
    CaSpikeAmp = -40;
    NMDASpikeAmp = -40;
     
    samplingFactor = 1000 / samplingR;
    
    nmdaSpikeClusterCount = zeros(1, 500);
    ApClusterCount = zeros(1, 500);
    SumAPNotPass = zeros(1, 500);
    caSpikeClusterCountHt1 = zeros(1, 500);
    caSpikeClusterCountHt1_end = zeros(1, 500);
    caSpikeClusterCountHt2_end = zeros(1, 500);
    caSpikeClusterCountHt1_start = zeros(1, 500);
    caSpikeClusterCountHt2_start = zeros(1, 500);
    caSpikeClusterCountHt2 = zeros(1, 500);
    synTotalCount = zeros(1, 500);
    synTotalGmax = zeros(1, 500);
    
    for i = 1:500
        load_v = load([simResults, sprintf('\\matlab_SimulationResults_%03d.mat', i-1)], 'V', 'selectedSYNSectionName', 'selectedSYNSectionGmax', 'names');
        synTotalCount(i) = length(load_v.selectedSYNSectionName);
        synTotalGmax(i) = sum(load_v.selectedSYNSectionGmax);
               
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
        
        caS1_end = load_v.V(ht1_end, :) > CaSpikeAmp;
        caS1_l_end_s = find(caS1_end(1:end-1)==0 & caS1_end(2:end)==1);
        caS1_l_end_e = find(caS1_end(1:end-1)==1 & caS1_end(2:end)==0);
        
        caS1_start = load_v.V(ht1_start, :) > CaSpikeAmp;
        caS1_l_start_s = find(caS1_start(1:end-1)==0 & caS1_start(2:end)==1);
        caS1_l_start_e = find(caS1_start(1:end-1)==1 & caS1_start(2:end)==0);
        
        caS2 = load_v.V(ht2, :) > CaSpikeAmp;
        caS2_l_s = find(caS2(1:end-1) ==0 & caS2(2:end) == 1);
        caS2_l_e = find(caS2(1:end-1) == 1 & caS2(2:end) == 0);
                       
        caS2_end = load_v.V(ht2_end, :) > CaSpikeAmp;
        caS2_l_end_s = find(caS2_end(1:end-1)==0 & caS2_end(2:end)==1);
        caS2_l_end_e = find(caS2_end(1:end-1)==1 & caS2_end(2:end)==0);
        
        caS2_start = load_v.V(ht2_start, :) > CaSpikeAmp;
        caS2_l_start_s = find(caS2_start(1:end-1)==0 & caS2_start(2:end)==1);
        caS2_l_start_e = find(caS2_start(1:end-1)==1 & caS2_start(2:end)==0);
        
        Ap1 = load_v.V(soma, :) > -10;
        Ap1_l_s = find(Ap1(1:end-1)==0 & Ap1(2:end)==1);
        Ap1_l_e = find(Ap1(1:end-1)==1 & Ap1(2:end)==0);
        
        if ~isempty(Ap1_l_s)
            Ap1_l_calc = samplingFactor .* (Ap1_l_e - Ap1_l_s);
            if any(Ap1_l_calc > APMS)
                ApClusterCount(i) = 1;
            end
            SumAPNotPass(i) = nan;
        else
            SumAPNotPass(i) = max(load_v.V(soma, :));
        end
        
       
        if ~isempty(caS1_l_s)
            caS1_l_calc = samplingFactor .* (caS1_l_e - caS1_l_s);
            if any(caS1_l_calc > CaSpikeMS)
                caSpikeClusterCountHt1(i) = 1;
            end
        end
        
        
        if ~isempty(caS1_l_end_s)
            caS1_l_calc_end = samplingFactor .* (caS1_l_end_e - caS1_l_end_s);
            if any(caS1_l_calc_end > CaSpikeMS)
                caSpikeClusterCountHt1_end(i) = 1;
            end
        end
        
        
        if ~isempty(caS1_l_start_s)
            caS1_l_calc_start = samplingFactor .* (caS1_l_start_e - caS1_l_start_s);
            if any(caS1_l_calc_start > CaSpikeMS)
                caSpikeClusterCountHt1_start(i) = 1;
            end
        end
        
        if ~isempty(caS2_l_end_s)
            caS2_l_calc_end = samplingFactor .* (caS2_l_end_e - caS2_l_end_s);
            if any(caS2_l_calc_end > CaSpikeMS)
                caSpikeClusterCountHt2_end(i) = 1;
            end
        end
        
        
        if ~isempty(caS2_l_start_s)
            caS2_l_calc_start = samplingFactor .* (caS2_l_start_e - caS2_l_start_s);
            if any(caS2_l_calc_start > CaSpikeMS)
                caSpikeClusterCountHt2_start(i) = 1;
            end
        end 
        
         if ~isempty(caS2_l_s)
            caS2_l_calc = samplingFactor .* (caS2_l_e - caS2_l_s);
            if any(caS2_l_calc > CaSpikeMS)
                caSpikeClusterCountHt2(i) = 1;
            end
         end
        
         for roi_i = 1:size(load_v.names, 1)
            nmda = load_v.V(roi_i, :) > NMDASpikeAmp;
            nmda_start = find(nmda(1:end-1)==0 & nmda(2:end)==1);
            nmda_end = find(nmda(1:end-1)==1 & nmda(2:end)==0);
            if ~isempty(nmda_start)
                nmda_l_calc = samplingFactor .* (nmda_end - nmda_start);
                if any(nmda_l_calc >= nmdaSpikeMS)
                    nmdaSpikeClusterCount(i) = nmdaSpikeClusterCount(i) + 1;
                end
            end         
         end
    end
    
    
    f = figure;
    hold on;
    ylabel('NMDA Precentage');
    xlabel('Syn Count');
    scatter(synTotalCount, nmdaSpikeClusterCount ./ size(load_v.names, 1), 'k', 'filled');
    mysave(f, [outputPath, '\synCountVsNMDACount']);
    
    f = figure;
    hold on;
    ylabel('NMDA Precentage');
    xlabel('Syn gmax');
    scatter(synTotalGmax, nmdaSpikeClusterCount ./ size(load_v.names, 1), 'k', 'filled');
    mysave(f, [outputPath, '\synGmaxVsNMDACount']);
    
    f = figure;
    hold on;
    ylabel('EPSP');
    xlabel('Syn gmax');
    scatter(synTotalGmax, SumAPNotPass, 'k', 'filled');
    mysave(f, [outputPath, '\synGmaxVsEPSP']);
   
    f = figure;
    hold on;
    ylabel('EPSP');
    xlabel('Syn Count');
    scatter(synTotalCount, SumAPNotPass, 'k', 'filled');
    mysave(f, [outputPath, '\synCountVsEPSP']);
    
    f = figure;
    hold on;
    subplot(1,3,1);
    h1 = histogram(synTotalCount(caSpikeClusterCountHt2_end == 1), 'DisplayName', 'End');
    h1.FaceAlpha = 0.5;
    title({'Ca Spike End',  hotZoneNames{2}});
    xlabel('Syn Count');
    ylabel('Histogram');
    
    subplot(1,3,2);
    h1 = histogram(synTotalCount(caSpikeClusterCountHt2_start == 1), 'DisplayName', 'Start');
    h1.FaceAlpha = 0.5;
    title({'Ca Spike Start',  hotZoneNames{2}});
    xlabel('Syn Count');
    ylabel('Histogram');
    
    subplot(1,3,3);
    h1 = histogram(synTotalCount(caSpikeClusterCountHt2 == 1), 'DisplayName', 'Center');
    h1.FaceAlpha = 0.5;
    title({'Ca Spike Center',  hotZoneNames{2}});
    xlabel('Syn Count');
    ylabel('Histogram');
    mysave(f, [outputPath, '\CaSpike2SynCount']);
    
        
    f = figure;
    hold on;
    subplot(1,3,1);
    h1 = histogram(synTotalGmax(caSpikeClusterCountHt2_end == 1), 'DisplayName', 'End');
    h1.FaceAlpha = 0.5;
    title({'Ca Spike End',  hotZoneNames{2}});
    xlabel('Syn Gmax');
    ylabel('Histogram');
    
    subplot(1,3,2);
    h1 = histogram(synTotalGmax(caSpikeClusterCountHt2_start == 1), 'DisplayName', 'Start');
    h1.FaceAlpha = 0.5;
    title({'Ca Spike Start',  hotZoneNames{2}});
    xlabel('Syn Gmax');
    ylabel('Histogram');
    
    subplot(1,3,3);
    h1 = histogram(synTotalGmax(caSpikeClusterCountHt2 == 1), 'DisplayName', 'Center');
    h1.FaceAlpha = 0.5;
    title({'Ca Spike Center',  hotZoneNames{2}});
    xlabel('Syn Gmax');
    ylabel('Histogram');
    mysave(f, [outputPath, '\CaSpike2SynGmax']);
 
    
    f = figure;
    hold on;
    subplot(1,3,1);
    h1 = histogram(synTotalCount(caSpikeClusterCountHt1_end == 1), 'DisplayName', 'End');
    h1.FaceAlpha = 0.5;
    title({'Ca Spike End',  hotZoneNames{1}});
    xlabel('Syn Count');
    ylabel('Histogram');
    
    subplot(1,3,2);
    h1 = histogram(synTotalCount(caSpikeClusterCountHt1_start == 1), 'DisplayName', 'Start');
    h1.FaceAlpha = 0.5;
    title({'Ca Spike Start',  hotZoneNames{1}});
    xlabel('Syn Count');
    ylabel('Histogram');
    
    subplot(1,3,3);
    h1 = histogram(synTotalCount(caSpikeClusterCountHt1 == 1), 'DisplayName', 'Center');
    h1.FaceAlpha = 0.5;
    title({'Ca Spike Center',  hotZoneNames{1}});
    xlabel('Syn Count');
    ylabel('Histogram');
    mysave(f, [outputPath, '\CaSpike1SynCount']);
 
    f = figure;
    hold on;
    subplot(1,3,1);
    h1 = histogram(synTotalGmax(caSpikeClusterCountHt1_end == 1), 'DisplayName', 'End');
    h1.FaceAlpha = 0.5;
    title({'Ca Spike End',  hotZoneNames{1}});
    xlabel('Syn Gmax');
    ylabel('Histogram');
    
    subplot(1,3,2);
    h1 = histogram(synTotalGmax(caSpikeClusterCountHt1_start == 1), 'DisplayName', 'Start');
    h1.FaceAlpha = 0.5;
    title({'Ca Spike Start',  hotZoneNames{1}});
    xlabel('Syn Gmax');
    ylabel('Histogram');
    
    subplot(1,3,3);
    h1 = histogram(synTotalGmax(caSpikeClusterCountHt1 == 1), 'DisplayName', 'Center');
    h1.FaceAlpha = 0.5;
    title({'Ca Spike Center',  hotZoneNames{1}});
    xlabel('Syn Gmax');
    ylabel('Histogram');
    mysave(f, [outputPath, '\CaSpike1SynGmax']);
 
    f = figure;
    hold on;
    subplot(1,3,1);
    h1 = histogram(synTotalCount(ApClusterCount == 1));
    h1.FaceAlpha = 0.5;
    title({'Ap'});
    xlabel('Syn Count');
    ylabel('Histogram');

    subplot(1,3,3);
    h1 = histogram(synTotalGmax(ApClusterCount == 1));
    h1.FaceAlpha = 0.5;
    title({'AP'});
    xlabel('Syn Gmax');
    ylabel('Histogram');
    mysave(f, [outputPath, '\ApHistogram']);
 
end