
inputpath = '\\jackie-analysis\e\Shay\CT35\22_01_14_Treadmill_ETL\Analysis\N2\';
load([inputpath, '\Structural_VS_Functional\final\Run_noSoma\EventsDetection\roiActivity_comb.mat']);
load([inputpath, '\Structural_VS_Functional\final\Run_noSoma\no_behave\Pearson\SP\roiActivityRawData.mat']);

outputpath = '\\jackie-analysis\e\Shay\StatisticSummary\ETL\TUFTAndSomaEvents\';
fileName = 'CT35_14.1.22_N2_AllResults4.mat';

classesRois = unique(selectedROISplitDepth1);
classesRois(classesRois == -1) = [];
somaIndex = find(selectedROISplitDepth1 == -1);

sumEventsSomaAndTuftByH = zeros(1,4);
sumEventsSomaAndTuftByP = zeros(1,4);
tuftPrecentagewithsoma = [];
hemiTreeOnlyEventsCount = 0;
hemiEventsSoma = [];
hemiTreeOnlyEventsWithSoma = [];

fullhemiTreeCount = 0;
fullhemiTreeWithSoma = 0;

hemiTreeCount_05_08 = 0;
hemiTreeWithSoma_05_08 = 0;

hemiTreeCount_02_05 = 0;
hemiTreeWithSoma_02_05 = 0;

hemiTreeCount_0_02 = 0;
hemiTreeWithSoma_0_02 = 0;

for i_events = 1:size(allEventsTable,1)
    somaEvents = any(allEventsTable.roisEvent{i_events}(somaIndex) == 1);
    allIndex = 1: length(allEventsTable.roisEvent{i_events});
    tuftIndex = setdiff(allIndex, somaIndex);
    tuftEvents = mean(allEventsTable.roisEvent{i_events}(tuftIndex) == 1);
    sumEventsSomaAndTuftByH(allEventsTable.clusterByH(i_events)) = sumEventsSomaAndTuftByH(allEventsTable.clusterByH(i_events)) + ... 
        double(somaEvents & tuftEvents > 0);
    sumEventsSomaAndTuftByP(allEventsTable.clusterByRoiPrecantage(i_events)) = sumEventsSomaAndTuftByP(allEventsTable.clusterByRoiPrecantage(i_events)) + ... 
        double(somaEvents & tuftEvents > 0);
    
    hemiR = mean(allEventsTable.roisEvent{i_events}(selectedROISplitDepth1 == classesRois(1)) == 1);
    hemiL = mean(allEventsTable.roisEvent{i_events}(selectedROISplitDepth1 == classesRois(2)) == 1);
    
    if somaEvents && tuftEvents > 0
        tuftPrecentagewithsoma(end+1) = tuftEvents;
    end
    
    hemiEventsSoma(end+1, 1:3) = [min([hemiR,hemiL]), max([hemiR,hemiL]), somaEvents];
    
    if (hemiR > 0 && hemiL == 0) || (hemiR == 0 && hemiL > 0)
        hemiTreeOnlyEventsCount = hemiTreeOnlyEventsCount + 1;
        if somaEvents
            hemiTreeOnlyEventsWithSoma(end+1) = hemiR + hemiL;
        end
    end
end

clustersbyH(1) =  sum(allEventsTable.clusterByH == 1);
clustersbyH(2) = sum(allEventsTable.clusterByH == 2);
clustersbyH(3) = sum(allEventsTable.clusterByH == 3);
clustersbyH(4) = sum(allEventsTable.clusterByH == 4);

clustersbyP(1) =  sum(allEventsTable.clusterByRoiPrecantage == 1);
clustersbyP(2) = sum(allEventsTable.clusterByRoiPrecantage == 2);
clustersbyP(3) = sum(allEventsTable.clusterByRoiPrecantage == 3);
clustersbyP(4) = sum(allEventsTable.clusterByRoiPrecantage == 4);

custers_ByP_precantage(1,1:2) = [min(allEventsTable.roiPrecantage(allEventsTable.clusterByRoiPrecantage == 1)),...
    max(allEventsTable.roiPrecantage(allEventsTable.clusterByRoiPrecantage == 1))];

custers_ByP_precantage(2,1:2) = [min(allEventsTable.roiPrecantage(allEventsTable.clusterByRoiPrecantage == 2)),...
    max(allEventsTable.roiPrecantage(allEventsTable.clusterByRoiPrecantage == 2))];

custers_ByP_precantage(3,1:2) = [min(allEventsTable.roiPrecantage(allEventsTable.clusterByRoiPrecantage == 3)),...
    max(allEventsTable.roiPrecantage(allEventsTable.clusterByRoiPrecantage == 3))];

custers_ByP_precantage(4,1:2) = [min(allEventsTable.roiPrecantage(allEventsTable.clusterByRoiPrecantage == 4)),...
    max(allEventsTable.roiPrecantage(allEventsTable.clusterByRoiPrecantage == 4))];

save([outputpath, '\', fileName], 'hemiEventsSoma', 'hemiTreeOnlyEventsWithSoma', 'hemiTreeOnlyEventsCount', 'tuftPrecentagewithsoma', 'sumEventsSomaAndTuftByH', 'sumEventsSomaAndTuftByP', 'clustersbyH', 'clustersbyP', 'custers_ByP_precantage');