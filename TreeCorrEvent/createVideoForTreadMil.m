function createVideoForTreadMil
    activityDataLocation = 'C:\Users\Jackie\Dropbox (Technion Dropbox)\Yara\Layer 5_Analysis\Shay\SM00\06.26.19_FreeRun\Analysis\N1\Structural_VS_Functional\27-10-20\Run1\no_behave\Pearson\SP\Behave_TreadMill\dataforvideo.mat';
    behaveVideoLocation = 'D:\Layer V\Videos\SM00\2019-06-26_SM00_freerun_behavior\20190626_133512\trial0000.mkv';
    outputpath = 'C:\Users\Jackie\Dropbox (Technion Dropbox)\Yara\Layer 5_Analysis\Shay\SM00\06.26.19_FreeRun\Analysis\N1\Structural_VS_Functional\27-10-20\Run1\video\';
    treadmilTxtFile = 'C:\Users\Jackie\Dropbox (Technion Dropbox)\Yara\Layer 5_Analysis\Shay\SM00\06.26.19_FreeRun\SM00_06.26.19_FreeRun_Behavior.txt';
    behaveTreadMil = 'C:\Users\Jackie\Dropbox (Technion Dropbox)\Yara\Layer 5_Analysis\Shay\SM00\06.26.19_FreeRun\Analysis\N1\Structural_VS_Functional\27-10-20\Run1\no_behave\Pearson\SP\BehaveTreadMilResults.mat';
    treadmilData = readtable(treadmilTxtFile);
   
    mkdir(outputpath);
    
    v_behave = VideoReader(behaveVideoLocation);
    load(activityDataLocation, 'meanRoiActivity', 'speedB');
    load(behaveTreadMil, 'BehaveDataTreadmil');
    
    totalFrames = length(BehaveDataTreadmil.walkconstant) + length(BehaveDataTreadmil.walkacceleration);
    
    vOut = VideoWriter([outputpath, '\behaveWithActivity_'],'MPEG-4');    
    
    frameIndex = sort([BehaveDataTreadmil.walkconstant; BehaveDataTreadmil.walkacceleration]);
    open(vOut);

%     videoPlayer = vision.VideoPlayer;
        
    k = 1;
    lastLocationInTwoP = 0;
    treadIndex = 1;
    
    while(hasFrame(v_behave))
        if k > length(meanRoiActivity)
            break;
        end
        
        if any(frameIndex == k)
            fig = figure('visible','off'); hold on;
            plot(meanRoiActivity + 1, 'Color', 'k', 'LineWidth', 1.5);
            plot(speedB(1:size(meanRoiActivity, 1)) + 2, 'Color', [25 110 180, 255] ./ 255);

            fig.Position = [fig.Position(1), fig.Position(2), v_behave.Width, v_behave.Height];

            scatter(k, meanRoiActivity(k)+ 1, 'filled', 'MarkerEdgeColor', 'r', 'MarkerFaceColor', 'r', 'SizeData', 15);
            scatter(k, speedB(k) + 2, 'filled', 'MarkerEdgeColor', 'r', 'MarkerFaceColor', 'r', 'SizeData', 15);
            xlim([max(k - 100, 0), min(k +100, size(meanRoiActivity, 1))]);
            ylim([-1, 8]);
            % Save the frame in structure for later saving to video file

            cur = readFrame(v_behave);
            fin = getframe(gcf);

            imgt = horzcat(fin.cdata, cur);

    %         step(videoPlayer, imgt);
            writeVideo(vOut,imgt)
            
            close gcf
            clear fig imgt fin cur;
        else
            readFrame(v_behave);
        end
        
        if (treadmilData.twoP(treadIndex) ~= lastLocationInTwoP)
            k = k+1;
            lastLocationInTwoP = treadmilData.twoP(treadIndex);
        end
        
        treadIndex = treadIndex + 1;     
    end

%     release(videoPlayer);
    close(vOut)
    close all
end