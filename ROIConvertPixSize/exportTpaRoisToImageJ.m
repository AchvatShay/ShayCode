% exportTpaRoisToImageJ() 
% by Nate Cermak, 2019.
% inputs:
%   tpaFile - a string containing the path of a TPA .mat file. The mat
%             file must include a strROI object.
% outputs:
%   no return value
%
% This function creates a set of .roi files formatted for ImageJ
% Format defined here: 
%  https://imagej.nih.gov/ij/developer/source/ij/io/RoiDecoder.java.html 
% and zips them into a single RoiSet.zip file. RoiSet.zip can be dragged
% into ImageJ to load the ROIs, or imported via ROI Manager. 
%
function exportTpaRoisToImageJ(tpaFile) 

    load(tpaFile)

    fNames = [];
    for i = 1:length(strROI)
        r = strROI{i};
        roiName = strrep(r.Name, ':', '_');
        roiFilename = strcat(roiName, ".roi");
        fNames = [fNames roiFilename];
        % create .roi file with roi name as filename. 
        f = fopen(roiFilename, 'wb');

        % write appropriate header (will only work for polygons currently)
        fprintf(f, "Iout");
        fwrite(f, 227,'uint16','b'); % 4-5     version (>=217)
        fwrite(f, 0,  'uint16','b'); % 6-7     roi type (0 is polygon)
        fwrite(f, 0,  'uint16','b'); % 8-9     top
        fwrite(f, 0,  'uint16','b'); % 10-11   left
        fwrite(f, max(r.xyInd(:,1)),  'uint16','b'); % 12-13   bottom
        fwrite(f, max(r.xyInd(:,2)),  'uint16','b'); % 14-15   right
        fwrite(f, size(r.xyInd,1),  'uint16','b');   % 16-17   NCoordinates
        fwrite(f, zeros(8,1),  'uint16','b'); % 18-33   x1,y1,x2,y2 (straight line) | x,y,width,height (double rect) | size (npoints)
        fwrite(f, 0,  'uint16','b'); % 34-35   stroke width (v1.43i or later)
        fwrite(f, 0,  'uint32','l'); % 36-39   ShapeRoi size (type must be 1 if this value>0)
        fwrite(f, 0,  'uint32','l'); % 40-43   stroke color (v1.43i or later)
        fwrite(f, 0,  'uint32','l'); % 44-47   fill color (v1.43i or later)
        fwrite(f, 0,  'uint16','b'); % 48-49   subtype (v1.43k or later)
        fwrite(f, 0,  'uint16','b'); % 50-51   options (v1.43k or later)
        fwrite(f, 0,  'uint8');      % 52-52   arrow style or aspect ratio (v1.43p or later)
        fwrite(f, 0,  'uint8');      % 53-53   arrow head size (v1.43p or later)
        fwrite(f, 0,  'uint16','b'); % 54-55   rounded rect arc size (v1.43p or later)
        fwrite(f, 0,  'uint32','l'); % 56-59   position
        fwrite(f, 0,  'uint32','l'); % 60-63   header2 offset

        % 64-       x-coordinates (short), followed by y-coordinates
        fwrite(f, reshape(uint16(r.xyInd),[],1), 'uint16','b');

        % close file
        fclose(f);

    end

    % zip it all up!
    zip(strcat(tpaFile,"_RoiSet.zip"), fNames)

    % remove individual roi files
    for i = 1:length(fNames)
       delete(fNames(i));
    end
    
end