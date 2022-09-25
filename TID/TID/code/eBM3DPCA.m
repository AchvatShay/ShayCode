

function [y_den, psnr_val, ssim_val] = eBM3DPCA(y, z, sigma, data)

%eBM3DPCA: BM3DPCA denoising using a targeted external database
%Input:
%              y: clean image(used for computing psnr and ssim)
%              z: noisy image
%          sigma: noise standard deviation
%           data: a structure containing the following external database and other parameters
%                 database: external database 
%                    y_est: image used for database patch matching
%                       N1: N1xN1 is the reference block size (default: 8)
%                    Nstep: sliding step to process the next reference block (default: 6)
%                       Ns: NsxNs is the search window size for patch matching (default: 101)
%                tau_match: threshold for patch similarity (default: 2*N1^2*sigma^2)
%                       N2: maximum number of similar patches for each database image (default: 20)
%                       N3: maximum number of similar patches for the entire database (default: 40)
%                    hThld: threshold for hard filtering when Wiener filter is off
%                  bWiener: boolean indicating if Wiener filtering is on or off
%
%Output:
%          y_den: denoised image
%       psnr_val: psnr value
%       ssim_val: ssim value

tStart = tic;
% Step 1
data.y_est = z;
data.Nstep = 6;
data.hThld = 2.7;
data.bWiener = 0;
[y_eBM3DPCA1, PSNR_eBM3DPCA1, SSIM_eBM3DPCA1] = external_BM3DPCA(y, z, sigma, data);
fprintf('external BM3DPCA step 1, PSNR: %0.2f; SSIM: %0.4f \n', PSNR_eBM3DPCA1, SSIM_eBM3DPCA1);
% Step 2
data.y_est = y_eBM3DPCA1;
data.Nstep = 4;
data.bWiener = 1;
[y_eBM3DPCA2, PSNR_eBM3DPCA2, SSIM_eBM3DPCA2] = external_BM3DPCA(y, z, sigma, data);
fprintf('external BM3DPCA step 2, PSNR: %0.2f; SSIM: %0.4f \n', PSNR_eBM3DPCA2, SSIM_eBM3DPCA2);
tElapsed = toc(tStart);
fprintf('eBM3DPCA takes %0.2f seconds \n\n', tElapsed);

y_den = y_eBM3DPCA2;
psnr_val = PSNR_eBM3DPCA2;
ssim_val = SSIM_eBM3DPCA2;








