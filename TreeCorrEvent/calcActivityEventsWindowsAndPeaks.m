function [windowFULL, windowToPeak, loc, pks] = calcActivityEventsWindowsAndPeaks(roiActivity, outputpath)
    activity_average = mean(roiActivity,2);
    baseLine = iqr(activity_average);
    threshold = 3*baseLine;
    [pks,loc,~,~]  = findpeaks(activity_average,'MinPeakHeight',threshold, 'MinPeakWidth', 3, 'MinPeakDistance', 3);
    
    fig = figure;
    hold on;
    plot(1:length(activity_average), activity_average);  
    plot(loc, pks,'o','MarkerSize',12);
    plot(1:length(activity_average), threshold * ones(length(activity_average),1));
    
    mysave(fig, [outputpath, '\SelectedEventsForROIS']);
  
    windowFULL = zeros(length(loc), 2);    
    windowToPeak = zeros(length(loc), 2);    
    eventsWindowsActivity_fromPeak = zeros(length(loc), 2);    
    
    for index = 1:length(loc)
        belowBaseLine_b = find(activity_average(loc(index):-1:1) <= baseLine,1);
        if isempty(belowBaseLine_b)
            [~, belowBaseLine_b] = min(activity_average(loc(index):-1:1));
        end
        
        windowFULL(index, 1) = loc(index) - belowBaseLine_b + 1;
        
        belowBaseLine = find(activity_average(loc(index):1:length(activity_average)) <= baseLine,1);
        if isempty(belowBaseLine)
            [~, belowBaseLine] = min(activity_average(loc(index):1:length(activity_average)));
        end
        
        windowFULL(index, 2) = loc(index) + belowBaseLine - 1;
        
        if (index > 1 && (windowFULL(index, 1) <= loc(index - 1, 1)))
            act = activity_average(loc(index-1):1:loc(index));
            TF = loc(index-1) + find(act == min(act)) - 1;
            windowFULL(index, 1) = TF;
            windowFULL(index - 1, 2) = TF;  
            eventsWindowsActivity_fromPeak(index - 1, 2) = TF;
        end
        
        windowToPeak(index, 1) = windowFULL(index, 1);
        windowToPeak(index, 2) = loc(index);
        
        eventsWindowsActivity_fromPeak(index, 1) = loc(index);
        eventsWindowsActivity_fromPeak(index, 2) = windowFULL(index, 2); 
    end
end