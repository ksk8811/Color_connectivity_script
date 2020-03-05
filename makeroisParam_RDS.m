patient = 0; %if 0 then run controls

mask_side = 'left'; %left or right
ana = 'stats_words'; %stats subdirectory (where the SPMt is)
p_value = 0.005; %for statistical thresholding
index_img = 14; % number of the contrast of interest (one or more)
nvox = 300; %number of best voxels

cluster_threshold = 50; % if clustering, take only clusters with bigger k


if patient
    rootdir = '/Users/k.siudakrzywicka/Desktop/RDS_fMRI/RDS_localizers'; % the directory with all your sibjects
    outputdir = '/Users/k.siudakrzywicka/Desktop/RDS_fMRI/Controls/functional_rois/patient'; 
    subs_dir = dir(fullfile(rootdir, '*2017*'));
    subs = {subs_dir.name};
else
    rootdir = '/Users/k.siudakrzywicka/Desktop/RDS_fMRI/Controls/Processed_566_471_vol';
    outputdir = '/Users/k.siudakrzywicka/Desktop/RDS_fMRI/Controls/functional_rois';
    subs = fileNames(rootdir); %create a cell array with subject names (names of the folders)
end

%subs= subs(1);%to run additional controls

if ~exist(outputdir, 'dir')
    mkdir(outputdir)
end


mask = ['/Users/k.siudakrzywicka/Desktop/RDS_fMRI/RDS_localizers/Mask/ranat_all_gyri_chopped_' mask_side '.nii']; %full directory
mask_name = [mask_side '_ventral'];

makeroisFunc_RDS(subs, ana, index_img, nvox, outputdir, rootdir, mask, mask_name, p_value, cluster_threshold)
