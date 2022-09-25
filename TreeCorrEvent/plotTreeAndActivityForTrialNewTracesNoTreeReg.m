function plotTreeAndActivityForTrialNewTracesNoTreeReg()
   BDATPAFolder = '\\jackie-analysis\F\Layer II-III\Analysis\Bas-S1-1\05.21.22-N2-Tuft-All';
   outputpath = '\\jackie-analysis\F\Layer II-III\Analysis\Bas-S1-1\05.21.22-N2-Tuft-All\Results\traces2\';
   mkdir(outputpath);
   ImagingSamplineRate = 30;
   
   trialTime = 12;
  
   tr = [];
   
   colorMapLim = [0,2];
   
   totalTrialTime = ImagingSamplineRate*trialTime;
   
   [roiActivity, roiActivityNames, ~] = loadActivityFileFromTPA(BDATPAFolder, {}, []);
   t = linspace(0, 12 * (round(size(roiActivity, 1) ./ totalTrialTime)), size(roiActivity, 1));
   roiActivity = roiActivity';
   
   roiSortedByCluster = 1:size(roiActivity, 1);  
      
    fig = figure;
    hold on;

    sb1 = subplot(1, 6, 1:5);
 
    revA = roiSortedByCluster(:);
    
    for j = 1:length(revA)
        plot(roiActivity(revA(j), :)+(j)*2, 'k');hold on;
    end
    
    ylim([1.5, length(roiActivityNames)*2 + 4]);
%     imagesc(t, 1:length(revA) ,roiActivity(revA, :));

    ax = gca;
    ax.YAxisLocation = 'right'; 
    yticks(2:2:length(revA)*2);
%     yticks(1:length(revA));
    
    yticklabels(roiActivityNames(revA));
    colormap('jet');
   
   
    caxis(colorMapLim);
    % Create title
    title(['Trial All']);
    
    mysave(fig, [outputpath, '\DendrogramROIShortestPathDistAndActivityROIFORTrial_AllTrail']);

end