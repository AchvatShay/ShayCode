function mainRunnerYara()
% ----------------------------------------
%   Values TO change according to Data
    functionalXmlPath = 'E:\Code\ShayCode\ROIConvertPixSize\TestFiles2\TSeries-08042020-1000-001.xml';
    structuralXmlPath = 'E:\Code\ShayCode\ROIConvertPixSize\TestFiles2\ZSeries-04072020-1115-001.xml';
    
    functionalRoiZipPath = 'E:\Code\ShayCode\ROIConvertPixSize\TestFiles2\RoiSet.zip';
    
    outputPath = 'E:\Dropbox (Technion Dropbox)\Test1';
    
    functionalImagePointX = 179;
    functionalImagePointY = 310;    
    
    structuralImagePointX = 298;
    structuralImagePointY = 824;
%    -------------------------------------

    mkdir(outputPath);
    
    changeRoiPix(functionalXmlPath, structuralXmlPath, functionalRoiZipPath, outputPath,...
        functionalImagePointX, functionalImagePointY, structuralImagePointX, structuralImagePointY);
    
end