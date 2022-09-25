function plotEventsHistogram(allEventsTable, outputpath, clusterNumber)
   fig = figure;
   hold on;
   
   subplot(3, 1, 1);
   h_ByH = histogram(allEventsTable.clusterByH); 
   title({'Ca Events Histogram ,Cluster By H'});
   
   subplot(3, 1, 2);
   h_ByP = histogram(allEventsTable.clusterByRoiPrecantage);
   title({'Ca Events Histogram ,Cluster By P'});
  
   subplot(3, 1, 3);
   h_ByP = histogram(allEventsTable.clusterByThresholdRoiPrecantage);
   title({'Ca Events Histogram ,Cluster By Percentage threshold'});
  
   
   mysave(fig, [outputpath, '\HistogramEventsCluster']);  

   [N_ByH,~, ~] = histcounts(allEventsTable.clusterByH, (0.5:clusterNumber+0.5));
   [N_ByP,~, ~] = histcounts(allEventsTable.clusterByRoiPrecantage, (0.5:clusterNumber+0.5));
   
   clusterSummary = [1:length(N_ByH);N_ByH; N_ByP];
   
   eventsSummaryCluster = array2table(clusterSummary');
   eventsSummaryCluster.Properties.VariableNames = {'Cluster', 'ByHValue', 'ByPValue'};
   writetable(eventsSummaryCluster, [outputpath, '\HistogramEventsClusterSummary.csv']);
end