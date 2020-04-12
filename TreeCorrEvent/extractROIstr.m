function roiNum = extractROIstr(fullstr)

roiNum=sscanf(fullstr, 'ROI:%d Z:1');
if isempty(roiNum)
    roiNum=sscanf(fullstr, 'ROI:Z:1:%d');
end
if isempty(roiNum)
    roiNum=sscanf(fullstr, 'ROI:Z:2:%d');
end
if isempty(roiNum)
    roiNum=sscanf(fullstr, 'AROI:Z1:%d');
end
if isempty(roiNum)
    roiNum=0;
    warning('Unrecognized neuron name');
end

