function mainRunnerYara()
% ----------------------------------------
%   Values TO change according to Data
    functionalXmlPath = '\\jackie-analysis\F\Layer II-III\Imaging\Bas-M2-Sa1\08.18.22-N1-Tuft\TSeries-08182022-1350-001\TSeries-08182022-1350-001.xml';
    structuralXmlPath = '\\jackie-analysis\F\Layer II-III\Imaging\Bas-M2-Sa1\07.21.22-structure-ETL\1_aligned\TSeries-07212022-0903-001\TSeries-07212022-0903-001.xml';
    
    functionalRoiZipPath = '\\jackie-analysis\F\Layer II-III\Analysis\Bas-M2-Sa1\08.18.22-N1-Tuft\TPA_TSeries_08182022_1350_001_Cycle00001_Ch1_000001_ome.mat_RoiSet.zip';
    
    outputPath = '\\jackie-analysis\F\Layer II-III\Analysis\Bas-M2-Sa1\08.18.22-N1-Tuft\ROIChangePix\';
    
    functionalImagePointX = 208;
    functionalImagePointY = 345;    
    
    structuralImagePointX = 522;
    structuralImagePointY = 383;
%    -------------------------------------

    mkdir(outputPath);
    
    changeRoiPix(functionalXmlPath, structuralXmlPath, functionalRoiZipPath, outputPath,...
        functionalImagePointX, functionalImagePointY, structuralImagePointX, structuralImagePointY);
    
end