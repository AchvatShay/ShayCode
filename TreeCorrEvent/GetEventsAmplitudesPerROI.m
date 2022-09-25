function [eventsAmplitudePerROITable] = GetEventsAmplitudesPerROI(roiActivity_comb, allEventsTable)

    % table for all events and ROIs: each row is an event, each column is
    % an ROI. for each ROI if it was active in the event we have its
    % amplutide and if it was not active in the event we have nan
    eventsAmplitudePerROITable = zeros(size(allEventsTable,1),size(roiActivity_comb,2));
    
    for i=1:size(allEventsTable,1)
        
        for j=1:size(roiActivity_comb,2)
            
            if (allEventsTable.roisEvent{i}(j) == 1) % if ROI j was active event i
                start_index = allEventsTable.start(i);
                end_index = allEventsTable.event_end(i);
                roiActivityForThisEvent = roiActivity_comb(start_index:end_index, j);
                [peakValue, peakIndex] = max(roiActivityForThisEvent);
                minValue = 0.8 * peakValue;
                
                index_forward_count = find(roiActivityForThisEvent(peakIndex:end) < minValue, 1);
                
                if ~isempty(index_forward_count)
                    index_forward = index_forward_count + peakIndex - 2;
                else
                    index_forward = length(roiActivityForThisEvent);
                end
                
                index_backward_count = find(roiActivityForThisEvent(1:peakIndex) < minValue, 1, 'last');
                
                if ~isempty(index_backward_count)
                    index_backward = index_backward_count + 1;
                else
                    index_backward = 1;
                end
               
                averageMaxPeak = mean(roiActivityForThisEvent(index_backward:index_forward));
%                 
%                 figure; hold on;
%                 plot(roiActivityForThisEvent);
%                 plot([1, length(roiActivityForThisEvent)], [minValue, minValue], '--b');
%                 plot([index_backward, index_backward], [min(roiActivityForThisEvent), max(roiActivityForThisEvent)], '--k');
%                 plot([index_forward, index_forward], [min(roiActivityForThisEvent), max(roiActivityForThisEvent)], '--k');
                
            else
                averageMaxPeak = nan;
            end  
            
            eventsAmplitudePerROITable(i, j) = averageMaxPeak;
        end
    end
end