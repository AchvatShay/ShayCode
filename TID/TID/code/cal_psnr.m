function s=cal_psnr(A,B,row,col)

m = size(A,1);
n = size(A,2);
e = A-B;
e = e(row+1:m-row,col+1:n-col,:);
s = 10*log10(1*1/(norm(e(:))^2/numel(e)));

return;