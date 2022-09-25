

function [y_den, psnr_val, ssim_val] = eNLM(y, z, sigma, data)

%eNLM: single image non-local means denoising using a targeted external database
%Input:
%              y: clean image(used for computing psnr and ssim)
%              z: noisy image
%          sigma: noise standard deviation
%           data: a structure containing the external database and other parameters
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
[y_eNLM1, PSNR_eNLM1, SSIM_eNLM1] = external_NLM(y, z, sigma, data);
fprintf('external NLM step 1, PSNR: %0.2f; SSIM: %0.4f \n', PSNR_eNLM1, SSIM_eNLM1);
% Step 2
data.y_est = y_eNLM1;
data.Nstep = 4;
[y_eNLM2, PSNR_eNLM2, SSIM_eNLM2] = external_NLM(y, z, sigma, data);
fprintf('external NLM step 2, PSNR: %0.2f; SSIM: %0.4f \n', PSNR_eNLM2, SSIM_eNLM2);
tElapsed = toc(tStart);
fprintf('eNLM takes %0.2f seconds \n\n', tElapsed);
y_den = y_eNLM2;
psnr_val = PSNR_eNLM2;
ssim_val = SSIM_eNLM2;























