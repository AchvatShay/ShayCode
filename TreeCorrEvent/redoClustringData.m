function [SpikeTrainClusterSecByH, SpikeTrainClusterSecByPrecantage, SpikeTrainClusterSecByPrecantageThresholds] = redoClustringData(allEventsTable, globalParameters, roiActivity_comb, outputpath)
%     -----------------------------------------------------------------------------------------------------

    SpikeTrainClusterSecByH = getClusterForActivity(allEventsTable.H, globalParameters.clusterCount);
    printClusterResults(SpikeTrainClusterSecByH, globalParameters.clusterCount, mean(roiActivity_comb, 2), allEventsTable.pks, allEventsTable.start, allEventsTable.event_end, allEventsTable.H, outputpath, 'ByH')

%   -----------------------------------------------------------------------------------------------------  

    SpikeTrainClusterSecByPrecantage = getClusterForActivity(allEventsTable.roiPrecantage, globalParameters.clusterCount);
    printClusterResults(SpikeTrainClusterSecByPrecantage, globalParameters.clusterCount, mean(roiActivity_comb, 2), allEventsTable.pks, allEventsTable.start, allEventsTable.event_end, allEventsTable.H, outputpath, 'ByP')

%     -----------------------------------------------------------------------------------------------------
    SpikeTrainClusterSecByPrecantageThresholds = getClustersByPercentageThreshold(globalParameters.PrecentageThresholdType,allEventsTable.roiPrecantage, allEventsTable.roiPrecantageSide1, allEventsTable.roiPrecantageSide2, globalParameters.ClustersByPrecentageThreshold);
    printClusterResults(SpikeTrainClusterSecByPrecantageThresholds, max(SpikeTrainClusterSecByPrecantageThresholds), mean(roiActivity_comb, 2), allEventsTable.pks, allEventsTable.start, allEventsTable.event_end, allEventsTable.H, outputpath, 'ByPercentageThreshold')

% ----------------------------------------------------------------------------------------


end