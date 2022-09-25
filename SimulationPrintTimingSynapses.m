 function SimulationPrintTimingSynapses()
    
    tr = [0];
    
    for k = 1:length(tr)
        simTrialResults = ['E:\\ShayCode\\Layer2-3Code\\Palmer_et_al Model 2014\\Simulation\\BackgroundTest_11_030822\\matlab_SimulationResults_', sprintf('%05d', tr(k)), '.mat'];
        outputPath = 'E:\\ShayCode\\Layer2-3Code\\Palmer_et_al Model 2014\\Simulation\\BackgroundTest_11_030822\';

        fName = ['SynTiming_Background' num2str(tr(k)) '_all'];
        load(simTrialResults, 'BackTimingVector');

%         lowB = load('\\jackie-analysis\e\ShayCode\pythonProject\larkumEtAl2009_2\Simulation\4481_N3\13.4.21_control_DepthTo1\matlab_SimulationRandSynInfoBackG_3.mat', 'timingVector');
%         
%         HB = load('\\jackie-analysis\e\ShayCode\pythonProject\larkumEtAl2009_2\Simulation\4481_N3\13.4.21_control_DepthTo1\matlab_SimulationRandSynInfoBackG_6.mat', 'timingVector');
%         
        inputsSize = size(BackTimingVector, 1);
%         selectedsynTiming(end+1:end+50, :) = lowB.timingVector;
%         selectedsynTiming(end+1:end+50, :) = HB. timingVector;
%         
        figTree = figure();
        
        subplot(7,1, 1:4);
        
        hold on;
        
        for i = 1:size(BackTimingVector, 1)
            for j = 1:size(BackTimingVector, 2)
                if BackTimingVector(i,j) == 1
                    plot([j,j], [i-0.5,i+0.5], 'k', 'LineWidth', 1);
                end
            end
        end
        
        
        hold on;
        plot([50,50], [0,size(BackTimingVector, 1)+1], '--r', 'LineWidth', 1);
%         plot([180,180], [1,size(selectedsynTiming, 1)], '--k', 'LineWidth', 1);
%         plot([1,2180], [inputsSize+0.5,inputsSize+0.5], '--r', 'LineWidth', 1);
       
        ylim([0,size(BackTimingVector, 1)+1]);
        xlim([1,550]);
       
        ylabel('Synapse#');
        xlabel('Time (ms)');
        
        subplot(8,1,7:8);
        csum = sum( reshape(sum(BackTimingVector), 10, [])).' ;
        hold on;
        plot(1:10:550, csum, 'k', 'LineWidth', 1);
        ylim([0,1000]);
        xlim([1,550]);
        plot([50,50], [0,1000], '--r', 'LineWidth', 1);
%         plot([180,180], [0,60], '--k', 'LineWidth', 1);
        
        mysave(figTree, [outputPath, fName]);
    end
    
 end