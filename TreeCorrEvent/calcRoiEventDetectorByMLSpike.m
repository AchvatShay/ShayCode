function [SpikeTrainStart, SpikeTrainEnd, SpikeTrainPks, SpikeTrainH, SpikeTrainClusterSec] = calcRoiEventDetectorByMLSpike(dataCurROI, ImageSampleTime, frameNum, aV, outputpath, activityIndex, clusterCount)       
    traceSig            = dataCurROI;
        
    sampFreq        = 1/ImageSampleTime;
    
    SpikeTrainStart  = [];
    SpikeTrainEnd  = [];
    SpikeTrainPks  = [];
    SpikeTrainH = [];
    max_index = [];
    SpikeTrainCluster = [];
%     
    % parameters
    par = tps_mlspikes('par');
    par.dt = ImageSampleTime;
%     par.algo.estimate = 'proba';
    % (use autocalibrated parameters)
    par.a = aV;
%     
%     par.tau = 0.1;
%     par.finetune.sigma = 0.06;
    % (the OGB saturation and drift parameters are fixed)
%     par.saturation = 0.1;
    par.drift.parameter = .015;
    % (do not display graph summary)
%     par.dographsummary = false;

    [spk, fit, drift, parest] = spk_est(traceSig,par);
    
    spk = round(spk * sampFreq);  
    
    if isempty(spk)
        return;
    end
    
    spk = unique(spk);
    spk = [-1, spk];  
    spk_fin = spk(find(spk(2:end) - spk(1:(end - 1)) > 4) + 1);
    
    v_calc = (fit(2:(end)) - fit(1:(end-1)));
    v_calc = repelem(v_calc,1,1);
    v_calc = [v_calc(1) ;v_calc];
   
    v_slop = v_calc > 0;

    res = [0; find(v_slop(1:end-1) ~= v_slop(2:end)); length(v_calc)];

    for k = 1:length(res)-1
        if v_slop(res(k) + 1) == 0 & (res(k + 1) - res(k) <= 1)
            slop_value = 1;
            if (k-1>0)
                slop_value = v_slop(res(k-1) + 1) ;    
            end

            v_slop((res(k) + 1):res(k+1)) = slop_value;
            
            if slop_value == 1
                v_calc((res(k) + 1):res(k+1)) = 0.1;
            else
                v_calc((res(k) + 1):res(k+1)) = -0.1;
            end
        end
    end

    
    spk_index = 1;
    
    for i = 1:length(spk_fin)
        start_pos = spk_fin(i);
        
        nextPos = length(fit);
        if i < length(spk_fin)
            nextPos = spk_fin(i + 1);
        end
% %         ---------------------------------------------------------
        maxRes = find(fit((start_pos+1):nextPos) <= fit(start_pos), 1);
        if isempty(maxRes)
%             maxRes = find(abs(v_calc((start_pos+1):nextPos)) <= 0.0001, 1);
%             
%             if isempty(maxRes)
                maxRes = nextPos; 
%             else
%                 maxRes = maxRes(1) + start_pos;
%             end
        else
            maxRes = maxRes(1) + start_pos;
        end
        
        maxRes2 = maxRes;
        maxRes3 = find(fit(start_pos:maxRes2) == max(fit(start_pos:maxRes2)), 1);

        SpikeTrainPks(spk_index) = maxRes3(1) + start_pos - 1;
%         ---------------------------------------------------------


%         ---------------------------------------------------------
%         maxRes = find(v_calc((start_pos+1):nextPos) <= 0.0001, 1);
%         
%         if isempty(maxRes)
%             continue;
%         end
%  

%         SpikeTrainPks(spk_index) = maxRes(1) + start_pos - 1;
%         ---------------------------------------------------------

%         ---------------------------------------------------------
%         maxRes = find(v_calc((start_pos+1):nextPos) <= 0.0001, 1);
%         
%         if isempty(maxRes)
%             continue;
%         end
%  
%         maxRes2 = maxRes(1) + start_pos - 1;
%         
%         afterS1 = find(fit(maxRes2(1):nextPos) <= 0.9 * fit(maxRes2(1)), 1);
%         afterS1 = afterS1 + maxRes2(1) - 1;
%         maxRes3 = find(fit(start_pos:afterS1) == max(fit(start_pos:afterS1)), 1);
%  
%         SpikeTrainPks(spk_index) = maxRes3(1) + start_pos - 1;
%         ---------------------------------------------------------


        SpikeTrainStart(spk_index) = start_pos;
      
                               
        afterS = find(fit(SpikeTrainPks(spk_index):nextPos) <= 0.9 * fit(SpikeTrainPks(spk_index)), 1);
        afterS = afterS + SpikeTrainPks(spk_index) - 1;
        end_find_res = find(abs(v_calc(afterS:nextPos)) < 0.0001, 1);
        
        if isempty(end_find_res)
            end_find_res = nextPos; 
        else
            end_find_res = end_find_res + afterS - 1;
        end
        
        SpikeTrainEnd(spk_index) = end_find_res;
        
        [SpikeTrainH(spk_index), max_index(spk_index)] = max(traceSig(SpikeTrainStart(spk_index):SpikeTrainEnd(spk_index))); 
         max_index(spk_index) = max_index(spk_index) + SpikeTrainStart(spk_index) - 1;       
        spk_index = spk_index + 1;
    end 
    
    SpikeTrainCluster = kmeans(SpikeTrainH', clusterCount, 'Replicates',5, 'MaxIter', 500);
    
    clusterMaxValue = [];
    for i = 1:clusterCount
        clusterMaxValue(i) = max(SpikeTrainH(SpikeTrainCluster == i));
    end
    
    [~, cluster_sort_index] = sort(clusterMaxValue);
    SpikeTrainClusterSec = zeros(1, length(SpikeTrainCluster));
    for i = 1:clusterCount
        SpikeTrainClusterSec(SpikeTrainCluster == cluster_sort_index(i)) = i;
    end
   
    
    f = figure;
    hold on;
    plot(traceSig)
    plot(fit)

    plot(SpikeTrainPks, fit(SpikeTrainPks), '*r');
    plot(SpikeTrainStart, fit(SpikeTrainStart), '*b');
    plot(SpikeTrainEnd, fit(SpikeTrainEnd), '*g');
 
    
    for i = 1:clusterCount
        plot(max_index(SpikeTrainClusterSec == i), SpikeTrainH(SpikeTrainClusterSec == i), 'o');
    end
   
       
    mysave(f, [outputpath, '\activity_averagePksHistByMLSpike_', num2str(activityIndex)]);
end