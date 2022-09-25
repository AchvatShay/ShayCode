function getSynapsesDistribution(outputPath, gRoi)
%     outputPath = '\\jackie-analysis\e\ShayCode\pythonProject\larkumEtAl2009_2\Simulation\4481_N3\12.6Syn50Size0.7\synDist\';
%     swcFile = '\\jackie-analysis\e\Shay\Simulation\4481_N3\Cai2\Swc\cell_N3_4481_allseg_onlyTuft_7-0d_noObliq_subP.swc';
%     
%     [gRoi, rootNodeID, selectedROITable] = loadSwcFile(swcFile, outputPath, 0);

    for i = 0:499
        matR = load(sprintf('\\\\jackie-analysis\\e\\ShayCode\\pythonProject\\larkumEtAl2009_2\\Simulation\\4481_N3\\12.6Syn50Size0.7\\matlab_SimulationResults_%03d.mat', i), 'SelectedSynSectionSeg', 'selectedSYNSectionName');

        resultsR = zeros(length(matR.SelectedSynSectionSeg), length(matR.SelectedSynSectionSeg));

        for k = 1:(length(matR.SelectedSynSectionSeg))
            segLocation1 = floor(matR.SelectedSynSectionSeg(k)*9);
            nameR1 = getRoiName(matR.selectedSYNSectionName(k, :));
            nameR1 = sprintf('%s%d', nameR1, segLocation1);
            
            nodeIndex1 = find(strcmp(gRoi.Nodes.Name,nameR1));
            
            for j = (k+1):length(matR.SelectedSynSectionSeg)
                segLocation2 = floor(matR.SelectedSynSectionSeg(j)*9);
                nameR2 = getRoiName(matR.selectedSYNSectionName(j, :));
                nameR2 = sprintf('%s%d', nameR2, segLocation2);
                nodeIndex2 = find(strcmp(gRoi.Nodes.Name,nameR2));
                
                [~, d] = shortestpath(gRoi,gRoi.Nodes.ID(nodeIndex1),gRoi.Nodes.ID(nodeIndex2));
                
                resultsR(k,j) = d;
                resultsR(j,k) = d;
            end
        end
        
        save(sprintf('%s\\matlab_SynDist_%03d.mat', outputPath, i), 'resultsR');

    end  
end

function re = getRoiName(names)
    if contains(names, 'apic')
       re = sprintf('roi%05d', sscanf(names, 'apic[%d]'));
    elseif contains(names, 'ep')
       re = sprintf('roi%05d', sscanf(names, 'ep%d'));
    elseif contains(names, 'bp')
       re = sprintf('roi%05d', sscanf(names, 'bp%d'));
    elseif contains(names, 'roi')
       re = sprintf('roi%05d', sscanf(names, 'roi%05d'));
    end
end