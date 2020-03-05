mask_side = 'left'; %left or right
ana = 'stats_color'; %stats subdirectory (where the SPMt is)
p_value = 0.001; %for statistical thresholding
index_img = 8; % number of the contrast of interest (one or more)
nvox = 500; %number of best voxels

rootdir = '/Users/k.siudakrzywicka/Desktop/RDS_fMRI/Controls/Processed_566_471_vol';
outputdir = '/Users/k.siudakrzywicka/Desktop/RDS_fMRI/Controls/colorRegions_rois';
subs = fileNames(rootdir); %create a cell array with subject names (names of the folders)


if ~exist(outputdir, 'dir')
    mkdir(outputdir)
end


mask = ['/Users/k.siudakrzywicka/Desktop/RDS_fMRI/RDS_localizers/Mask/ranat_all_gyri_chopped_' mask_side '.nii']; %full directory
mask_name = [mask_side '_ventral'];

makeroisColorRegions(subs, index_img, outputdir, rootdir, mask, mask_name, p_value)

for i = 1:length(index_img)
    files = dir(['bin*con' num2str(index_img(i)) '*' mask_side '*' num2str(p_value) '*']);
    files = {files.name}';
    name = ['pMap_colorRegions_con' num2str(index_img(i)) '_' mask_side '_p' num2str(p_value) '.nii'];
    create_pMap(files, name, outputdir)
end
