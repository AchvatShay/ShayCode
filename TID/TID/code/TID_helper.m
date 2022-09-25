

function [y_den, psnr_val, ssim_val] = TID_helper(y, z, sigma, data)

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

% check defaults
if ~isfield(data, 'N1')
    data.N1 = 8;
end
if ~isfield(data, 'Nstep')
    data.Nstep = 6;
end
if ~isfield(data, 'Ns')
    data.Ns = 101;
end
if ~isfield(data, 'tau_match')
    data.tau_match = 2*(data.N1)^2*sigma^2;
end
if ~isfield(data, 'N2')
    data.N2 = 20;
end
if ~isfield(data, 'N3')
    data.N3 = 40;
end

% initialize
database = data.database;
y_est = data.y_est;
N1 = data.N1;
Nstep = data.Nstep;
Ns = data.Ns;
tau_match = data.tau_match;
N2 = data.N2;
N3 = data.N3;

[height, width] = size(z);
rem_h = mod(height,Nstep);
rem_w = mod(width,Nstep);
if rem_h == 0
    ext_h = N1 - Nstep;
else
    ext_h = N1 - rem_h;
end
if rem_w == 0
    ext_w = N1 - Nstep;
else
    ext_w = N1 - rem_w;
end
z = [z, z(:,end:-1:end-ext_w+1)];
z = [z; z(end:-1:end-ext_h+1,:)];
y_est = [y_est, y_est(:,end:-1:end-ext_w+1)];
y_est = [y_est; y_est(end:-1:end-ext_h+1,:)];

y_den = zeros(size(z));
weight_total = zeros(size(z));
for row = 1:Nstep:height
    for col = 1:Nstep:width
        blk_est = y_est(row:row+N1-1, col:col+N1-1);
        array3D = [];
        for idx = 1:length(database)
            search_image = database{idx};
            row_min = max(row-(Ns-1)/2,1);
            row_max = min(row+(Ns-1)/2,size(search_image,1));        
            col_min = max(col-(Ns-1)/2,1);
            col_max = min(col+(Ns-1)/2,size(search_image,2));   
            if (row_max - row_min)< (Ns-1)/2
                row_min = size(search_image,1)-(Ns-1)/2;
                row_max = size(search_image,1);
            end
            if (col_max - col_min)< (Ns-1)/2
                col_min = size(search_image,2)-(Ns-1)/2;
                col_max = size(search_image,2);
            end                            
            search_window = search_image(row_min:row_max, col_min:col_max);
            [array3D_temp,~,~] = blk_matching(blk_est, search_window, N2, tau_match);
            array3D = cat(3, array3D, array3D_temp);
        end
        array3D = array3D_sorting(blk_est, array3D, N3, tau_match);         
        array2D = reshape(array3D, [N1*N1, size(array3D,3)]);
        blk_ref = z(row:row+N1-1, col:col+N1-1);
        blk_ref = blk_ref(:);
        
        %NLM weight
        W_vec = (array2D - repmat(blk_ref, 1, size(array2D,2))).^2;
        W_vec = sum(W_vec) - N1*N1*sigma^2;
        W_vec = exp(-max(W_vec, 0)/(N1*N1*sigma^2*0.6*0.6));
        W_vec = W_vec'/sum(W_vec);                
        mu = array2D * W_vec;  
              
        array2D = array2D - repmat(mu, 1, size(array2D,2));
        [U,S,~] = svd(array2D*diag(W_vec)*array2D');
        subDim = 10;
        U = U(:,1:subDim);
        S = S(1:subDim,1:subDim);
        blk_ref = blk_ref - mu; 
        spec_ref = U'*blk_ref;
        S = diag(S);
        spec_ref = spec_ref.*(S./(S+sigma^2));
        rec_ref = U*spec_ref;
        rec_ref = rec_ref + mu;
        rec_ref = reshape(rec_ref, [N1,N1]);
        weight = 1;
        y_den(row:row+N1-1, col:col+N1-1) = y_den(row:row+N1-1, col:col+N1-1) + rec_ref * weight;     
        weight_total(row:row+N1-1, col:col+N1-1) = weight_total(row:row+N1-1, col:col+N1-1) + weight; 
    end
end

y_den = y_den(1:height,1:width)./weight_total(1:height,1:width);
psnr_val = cal_psnr(y(1:end-8, 1:end-8), y_den(1:end-8, 1:end-8), 0, 0);
ssim_val = cal_ssim(y(1:end-8, 1:end-8), y_den(1:end-8, 1:end-8), 0, 0);




















