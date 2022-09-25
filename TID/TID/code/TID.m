

function [y_den, psnr_val, ssim_val] = TID(y, z, sigma, data)

%TID: the proposed optimal denoising filter using a targeted external database
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
%
%Output:
%          y_den: denoised image
%       psnr_val: psnr value
%       ssim_val: ssim value

tStart = tic;
% Step 1
data.y_est = z;
data.Nstep = 6;
[y_TID1, PSNR_TID1, SSIM_TID1] = TID_helper(y, z, sigma, data);
fprintf('proposed TID step 1, PSNR: %0.2f; SSIM: %0.4f \n', PSNR_TID1, SSIM_TID1);
% Step 2
data.y_est = y_TID1;
data.Nstep = 4;
[y_TID2, PSNR_TID2, SSIM_TID2] = TID_helper(y, z, sigma, data);
fprintf('proposed TID step 2, PSNR: %0.2f; SSIM: %0.4f \n', PSNR_TID2, SSIM_TID2);
tElapsed = toc(tStart);
fprintf('TID takes %0.2f seconds \n\n', tElapsed);

y_den = y_TID2;
psnr_val = PSNR_TID2;
ssim_val = SSIM_TID2;







