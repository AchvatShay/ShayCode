function createLikeLivescanVideo(ImagingFilesLocation, videoOutputfolder, videoName, channel, avgFrame, videoFR)
    filesList = dir(fullfile(ImagingFilesLocation, ['*_', channel, '_*.tif']));
    
%     net = denoisingNetwork('DnCNN');
    
    for i = 1:length(filesList)
        curTiff = Tiff(fullfile(filesList(i).folder, filesList(i).name),'r');
        currentImage = read(curTiff);
        imageData(i) = {currentImage};
%       imageData(i) = {imgaussfilt(currentImage, 1)};
%         imageData(i) = {denoiseImage(currentImage,net)};
        close(curTiff);
    end
    
    writerObj = VideoWriter(fullfile(videoOutputfolder, [videoName, '.avi']));
    writerObj.FrameRate = videoFR;
    open(writerObj);
    
    for i = 1:length(filesList)-3
%         startIndex = i;
%         endIndex = min(i+avgFrame-1, length(filesList));
%         
%         sumResults = imageData{startIndex};
%         for j = startIndex+1:endIndex
%             sumResults = imadd(sumResults, imageData{i});
%         end
%         
%         sumResults = imadjust(imdivide(sumResults, avgFrame), [0.00, 0.03]);
%         sumResults = imadjust(imageData{i}, [0.00, 0.03]);
        
        writeVideo(writerObj, im2double((sumResults)));
    end
    
    close(writerObj); 
end