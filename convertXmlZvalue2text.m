function convertXmlZvalue2text(xmlFolders)
    list = dir([xmlFolders '\*.xml']);
    
    fid = fopen([xmlFolders '\depths_doc.txt'], 'a');
    
    for index = 1:length(list)
        xmlValueNdes = xmlread(fullfile(list(index).folder, list(index).name));
        sequence_list = xmlValueNdes.getElementsByTagName('Sequence');
        
        if (sequence_list.getLength > 1)
            error('NOT the XML Format we need')
        end
        
        allFrames = sequence_list.item(0).getElementsByTagName('Frame');
        
        for frame_index = 0:(allFrames.getLength - 1)
            currentFrame = allFrames.item(frame_index);
            
            pvStateShard = currentFrame.getElementsByTagName('PVStateShard');
             if (pvStateShard.getLength > 1)
                error('NOT the XML Format we need')
             end
            
            curShard = pvStateShard.item(0).getElementsByTagName('PVStateValue');
            
            for i_shard = 0:(curShard.getLength - 1)
                pvStateValueCur = curShard.item(i_shard);
                if strcmp(pvStateValueCur.getAttribute('key'), 'positionCurrent')
                    subindexedValues = pvStateValueCur.getElementsByTagName('SubindexedValues');
                    
                    for i = 0:(subindexedValues.getLength - 1)
                        cur = subindexedValues.item(i);
                        if (strcmp(cur.getAttribute('index'), 'ZAxis'))
                            zVal = cur.getElementsByTagName('SubindexedValue');
                            for k = 0:(zVal.getLength - 1)
                                z_val_cur = zVal.item(k);
                                if (strcmp(z_val_cur.getAttribute('description'), 'Z Focus'))
                                    valuetoText = z_val_cur.getAttribute('value');
                                    fprintf(fid, [valuetoText.toCharArray' '\n']);
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    fclose(fid);
end