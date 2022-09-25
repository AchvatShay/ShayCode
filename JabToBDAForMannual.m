% jaaba1 = load('\\192.114.21.82\d\Layer V\Analysis\OP2\03.27.20_Tuft\fixed- TableTurn_Lift_Grab_Supination_AtMouth_BackToPerch.mat', 'm');
jaaba = load('\\jackie-analysis\F\Layer II-III\Analysis\Bas-S1-1\05.21.22-N2-Tuft-part1\TableTurn_Lift_GrabF_P_GrabF_NP_GrabS_Supinate_AtMouth_BackTo.mat', 'm');

timeF = 2400; 
%  

BDAFolder = '\\jackie-analysis\F\Layer II-III\Analysis\Bas-S1-1\05.21.22-N2-Tuft-part1\';
BDANAme = 'BDA_TSeries_05212022_0935';

for i = 1:length(jaaba.m)
    bdaFileName = sprintf('%s\\%s_%03d_Cycle00001_Ch1_000001_ome.mat', BDAFolder, BDANAme, i);
    
    if ~isfile(bdaFileName)
        continue;
    end
    
    curBDA = load(bdaFileName);
    
    curBDATemp.strEvent = {};
    for j = 1:length(curBDA.strEvent)
        if contains(lower(curBDA.strEvent{j}.Name), 'success') || contains(lower(curBDA.strEvent{j}.Name), 'fail') || contains(lower(curBDA.strEvent{j}.Name), 'failure') || contains(lower(curBDA.strEvent{j}.Name), 'tone')
            curBDATemp.strEvent{end+1} = curBDA.strEvent{j};
        end
    end
    
    curBDA = curBDATemp;
    
    startTimeEvent = jaaba.m(i).t0s{1};
    endTimeEvent = jaaba.m(i).t1s{1};
    eventName = jaaba.m(i).names{1};
    
    if isempty(eventName)
        strEvent = curBDA.strEvent;
        save(bdaFileName, 'strEvent');
        continue;
    end
    
    unNames = unique(eventName);
    unNames(contains(unNames, 'No_')) = [];
    eventsCount = ones(1, length(unNames));
    
    for e = 1:length(startTimeEvent)
        eventLocation = find(strcmp(unNames, eventName{e}));
        if isempty(eventLocation)
            continue;
        end
        
        event = TPA_EventManager();
        event.Name = sprintf('%s:%02d', eventName{e}, eventsCount(eventLocation));
        event.tInd = [startTimeEvent(e),endTimeEvent(e)];
        event.Data = zeros(1, timeF);
        event.Data(startTimeEvent(e):endTimeEvent(e)) = 1;
        eventsCount(eventLocation) = eventsCount(eventLocation) + 1;
        curBDA.strEvent{end + 1} = event;
    end
    
    strEvent = curBDA.strEvent;
    save(bdaFileName, 'strEvent');
end


