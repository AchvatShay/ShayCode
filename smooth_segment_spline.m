function [x, y, z] = smooth_segment_spline(x, y, z)
     if length(x) < 4
        return;
     end  
    
    matrixSeg = [x, y, z];
    indexSeg = 1:(size(matrixSeg, 1) - 1);
    segDistResult = vecnorm(matrixSeg(indexSeg, :) - matrixSeg(indexSeg + 1, :), 2, 2); 
    
    t = [0, cumsum(segDistResult)'];
    
%   ensure that ends are fixed
    
    w = ones(1, length(x));
%     w(1) = 1e6;
%     w(end) = w(1);
%     
    x = fnplt(csaps(t, x));
    y = fnplt(csaps(t, y));
    z = fnplt(csaps(t, z));
    
    x = x(2, :);
    y = y(2, :);
    z = z(2, :);
end