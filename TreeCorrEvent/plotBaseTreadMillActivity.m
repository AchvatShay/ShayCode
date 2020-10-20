function plotBaseTreadMillActivity(speedB, accelB, roiActivity, outputpath, selectedROI, allEventsTabel, clusterCount)  
    meanRoiActivity = mean(roiActivity, 2);
            
    for cl = 0:clusterCount
        if cl ~= 0
           currentEventsStart = allEventsTabel.start(allEventsTabel.clusterByH == cl);
        else
           currentEventsStart = allEventsTabel.start;
        end

        if cl ~= 0
           currentEventsEnd = min(allEventsTabel.event_end(allEventsTabel.clusterByH == cl),allEventsTabel.pks(allEventsTabel.clusterByH == cl)+20);
        else
           currentEventsEnd = min(allEventsTabel.event_end, allEventsTabel.pks + 20);
        end

        framesVector.cl = [];
        for i = 1:length(currentEventsStart)
            framesVector.cl = [framesVector.cl, currentEventsStart(i):currentEventsEnd(i)]; 
        end
           
        plotForActivity(speedB, accelB, meanRoiActivity(framesVector.cl), outputpath, ['mean roi' '_cluster_ByH_c' num2str(cl)]);

        for in = 1:length(selectedROI)
           plotForActivity(speedB, accelB, roiActivity(framesVector.cl, in), outputpath, [selectedROI{in} '_cluster_ByH_c' num2str(cl)]);
           close all;
        end

     end
       

    meanRoiActivity = mean(roiActivity, 2);
    plotForActivity(speedB, accelB, meanRoiActivity, outputpath, 'mean roi');
    
    for in = 1:length(selectedROI)
       
       plotForActivity(speedB, accelB, roiActivity(:, in), outputpath, selectedROI{in});
       close all;
    end
    
end

function plotForActivity(speedB, accelB, currActivity, outputpath, nameROI)
    f = figure;
    hold on;
    
    s1 = subplot(8, 1, 1:2);
    plot(currActivity);
    title({nameROI, ' Activity'});
    xlabel('Time');
    xlim([1, size(currActivity, 1)]);
    
    s2 = subplot(8, 1, 4:5);
    plot(speedB(1:size(currActivity, 1)));
    title({'Velocity'});
    xlabel('Time');
    xlim([1, size(speedB, 1)]);
    
    s3 = subplot(8, 1, 7:8);
    plot(accelB(1:size(currActivity, 1)));
    title({'Acceleration'});
    xlabel('Time');
    xlim([1, size(accelB, 1)]);
    
    linkaxes([s1, s2, s3], 'x');
    
    mysave(f, [outputpath, '\Behave_TreadMill\SpeedAndAccelPresentation_' nameROI]); 
end