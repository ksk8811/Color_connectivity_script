function [threshold, r] = create_intensity_mask_SPM(functional_images_dir, intensity_mask_output_filename, start_args)
% [threshold,r] = create_intensity_mask_SPM(functional_images_dir, intensity_mask_output_name, start_args)
%
% Sample usage: 
% 1) [t,r] = create_intensity_mask_SPM('c:\data\subj1_func\', 'c:\data\subj1_intensity_mask.nii');
% 2) [t,r] = create_intensity_mask_SPM('c:\data\subj1_func\', 'c:\data\subj1_intensity_mask.nii', [0;100;500;250]);
%
% This function receives the name of a directory of functional images, creates
% a mean image, fits a model of two normal distibutions to the histogram 
% of mean intensities, and returns a lower threshold and goodness of fit 
% using r-value.
% The function also saves an image of an intensity mask (application of the
% threshold on the mean functional image) which can be used to mask the 
% functional images and avoid using voxels with signal dropout.
%
% THIS FUNCTION REQUIRES SPM8 OR LATER.
%
% Sami Abboud and Michael Peer, July 2015


%% Starting parameters
% Discard voxels under cutoff intensity value from the histogram (too many
% such voxels impair the Gaussian fitting)
cutoff = 100;
cutoff2 = 900;

% start_args could be provided to the function in case the estimation
% calculated lead the algorithm to diverge.
if (nargin <3)
    estimate_start_args = true;
else
    estimate_start_args = false;
end

%% Loading images and creating a mean functional image

func_dir_filenames=dir(fullfile(functional_images_dir,'*.img'));
if isempty(func_dir_filenames)
    % Kasia Siuda 21.06.2018
    % added wauf* to take only unsmoothed func
    func_dir_filenames=dir(fullfile(functional_images_dir,'wauf*.nii'));
end
num_pics=length(func_dir_filenames);

func_image1=spm_read_vols(spm_vol(fullfile(functional_images_dir,func_dir_filenames(1).name)));
if num_pics>1
    % for 3D files
    all_func_images=zeros([size(func_image1) num_pics]);
    all_func_images(:,:,:,1)=func_image1;
    for i=2:num_pics
        all_func_images(:,:,:,i)=spm_read_vols(spm_vol(fullfile(functional_images_dir,func_dir_filenames(i).name)));
    end
else
    % for 4D files
    all_func_images=func_image1;
end

% averaging across functional images to get mean image
mean_func_image = mean(all_func_images,4);

%% Model fitting to find the threshold

histogram_bins = 100;
[nelements,xcenters] = hist(mean_func_image(mean_func_image>cutoff & mean_func_image<cutoff2),histogram_bins);

y = nelements'; 
t = xcenters';

if estimate_start_args
    % Try to estimate Mu0 and s0 of the distribution of data
    % Get the point with max value after skipping the first 20% of bins
    first_point = histogram_bins*0.2;
    [~, idx] = max(nelements(first_point:end));
    mu2_0 = xcenters(first_point+idx);
    s2_0 = mu2_0/3;

    start_args = [0;50;mu2_0;s2_0];
end

fig = figure;
scale = max(nelements);
plot(t,y,'ro'); hold on; h = plot(t,y,'b'); hold off;
title('Input data'); ylim([0 scale]); xlabel('Intensity'); ylabel('Number of voxels');

outputFcn = @(x,optimvalues,state) fitoutputfun(x,optimvalues,state,t,y,h);
options = optimset('OutputFcn',outputFcn,'TolX',0.05);
estimated_args = fminsearch(@(x)modelfunc(x,t,y),start_args,options);

% Calculate estimated function
A = zeros(length(t),4);

A(:,1) = normpdf(t,estimated_args(1),estimated_args(2));
A(:,2) = normpdf(t,estimated_args(3),estimated_args(4));
A(:,3) = t;
A(:,4) = 1;

c = A\y;
z = A*c;

% Result values:
%     Mu1 estimated_args(1);
%     S1 = estimated_args(2);
%     Mu2 = estimated_args(3);
%     S2 = estimated_args(4);
%     r-value of fit = corr(y,z);

% Setting the threshold at the middle point between the peaks of the distributions
threshold = (estimated_args(3)-estimated_args(1))/2;
disp(threshold)
r = corr(y,z);  % the goodness of fit

%% Creating and saving an intensity mask
[outdir,outfile] = fileparts(intensity_mask_output_filename);
if isdir(outdir)    % verifying that the output directory exists
    
    mask_image = zeros(size(mean_func_image));
    mask_image(mean_func_image >= threshold) = 1;

    new_nifti_file = spm_vol(fullfile(functional_images_dir,func_dir_filenames(1).name));     % using the functional image parameters to save a new NIFTI image of the mask
    new_nifti_file(1).fname = intensity_mask_output_filename; 
    new_nifti_file(1).private.dat.fname =  intensity_mask_output_filename;
    spm_write_vol(new_nifti_file(1),mask_image);   % THE OUTPUT DIRECTORY MUST ALREADY EXIST FOR THIS TO WORK

else
    
    disp('Output directory does not exist!! skipping intensity mask creation...');

end

end     % end of main function




%% Helper functions

function stop = fitoutputfun(args, optimvalues, state, t, y, handle)
% v1.1
% Sami Abboud

% fitoutputfun based on FITOUTPUT Output function used by FITDEMO

    stop = false;
    % Obtain new values of fitted function at 't'
    A = zeros(length(t),4);

    A(:,1) = normpdf(t,args(1),args(2));
    A(:,2) = normpdf(t,args(3),args(4));
    A(:,3) = t;
    A(:,4) = 1;

    c = A\y;
    z = A*c;

    switch state
        case 'init'
            set(handle,'ydata',z)
            drawnow
            title('Input data and fitted function');
        case 'iter'
            set(handle,'ydata',z)
            drawnow
        case 'done'
            hold off;
    end
    pause(.04)
    
end


function err = modelfunc(args, t, y)
% v1.1
% Sami Abboud
% modelfunc based on FITFUN Used by FITDEMO.

    A = zeros(length(t),4);

    A(:,1) = normpdf(t,args(1),args(2));
    A(:,2) = normpdf(t,args(3),args(4));
    A(:,3) = t;
    A(:,4) = 1;

    c = A\y;
    z = A*c;

    err = norm(z-y);

end
