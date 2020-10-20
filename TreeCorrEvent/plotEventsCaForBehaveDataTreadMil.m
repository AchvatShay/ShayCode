function plotEventsCaForBehaveDataTreadMil(speedActivity, accelActivity, allEventsTable, clusterCount, outputpath, win_plot, BehaveDataTreadmil)
    
    behaveCombain = nan(1, size(speedActivity, 1));

    behaveCombain(BehaveDataTreadmil.rest) = 0;
    behaveCombain(BehaveDataTreadmil.walkconstant) = 1;
    behaveCombain(BehaveDataTreadmil.walkacceleration) = 2;

    for i = 0:clusterCount
        if i == 0
            currentCaTable = allEventsTable;
        else
            currentCaTable = allEventsTable(allEventsTable.clusterByH == i,:);
        end
        
        matrixBehave.Speedafter = nan(size(currentCaTable, 1), win_plot / 2);
        matrixBehave.Speedbefore = nan(size(currentCaTable, 1), win_plot / 2);
        matrixBehave.accelafter = nan(size(currentCaTable, 1), win_plot / 2);
        matrixBehave.accelbefore = nan(size(currentCaTable, 1), win_plot / 2);
        matrixBehave.behavebefore = nan(size(currentCaTable, 1), win_plot / 2);
        matrixBehave.behaveafter = nan(size(currentCaTable, 1), win_plot / 2);
        
        for ca_i = 1:size(currentCaTable, 1)
            loc_vec_after = currentCaTable.start(ca_i):(currentCaTable.start(ca_i) + win_plot / 2 - 1);
            loc_vec_befor = (currentCaTable.start(ca_i)-1):-1:max(1, (currentCaTable.start(ca_i) - win_plot / 2));
            matrixBehave.Speedafter(ca_i, 1:length(loc_vec_after)) = speedActivity(loc_vec_after);
            matrixBehave.Speedbefore(ca_i, 1:length(loc_vec_befor)) = speedActivity(loc_vec_befor);
            
            matrixBehave.behaveafter(ca_i, 1:length(loc_vec_after)) = behaveCombain(loc_vec_after);
            matrixBehave.behavebefore(ca_i, 1:length(loc_vec_befor)) = behaveCombain(loc_vec_befor);
            
            matrixBehave.accelafter(ca_i, 1:length(loc_vec_after)) = accelActivity(loc_vec_after);
            matrixBehave.accelbefore(ca_i, 1:length(loc_vec_befor)) = accelActivity(loc_vec_befor);
        end
        
        matrixBehaveall.speed = [flip(matrixBehave.Speedbefore, 2), matrixBehave.Speedafter];
        matrixBehaveall.accel = [flip(matrixBehave.accelbefore, 2), matrixBehave.accelafter];
        matrixBehaveall.behave = [flip(matrixBehave.behavebefore, 2), matrixBehave.behaveafter];
        
        
        fig = figure;
        hold on;
        
        s1 = subplot(2, 1, 1);
        imagesc(matrixBehaveall.speed);
        colorbar
        cmap = jet();
        colormap(cmap);
        title({'Behave velocity aligned To Ca Events', ['cluster : ' num2str(i)]});
        xlabel('Time');
        ylabel('Event#');
        hold on;
        plot(ones(1, size(currentCaTable, 1)) * (win_plot / 2), 1:size(currentCaTable), '--k', 'LineWidth', 1.5);
        xlim([1,win_plot]);
%         ylim([1,size(currentCaTable,1)]);
        
        s2 = subplot(2, 1, 2);
        hold on;
        imagesc(matrixBehaveall.accel);
        colorbar
        cmap = jet();
        colormap(cmap);
        title({'Behave acceleration aligned To Ca Events', ['cluster : ' num2str(i)]});
        xlabel('Time');
        ylabel('Event#');
        xlim([1,win_plot]);
%         ylim([1,size(currentCaTable,1)]);
        
        plot(ones(1, size(currentCaTable, 1)) * (win_plot / 2), 1:size(currentCaTable), '--k', 'LineWidth', 1.5);
        
        linkaxes([s1, s2], 'xy');
        
        mysave(fig, [outputpath, '\TreadMilAndCa\BehaveAlignedToCaEvents_cluster' num2str(i)]);  

    end
end