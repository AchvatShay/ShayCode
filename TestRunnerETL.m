fileResults = dir('\\jackie-analysis\e\Shay\StatisticSummary\ETL\TUFTAndSomaEvents\*4.mat');

fullHemiEvent = [];
eventsWithMorethan05 = [];
eventsWithLessthan05 = [];
fullHemiEventandSoma = [];
eventsWithMorethan05andSoma = [];
eventsWithLessthan05andSoma = [];

for i = 1:length(fileResults)
load(fullfile(fileResults(i).folder, fileResults(i).name));
fullHemiEvent(end+1) = sum(hemiEventsSoma(:,2) >= 0.9 & hemiEventsSoma(:,1) <= 0);
eventsWithMorethan05(end+1) = sum(hemiEventsSoma(:,2) >= 0.5 & hemiEventsSoma(:,2) < 0.9 & hemiEventsSoma(:,1) <= 0);
eventsWithLessthan05(end+1) = sum(hemiEventsSoma(:,2) < 0.5 & hemiEventsSoma(:,1) <= 0);
fullHemiEventandSoma(end+1) = sum(hemiEventsSoma(:,2) >= 0.9 & hemiEventsSoma(:,1) <= 0 & hemiEventsSoma(:,3) == 1);
eventsWithMorethan05andSoma(end+1) = sum(hemiEventsSoma(:,2) >= 0.5 & hemiEventsSoma(:,2) < 0.9 & hemiEventsSoma(:,1) <= 0& hemiEventsSoma(:,3) == 1);
eventsWithLessthan05andSoma(end+1) = sum(hemiEventsSoma(:,2) < 0.5 & hemiEventsSoma(:,1) <= 0& hemiEventsSoma(:,3) == 1);
end

fullHemiEventandSoma(fullHemiEvent == 0) = [];
fullHemiEvent(fullHemiEvent == 0) = [];
eventsWithMorethan05andSoma(eventsWithMorethan05 == 0) = [];
eventsWithMorethan05(eventsWithMorethan05 == 0) = [];
eventsWithLessthan05andSoma(eventsWithLessthan05 == 0) = [];
eventsWithLessthan05(eventsWithLessthan05 == 0) = [];

mean(fullHemiEventandSoma ./ fullHemiEvent)
mean(eventsWithMorethan05andSoma ./ eventsWithMorethan05)
mean(eventsWithLessthan05andSoma ./ eventsWithLessthan05)