function plotBaseTreadMillActivity(speedB, accelB, roiActivity, outputpath)
    meanRoiActivity = mean(roiActivity, 2);
    
    f = figure;
    hold on;
    
    s1 = subplot(8, 1, 1:2);
    plot(meanRoiActivity);
    title({'ROI mean Activity'});
    xlabel('Time');
    xlim([1, size(meanRoiActivity, 1)]);
    
    s2 = subplot(8, 1, 4:5);
    plot(speedB(1:size(meanRoiActivity, 1)));
    title({'Velocity'});
    xlabel('Time');
    xlim([1, size(speedB, 1)]);
    
    s3 = subplot(8, 1, 7:8);
    plot(accelB(1:size(meanRoiActivity, 1)));
    title({'Acceleration'});
    xlabel('Time');
    xlim([1, size(accelB, 1)]);
    
    linkaxes([s1, s2, s3], 'x');
    
    mysave(f, [outputpath, '\Behave_TreadMill\SpeedAndAccelPresentation']);  
end