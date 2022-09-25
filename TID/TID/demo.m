
close all;
clear all;
clc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Demo file for TID (Targeted Image Denoising)
% Gaussian noise removal on noisy text or face images using a targeted database
%
% Enming Luo, Stanley H. Chan, and Truong Q. Nguyen
% University of California, San Diego
% March 2, 2016
%
% Copyright 2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath('code');
% re-compile the .cpp files to .mex files for patch matching
% the already compiled .mex files can also be found in videoprocessing.ucsd.edu/~eluo
mex -g code/blk_matching.cpp;
mex -g code/array3D_sorting.cpp;

%% prepare test image and database images
% path = 'data/face';
path = 'Data/text';                             % choose face denoising or text denoising
addpath(path);
y = im2double(imread('1.png'));                 % y: clean image
sigma = 60/255;                                 % sigma: noise standard deviation
z = y + sigma*randn(size(y));                   % z: noisy image
data.database = {};                             % database: example images
frmStart = 2;
frmEnd = 9;
for frmIdx = frmStart:frmEnd
    im = im2double(imread([path sprintf('\\%d.png', frmIdx)]));
    data.database = [data.database, {im}];
end

%% proposed TID denoising
[y_TID, PSNR_TID, SSIM_TID] = TID(y, z, sigma, data);

%% external NLM denoising
[y_eNLM, PSNR_eNLM, SSIM_eNLM] = eNLM(y, z, sigma, data);

%% external BM3DPCA denoising
[y_eBM3DPCA, PSNR_eBM3DPCA, SSIM_eBM3DPCA] = eBM3DPCA(y, z, sigma, data);

%% external LPG-PCA denoising
[y_eLPGPCA, PSNR_eLPGPCA, SSIM_eLPGPCA] = eLPGPCA(y, z, sigma, data);

%% external BM3D denoising
[y_eBM3D, PSNR_eBM3D, SSIM_eBM3D] = eBM3D(y, z, sigma, data);
















