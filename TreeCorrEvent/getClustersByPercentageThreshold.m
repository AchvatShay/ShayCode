function SpikeTrainClusterSecByPrecantageThresholds = getClustersByPercentageThreshold(precentageThresholdType,roiPrecantage, roiPrecantageSide1, roiPrecantageSide2, precentageThresholds)
    SpikeTrainClusterSecByPrecantageThresholds = nan(1, size(roiPrecantage, 1));

    if precentageThresholdType == 1
        th_v = precentageThresholds ./ 100;
        cluster1_logic = roiPrecantageSide1 < th_v(1) & roiPrecantageSide2 <  th_v(1);
        SpikeTrainClusterSecByPrecantageThresholds(cluster1_logic) = 1;

        cluster2_logic = ((roiPrecantageSide1 >=  th_v(1) & roiPrecantageSide1 < th_v(2)) & roiPrecantageSide2 <  th_v(1)) | ...
            ((roiPrecantageSide2 >=  th_v(1) & roiPrecantageSide2 < th_v(2)) & roiPrecantageSide1 <  th_v(1));
        SpikeTrainClusterSecByPrecantageThresholds(cluster2_logic) = 2;

        cluster3_logic = ((roiPrecantageSide1 >=  th_v(2) & roiPrecantageSide1 <= th_v(3)) & roiPrecantageSide2 <  th_v(1)) | ...
            ((roiPrecantageSide2 >= th_v(2) & roiPrecantageSide2 <= th_v(3)) & roiPrecantageSide1 <  th_v(1));
        SpikeTrainClusterSecByPrecantageThresholds(cluster3_logic) = 3;

        cluster4_logic = ((roiPrecantageSide1 >=  th_v(1) & roiPrecantageSide1 < th_v(2)) & (roiPrecantageSide2 >= th_v(1) & roiPrecantageSide2 < th_v(2))) | ...
            ((roiPrecantageSide1 >=  th_v(1) & roiPrecantageSide1 < th_v(2)) & (roiPrecantageSide2 >= th_v(2) & roiPrecantageSide2 <= th_v(3))) | ...
            ((roiPrecantageSide1 >= th_v(2) & roiPrecantageSide1 <= th_v(3)) & (roiPrecantageSide2 >=  th_v(1) & roiPrecantageSide2 < th_v(2)));

        SpikeTrainClusterSecByPrecantageThresholds(cluster4_logic) = 4;

        cluster5_logic = ((roiPrecantageSide1 >= th_v(2) & roiPrecantageSide1 <= th_v(3)) & (roiPrecantageSide2 >= th_v(2) & roiPrecantageSide2 <= th_v(3)));
        SpikeTrainClusterSecByPrecantageThresholds(cluster5_logic) = 5;
    else
        for th_i = 1:(size(precentageThresholds, 1))
            startPre = precentageThresholds(th_i, 1) ./ 100;
            endPre = precentageThresholds(th_i, 2) ./ 100;

            eventsInthisCategory = allEventsTable.roiPrecantage >= startPre & allEventsTable.roiPrecantage < endPre;

            SpikeTrainClusterSecByPrecantageThresholds(eventsInthisCategory) = th_i;
        end

        eventsInthisCategory = allEventsTable.roiPrecantage == precentageThresholds(end, 2) ./ 100;
        SpikeTrainClusterSecByPrecantageThresholds(eventsInthisCategory) = length(precentageThresholds);   
    end
end