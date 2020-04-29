clear 
clc


addpath '/Users/k.siudakrzywicka/Desktop/tools/MATLAB_repository/' %the path with the script
ROI_dir = '/Users/k.siudakrzywicka/Desktop/RDS_fMRI/Controls/colorRegions_rois/from_secondLevel_peaks/color-regions-p001corr/final/8mmspheres/'; %ROI directory
mkdir(ROI_dir) %if the ROI_dir does not exsit

mm = 8; %sphere radius

cd(ROI_dir)

%MNI peak coordinates (x,y,z)
peaks =[ -14 -94 -2;20 -94 -6;...
    30 -72 -10; -32 -76 -16;...
    -32 -56 -12; 34 -50 -20;...
    -34 -44 -22; 22 -44 -20];

%compute coordinates in voxel space

MNI_mat = '/Applications/fsl/data/standard/avg152T1_brain.nii.gz'; %this is the MNI template that comes with FSL. Change to your FSL directory
gunzip(MNI_mat)

V1=spm_vol(MNI_mat(1:end-3)); %uses SPM function. make sure to add SPM to the path
T1=V1.mat;
coords_voxel1 = mni2cor(peaks, T1);
delete('/Applications/fsl/data/standard/avg152T1_brain.nii'); %delete unzipped MNI template


 
%ROI names
names ={'earlyVis_left', 'earlyVis_right', ...
'occipitalFusiform_right','occipitalFusiform_left',...
    'centralFusiform_left', 'centralFusiform_right',...
    'anteriorFusiform_left', 'anteriorFusiform_right'};

% use FSL functions to create the spheres

for i = 1:size(coords_voxel, 1)
    system(['fslmaths ' MNI_mat ' -mul 0 -add 1 -roi ' num2str(coords_voxel(i,1)) ...
        ' 1 ' num2str(coords_voxel(i,2)) ' 1 ' num2str(coords_voxel(i,3)) ' 1 0 1 ' names{i} '_point -odt float']) %creates a single point in the peak location

    system(['fslmaths ' names{i} '_point.nii.gz -kernel sphere 8 -fmean ' names{i} '_sphere' num2str(mm) 'mm -odt float']) %creates a sphere around the point
    
    system(['fslmaths ' names{i} '_sphere' num2str(mm) 'mm.nii.gz -bin ' names{i} '_sphere' num2str(mm) 'mm_bin']) %binarizes the sphere
    
end


