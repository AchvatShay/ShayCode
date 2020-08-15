function changeRoiPix(xmlOriginalPix, xmlNewPix, roiOriginalZip, outputPath, originalPointX, originalPointY, newPointX, newPointY)
   [original_x_mic, original_y_mic, pixOriginal] = getPixPerMic(xmlOriginalPix);
   
   [new_x_mic, new_y_mic, pixNew] = getPixPerMic(xmlNewPix);
   
   roi_all = ReadImageJROI(roiOriginalZip);
   
   pointMicronOriginal = [originalPointX * original_x_mic, originalPointY * original_y_mic];
   pointMicronNew = [newPointX * new_x_mic, newPointY * new_y_mic];
   
   d_micron = pointMicronNew - pointMicronOriginal;
      
   for i = 1:length(roi_all)
        x_list = roi_all{i}.mnCoordinates(:, 1) .* original_x_mic;
        y_list = roi_all{i}.mnCoordinates(:, 2) .* original_y_mic;
        
        roi_all{i}.mnCoordinates(:, 1) = (x_list + d_micron(1)) ./ new_x_mic;
        roi_all{i}.mnCoordinates(:, 2) = (y_list + d_micron(2)) ./ new_y_mic;
   end
   
   exportRoisToImageJ(roi_all, outputPath);
end

function [x, y, pixS] = getPixPerMic(xmlFile)
   xmlValueNdes = xmlread(xmlFile);
   sequence_list = xmlValueNdes.getElementsByTagName('PVStateShard');
   
   curShard = sequence_list.item(0).getElementsByTagName('PVStateValue');
   x = 0;
   y = 0;
   pixS = 0;
   for i_shard = 0:(curShard.getLength - 1)
        pvStateValueCur = curShard.item(i_shard);

        if strcmp(pvStateValueCur.getAttribute('key'), 'micronsPerPixel')
            subindexedValues = pvStateValueCur.getElementsByTagName('IndexedValue');
             for i = 0:(subindexedValues.getLength - 1)
                cur = subindexedValues.item(i);
                if (strcmp(cur.getAttribute('index'), 'XAxis'))
                    x = str2double(cur.getAttribute('value'));
                end

                if (strcmp(cur.getAttribute('index'), 'YAxis'))
                    y = str2double(cur.getAttribute('value'));
                end
             end
             
            break;
        elseif strcmp(pvStateValueCur.getAttribute('key'), 'linesPerFrame') 
            pixS = str2double(pvStateValueCur.getAttribute('value'));
        end
   end 
end