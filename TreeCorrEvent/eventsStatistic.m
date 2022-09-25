function eventsStatistic(outputpath, allEventsTable, roiActivity_comb, selectedROISplitDepth1)
    
    outputpathCur = fullfile(outputpath, 'Exclusivity');
    mkdir(outputpathCur);
    
    precentageRatioName = {'All', 'Ratio 0.8-1.25', 'Ratio 0.5-0.8', 'Ratio 0-0.5', 'Ratio 1.25-2', 'Ratio above 2'};

    splitValues = [0,0.25;0.25,0.5;0.5,0.75;0.25,0.75;0.75,1];
    splitValuesName = {'0-25 percentage', '25-50 percentage', '50-75 percentage', '25-75 percentage', '75-100 percentage'};
    
    percentageRatio = allEventsTable.roiPrecantageSide1 ./ allEventsTable.roiPrecantageSide2; 
    
    % if divided by zero needs to be classified as the biggest ration
    % cluster , we set the last cluster to be above 2 so 4 is above 2 and
    % will be classified as big.
    percentageRatio(percentageRatio == Inf) = 4;
    classesRois = unique(selectedROISplitDepth1);
    
    eventsAmplitudePerROITable = GetEventsAmplitudesPerROI(roiActivity_comb, allEventsTable);
    
    sumEventsRation08_125 = nan(1, size(splitValues, 1));
    sumEventsRation05_08 = nan(1, size(splitValues, 1));
    sumEventsRation0_05 = nan(1, size(splitValues, 1));
    sumEventsRation125_2 = nan(1, size(splitValues, 1));
    sumEventsRation2_inf = nan(1, size(splitValues, 1));
    sumAllEvents = nan(1, size(splitValues, 1));
    
    f = figure; hold on;   
    f.Position = [0 0 1400 800];
    f2 = figure; hold on;  
    f2.Position = [0 0 1400 800];
    f3 = figure; hold on;  
    f3.Position = [0 0 1400 800];
    
    for i = 1:size(splitValues, 1)
        sb1 = subplot(3,2,i,'Parent', f);
        sb2 = subplot(3,2,i,'Parent', f2);            
        sb3 = subplot(3,2,i,'Parent', f3);
        
        eventsIndex = allEventsTable.roiPrecantage >= splitValues(i, 1) & allEventsTable.roiPrecantage < splitValues(i, 2);        
        
        sumEventsRation08_125(i) = sum(percentageRatio(eventsIndex) >= 0.8 & percentageRatio(eventsIndex) <= 1.25);
        sumEventsRation05_08(i) = sum(percentageRatio(eventsIndex) >= 0.5 & percentageRatio(eventsIndex) < 0.8);
        sumEventsRation0_05(i) = sum(percentageRatio(eventsIndex) < 0.5);
        sumEventsRation125_2(i) = sum(percentageRatio(eventsIndex) > 1.25 & percentageRatio(eventsIndex) <= 2);
        sumEventsRation2_inf(i) = sum(percentageRatio(eventsIndex) > 2);
        sumAllEvents(i) = sum(eventsIndex);
        
        bar(sb1, [sumAllEvents(i), sumEventsRation08_125(i), sumEventsRation05_08(i), sumEventsRation0_05(i), sumEventsRation125_2(i), sumEventsRation2_inf(i)]);
        bar(sb2, [sumEventsRation08_125(i), sumEventsRation05_08(i), sumEventsRation0_05(i), sumEventsRation125_2(i), sumEventsRation2_inf(i)] ./ sumAllEvents(i));
        xticks(sb1, 1:6);
        xticks(sb2, 1:5);
        ylim(sb2, [0,1]);
        xtickangle(sb1, 45);
        xtickangle(sb2, 45);
        xticklabels(sb1, precentageRatioName);
        xticklabels(sb2, precentageRatioName(2:end));
        ylabel(sb1, 'Events#');
        ylabel(sb2, 'Events%');
        title(sb1, sprintf('Events Count for exclusivity ratio of All tree activation %s', splitValuesName{i}));
        title(sb2, sprintf('Events percentage for exclusivity ratio of All tree activation %s', splitValuesName{i}));
        
        side1Amp = eventsAmplitudePerROITable(eventsIndex, selectedROISplitDepth1 == classesRois(1));
        side1Amp(isnan(side1Amp)) = [];
        side2Amp = eventsAmplitudePerROITable(eventsIndex, selectedROISplitDepth1 == classesRois(2));
        side2Amp(isnan(side2Amp)) = [];
        
        histogram(sb3, side1Amp, 'Normalization', 'probability', 'BinWidth', 0.1);
        hold(sb3, 'on');
        histogram(sb3, side2Amp, 'Normalization', 'probability', 'BinWidth', 0.1);
        xlabel('dF/F events');
        ylabel('Probability');
        xlim([0,max(eventsAmplitudePerROITable, [], 'all')]);
        ylim([0,0.3]);
        title(sprintf('Events Histogram for hemitree of All tree activation %s', splitValuesName{i}));
    end
    
    mysave(f, fullfile(outputpathCur, 'ExclusivityEventsCount'));
    mysave(f2, fullfile(outputpathCur, 'ExclusivityEventspercentage'));
    mysave(f3, fullfile(outputpathCur, 'EventsAmpHistogramForHemitreeByActivationPercentage'));
    
    save(fullfile(outputpath, 'eventsAmplitudePerROITable.mat'), 'eventsAmplitudePerROITable');
    save(fullfile(outputpathCur, 'ExclusivityEventsResults.mat'), 'sumEventsRation08_125', 'sumEventsRation05_08', 'sumEventsRation0_05', 'sumEventsRation125_2', 'sumEventsRation2_inf', 'sumAllEvents', 'splitValues', 'percentageRatio', 'splitValuesName', 'precentageRatioName')
end