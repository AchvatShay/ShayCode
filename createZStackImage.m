function createZStackImage
    inputTiff = '\\192.114.21.82\g\Layer V\Analysis\CT14\Structural\CT14_StructuralStack.tif';
    outputPath = '\\192.114.21.82\g\Layer V\Analysis\CT14\Structural\2D_StackImage_CT14_fullStackFast';
    
    tiff_info = imfinfo(inputTiff);
    indexStack = 1;
    
    contrast = ones(1,size(tiff_info, 1))*0.015;
    
    for ii = size(tiff_info, 1):-1:1
%         M(:, :, indexStack) = imadjust(wiener2(im2double((imread(inputTiff, ii)))));
        M(:, :, indexStack) = imadjust((im2double((imread(inputTiff, ii)))),[0,contrast(ii)]);
%         M(:, :, indexStack) = ((im2double((imread(inputTiff, ii)))));
        indexStack =indexStack + 1;
    end
    
%     M2 = imadjustn(M);
    
    writerObj = VideoWriter([outputPath,'.avi']);
    writerObj.FrameRate = 5;
    open(writerObj);
    
    hf2 = figure;
    sliceRange = [11,16,21,26,31,36,41,46,51,56,61,66,71,76,81,86,91,96,101];
    hs = slice(M,[],[],sliceRange(1:end));
    
    hf2.Position = [308,159,354,665];
    hf2.Color = [1,1,1];

    hf2.Children(1).GridColor = [1,1,1];
    hf2.Children(1).YColor = [1,1,1];
    hf2.Children(1).XColor = [1,1,1];
    hf2.Children(1).ZColor = [1,1,1];
    hf2.Children(1).View = [-37.5,15];
    hf2.Children(1).ZLim = [1, sliceRange(end)];
    colormap gray
    shading interp

%     set(hs,'FaceAlpha',0.9);
    
    for i = 1:length(hs)
       hs(i).Visible = 'off';
    end
    
    for slicindex = 1:length(sliceRange)    
        hs(slicindex).Visible = 'on';       
        
        frame = getframe(hf2);    
        writeVideo(writerObj, frame);
    end
    
    close(hf2);
    close(writerObj); 
%     mysave(hf2, outputPath);
end