function [speedResultsBehave, accelResultsBehave, speedResultsActivity, accelResultsActivity] = treadmilBehave(treadmilTxtFile, behaveFrameRate)
    treadmilData = readtable(treadmilTxtFile);
    
    b_floor = floor(behaveFrameRate / 2);
    b_celing = ceil(behaveFrameRate / 2);
    
    deltaTreadmilSpeed = treadmilData.treadmill((1 + behaveFrameRate):size(treadmilData,1)) - treadmilData.treadmill(1:(size(treadmilData,1)-behaveFrameRate));
    speed_vector =  (deltaTreadmilSpeed / 1024) * pi * 10;
    treadmilData.speed = [NaN(b_floor, 1); speed_vector; NaN(b_celing, 1)];
    
    deltaTreadmilAccel = treadmilData.speed((1 + behaveFrameRate):size(treadmilData,1)) - treadmilData.speed(1:(size(treadmilData,1)-behaveFrameRate));
    
    treadmilData.accel = [NaN(b_floor,1); deltaTreadmilAccel; NaN(b_celing,1)];
    
    
    treadmilData.twoP = seconds(treadmilData.twoP);
    treadmilASTimeTable = table2timetable(treadmilData, 'RowTimes', 'twoP');
    treadmilASTimeTable = retime(treadmilASTimeTable, 'secondly', 'mean');
    
    speedResultsBehave = treadmilASTimeTable.speed;
    accelResultsBehave = treadmilASTimeTable.accel;
    
    speedResultsActivity = treadmilData.speed;
    accelResultsActivity = treadmilData.accel;  
end