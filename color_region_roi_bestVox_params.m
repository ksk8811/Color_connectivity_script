file =  '/Users/k.siudakrzywicka/Desktop/RDS_fMRI/Controls/second_level/20_pp/tools_vs_others_noBODY/spmT_0001.nii';
n = 50;
addpath('/Users/k.siudakrzywicka/Desktop/tools/MATLAB_repository/fMRI_tools/skrypty_bacze/BestVoxel');

roi_dir = '/Users/k.siudakrzywicka/Desktop/RDS_fMRI/Controls/colorRegions_rois/from_secondLevel_peaks/domain-regions/corrected/';

cd (roi_dir)

rois = dir('r*LOC*thr.nii');
rois = {rois.name};
rois = strcat(roi_dir, rois);

cd('/Users/k.siudakrzywicka/Desktop/RDS_fMRI/Controls/colorRegions_rois/from_secondLevel_peaks/domain-regions/corrected/best_50_vox');

for r = 1:length(rois)
    mask = rois{r};
    best_n_voxels(file,n, mask)
    
end