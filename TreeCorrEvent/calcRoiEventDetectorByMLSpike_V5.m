function [SpikeTrainStart, SpikeTrainEnd, SpikeTrainPks,SpikeTrainH, eventDetector_activity, comb_activity] = calcRoiEventDetectorByMLSpike_V5(dataCurROI, ImageSampleTime, frameNum, aV, outputpath, activityIndex, clusterCount, roiName, sigmaChangeValue, roiCount, runMLS, thresholdForGn, EventsDetectionSpikeRate)       
    traceSig            = dataCurROI;         

    par = tps_mlspikes('par');
    par.dt = ImageSampleTime;
    par.a = aV;
    
    if activityIndex ~= 0
        par.tau = 0.8;
        par.saturation = 7e-4;
        par.F0 = [];
        par.pnonlin = [];

        par.hill = 2.99;
        par.c0 = 1.5;
    end
    
    if sigmaChangeValue ~= 0
        par.finetune.sigma = sigmaChangeValue;
    end
    
    if ~isnan(EventsDetectionSpikeRate)
        par.finetune.spikerate = EventsDetectionSpikeRate;
    end
    
    par.drift.parameter = .015;
    par.dographsummary = false;

    % -------------------------------------------------------------------------------    
    burstdelay = .3;

    [spk_cell, fitCell, drift, parest] = spk_est(traceSig,par);

    fit = fitCell;
    spikesk = {spk_cell};

    nsp = length(spikesk); 

    burstStart = [];
    burstEnd = [];
    burstPKS = [];
    burstCount = [];
    burstH = [];
    spk = zeros(1,0); 
    for i=1:nsp, spk = row(union(spk,spikesk{i})); end

    vectTiming = fn_timevector(spk,ImageSampleTime);
    vectIndex = find(vectTiming == 1);

    if ~isempty(spk) && ~isempty(vectIndex)
        delays = diff(spk);
        kburst = [1 1+find(delays>burstdelay)];
        nburst = length(kburst);
        burstend = [kburst(2:end)-1 length(spk)];
        tsep = [-Inf (spk(burstend(1:end-1))+spk(kburst(2:end)))/2 Inf];
        count = zeros(1,nsp);
        for kb=1:nburst
            for i=1:nsp
                count(i) = sum(spikesk{i}>tsep(kb) & spikesk{i}<=tsep(kb+1));
            end

            if kburst(kb) ==  length(spk)
                kburst(kb) =  max([1, length(spk) - 1]);
            end

            burstStart(kb) = round(spk(kburst(kb)) * (1/ImageSampleTime));
            burstEnd(kb) = round(spk(burstend(kb)) * (1/ImageSampleTime) + 1);

            if (burstEnd(kb) > length(traceSig))
                burstEnd(kb) = length(traceSig);
            end
            
            [burstH(kb), maxValue] = max(traceSig(burstStart(kb): burstEnd(kb)));

            burstPKS(kb) = maxValue + burstStart(kb) - 1;
            burstCount(kb) = count;
        end 
    end

    indexToremove = [];
    for k = 1:length(burstStart)
        if traceSig(burstStart(k)) > traceSig(burstEnd(k))
            indexToremove(end+1) = k;
        end
    end

    burstStart(indexToremove) = [];
    burstEnd(indexToremove) = [];
    burstPKS(indexToremove) = [];
    burstCount(indexToremove) = [];
    burstH(indexToremove) = [];
    
    SpikeTrainStart = burstStart;
    SpikeTrainEnd = burstEnd;
    SpikeTrainPks = burstPKS;
    SpikeTrainCountF = burstCount;
    SpikeTrainH = burstH;
    fitData = fit;    
    
    f = figure;
    hold on;
    
    sb1 = subplot(8, 1, 1:6);
    hold on;
    title(roiName);
    
    plot(traceSig)
    plot(fit)

    plot(SpikeTrainPks, fit(SpikeTrainPks), '*r');
    plot(SpikeTrainStart, fit(SpikeTrainStart), '*b');
    plot(SpikeTrainEnd, fit(SpikeTrainEnd), '*g');
 
    legend('Activity', 'Fit', 'Peaks', 'StartEvent', 'EndEvents');
    
    plot(SpikeTrainPks, SpikeTrainH, 'o');
    
    xlim([1, size(traceSig, 1)]);
%     ylim([-1, 5]);
    
    sb2 = subplot(8, 1, 8:8);
    imagesc(traceSig');
    colormap(jet);
    caxis(sb1.YLim);
       
    linkaxes([sb1, sb2], 'x');
    
    mysave(f, [outputpath, '\activity_averagePksHistByMLSpike_', num2str(activityIndex)]);
    
    close(f);
    
    comb_activity = fit;
    eventDetector_activity = zeros(length(fit), 1);
    for i = 1:length(SpikeTrainPks)
        comb_activity(SpikeTrainStart(i):SpikeTrainEnd(i)) = traceSig(SpikeTrainStart(i):SpikeTrainEnd(i));
        
        eventDetector_activity((SpikeTrainStart(i)):(SpikeTrainPks(i))) = ones(length((SpikeTrainStart(i)):SpikeTrainPks(i)),1);
    end
end