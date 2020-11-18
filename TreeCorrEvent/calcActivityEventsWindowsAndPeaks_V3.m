function [allEventsTable, roiActivity_comb] = calcActivityEventsWindowsAndPeaks_V3(roiActivity, outputpath, clusterCount, samplingRate, tr_frame_count, aV, roiActivityNames, sigmaChangeValue, mean_aV)
    
    roi_locationFull_pks = [];
    roi_locationFull_H = [];
    all_locationFull_cluster = [];
    

    for i = 1:size(roiActivity, 2)
        ac_curr = roiActivity(:, i);
        [~, ~, roi_locationFull_pks{i}, roi_locationFull_H{i}, roiActivity_foreventDetector(:,i), roiActivity_comb(:, i)] = calcRoiEventDetectorByMLSpike_V3(ac_curr, 1 / samplingRate, tr_frame_count, aV(i), outputpath, i, clusterCount, roiActivityNames(i), sigmaChangeValue(i), size(roiActivity, 2));
    end
    
    meanROIActivityForDetector = mean(roiActivity_foreventDetector , 2);
    meanROIActivityForDetector(meanROIActivityForDetector ~= 0) = meanROIActivityForDetector(meanROIActivityForDetector ~= 0) + 0.1;
    
    meanCombActivity = mean(roiActivity_comb, 2);
    
    par = tps_mlspikes('par');
    par.dt = 1/samplingRate;
    par.a = 0.1;
    par.drift.parameter = .015;
    par.dographsummary = false;

    Fpred = tps_mlspikes(meanROIActivityForDetector,par);
    
    [all_locationFull_start, all_locationFull_end, ~, ~, ~, ~] = calcRoiEventDetectorByMLSpike_V3(Fpred, 1 / samplingRate, tr_frame_count, mean_aV, outputpath, 0, clusterCount, 'mean', 0, 1);
    all_locationFull_pks = zeros(length(all_locationFull_start),1);
    all_locationFull_H = zeros(length(all_locationFull_start),1);
    all_locationFull_roiPrecantage = zeros(length(all_locationFull_start),1);
    all_locationFull_Name = cell(length(all_locationFull_start),1);
    all_roiIndexInEvents = cell(length(all_locationFull_start),1);
    
    for index = 1:length(all_locationFull_start)
        current_event_roiCount = 0;
        roiIndexInEvent = zeros(size(roiActivity, 2), 1);
        
        for i = 1:size(roiActivity, 2)
            findEventR = (roi_locationFull_pks{i} >= all_locationFull_start(index) & roi_locationFull_pks{i} <= all_locationFull_end(index));
            if sum(findEventR) == 0
                continue;
            end
            
            current_event_roiCount = current_event_roiCount + 1;
            roiIndexInEvent(i) = 1;
        end
        
        if (current_event_roiCount == 0)
            
            all_locationFull_pks(index) = -1;
            continue;
        end
        
        all_locationFull_roiPrecantage(index) = current_event_roiCount / size(roiActivity, 2);
        all_roiIndexInEvents(index) = {roiIndexInEvent};
        
        [maxValue, maxLocation] = max(meanCombActivity(all_locationFull_start(index): all_locationFull_end(index)));
        all_locationFull_pks(index) = maxLocation + all_locationFull_start(index) - 1;
        all_locationFull_H(index) = maxValue;
        all_locationFull_Name(index) = {sprintf('event_%d', index)};       
    end
     
    events_location_pass = all_locationFull_pks ~= -1;
    allEventsTable = table(all_locationFull_Name(events_location_pass),...
    all_locationFull_start(events_location_pass)',...
    all_locationFull_end(events_location_pass)',...
    all_locationFull_pks(events_location_pass),...
    all_locationFull_H(events_location_pass),...
    all_locationFull_roiPrecantage(events_location_pass), zeros(sum(events_location_pass), 1), zeros(sum(events_location_pass), 1),...
    all_roiIndexInEvents(events_location_pass));
    
    allEventsTable.Properties.VariableNames = {'event_name', 'start', 'event_end', 'pks', 'H', 'roiPrecantage','clusterByH', 'clusterByRoiPrecantage', 'roisEvent'};
   
    all_locationFull_start = all_locationFull_start(events_location_pass);
    all_locationFull_end = all_locationFull_end(events_location_pass);
    all_locationFull_pks = all_locationFull_pks(events_location_pass);
    all_locationFull_H = all_locationFull_H(events_location_pass);
    
%     -----------------------------------------------------------------------------------------------------
    
    SpikeTrainClusterSecByH = getClusterForActivity(all_locationFull_H, clusterCount);
    printClusterResults(SpikeTrainClusterSecByH, clusterCount, meanCombActivity, all_locationFull_pks, all_locationFull_start, all_locationFull_end, all_locationFull_H, outputpath, 'ByH')
    
%   -----------------------------------------------------------------------------------------------------  
    
    SpikeTrainClusterSecByPrecantage = getClusterForActivity((allEventsTable.roiPrecantage), clusterCount);
    printClusterResults(SpikeTrainClusterSecByPrecantage, clusterCount, meanCombActivity, all_locationFull_pks, all_locationFull_start, all_locationFull_end, all_locationFull_H, outputpath, 'ByP')
    
%     -----------------------------------------------------------------------------------------------------
    
    allEventsTable.clusterByRoiPrecantage = SpikeTrainClusterSecByPrecantage';
    allEventsTable.clusterByH = SpikeTrainClusterSecByH';    
end