valueH = []; valueH_relative = [];
cluster = [];
precentage = [];
classification = [];
for i = 1:size(tableResults,1)
if tableResults.includeMainR2(i) ~= 1 | tableResults.Classification(i) == -1
continue;
end
load(fullfile(tableResults.RunLocation{(i)}, '\..\..\..\EventsDetection\roiActivity_comb.mat')); load(fullfile(tableResults.RunLocation{(i)}, 'roiActivityRawData.mat'));
valueH(end+1:end+size(allEventsTable,1)) = allEventsTable.H; valueH_relative(end+1:end+size(allEventsTable,1)) = allEventsTable.H ./ max(allEventsTable.H);
cluster(end+1:end+size(allEventsTable,1)) = allEventsTable.clusterByH;
leftHemi = []; rhemi = [];
for j = 1:size(allEventsTable,1)
roiList = allEventsTable.roisEvent{j};
classTest = unique(selectedROISplitDepth1);
leftHemi(end+1) = sum(roiList(selectedROISplitDepth1 == classTest(1)) == 1) ./ sum(selectedROISplitDepth1 == classTest(1));
rhemi(end+1) = sum(roiList(selectedROISplitDepth1 == classTest(2)) == 1) ./ sum(selectedROISplitDepth1 == classTest(2));
end
precentage(end+1:end+size(allEventsTable,1)) = (leftHemi + rhemi) ./ 2;
classification(end+1:end+size(allEventsTable,1)) = ones(1,size(allEventsTable,1))*tableResults.Classification(i);
end