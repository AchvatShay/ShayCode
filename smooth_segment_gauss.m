function [x, y, z] = smooth_segment_gauss(x, y, z, sigma)
    if length(x) < 2
        return;
    end    
    
    matrixSeg = [x, y, z];
    indexSeg = 1:(size(matrixSeg, 1) - 1);
    segDistResult = vecnorm(matrixSeg(indexSeg, :) - matrixSeg(indexSeg + 1, :), 2, 2); 
    
    t = [0, cumsum(segDistResult)'];
    matrixSeg2 = matrixSeg;
    
    for i = 2:(length(x)-1)
        valueforDist = abs(t-t(i));
        weights=normpdf(valueforDist, 0, sigma);
        weights=weights/sum(weights);
        
        matrixSegtemp = [];
      
        for k = 1:length(weights)
             matrixSegtemp(k, :) = matrixSeg(k, :) .* weights(k);
        end
        
        matrixSeg2(i, :) = sum(matrixSegtemp, 1);
    end
    
    x = matrixSeg2(:, 1);
    y = matrixSeg2(:, 2);
    z = matrixSeg2(:, 3);
end