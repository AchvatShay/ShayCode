function plotEventCaForBehaveDataHandReach(behaveStartTime, allEventsTable, clusterCount, outputpath)
    for i = 0:clusterCount
        if i == 0
            currentCaTable = allEventsTable;
        else
            currentCaTable = allEventsTable(allEventsTable.clusterByH == i,:);
        end
        
        eventsStart = currentCaTable.start - behaveStartTime(currentCaTable.tr_index);
        eventsEnd = min(currentCaTable.event_end - behaveStartTime(currentCaTable.tr_index), currentCaTable.pks - behaveStartTime(currentCaTable.tr_index) + 50);
        min_lag = abs(min(eventsStart));
        
        max_lag = abs(max(eventsEnd));
        eventsStart_location = abs(eventsStart + min_lag);
        eventsEnd_location = abs(eventsEnd + min_lag);
        
        fig = figure;
        hold on;
        
        for ca_i = 1:size(currentCaTable, 1)
            plot(eventsStart_location(ca_i):eventsEnd_location(ca_i), ones(1, eventsEnd_location(ca_i) - eventsStart_location(ca_i)) * ca_i, 'k');
        end
        
        plot(zeros(1, length(eventsStart)), 1:size(currentCaTable, 1), '--k', 'LineWidth', 1.5)
        xlim([-1*min_lag,max_lag]);
        
        mysave(fig, [outputpath, '\BehaveAlignedHandreach\cluster_', num2str(i)]);
    end
end