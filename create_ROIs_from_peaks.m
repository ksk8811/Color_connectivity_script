clear 
clc


addpath '/Users/k.siudakrzywicka/Desktop/tools/MATLAB_repository/'
ROI_dir = '/Users/k.siudakrzywicka/Desktop/RDS_fMRI/Controls/colorRegions_rois/from_secondLevel_peaks/domain-regions/corrected/';
mkdir(ROI_dir)

mm = 8;

cd(ROI_dir)

%% DOMAIN
peaks = [40 -54 -22;...
    -38 -52 -18;...
    30 -46 -10;...
    -26 -42 -14;...
    50 -62 -4 ;...
    -50 -68 -6];

 coords_voxel = [25 36 25;...
     64 37 27;...
     30 40 31;...
     58 42 29;...
     20 32 34;...
     70 29 33];
     
     
     
     
 names = {'FFA_right'; 'FFA_left'; 'PPA_right'; 'PPA_left'; 'LOC_right'; 'LOC_left'};
     

%     

% %%COLOR
% peaks =[ -14 -94 -2;20 -94 -6;...
%     30 -72 -10; -32 -76 -16;...
%     -32 -56 -12; 34 -50 -20;...
%     -34 -44 -22; 22 -44 -20];
% 
% 
% coords_voxel = [52 16 35; 35 16 33;...
%     30 27 31; 61 25 28;...
%     61 35 30; 29 35 30;...
%     62 41 25;34 41 26 ];
 % I identified them with FSL view bc mni2cord have me misplaced points!   

% 
% names ={'earlyVis_left', 'earlyVis_right', ...
% 'occipitalFusiform_right','occipitalFusiform_left',...
%     'centralFusiform_left', 'centralFusiform_right',...
%     'anteriorFusiform_left', 'anteriorFusiform_right'};

    
% MNI_mat = '/Applications/fsl/data/standard/avg152T1_brain.nii.gz';
% gunzip(MNI_mat)
% 
% V1=spm_vol(MNI_mat(1:end-3)); 
% T1=V1.mat;
% coords_voxel1 = mni2cor(peaks, T1)
% 
% delete('/Applications/fsl/data/standard/avg152T1_brain.nii')
% 
% 
% 
% dim_temp = '/Users/k.siudakrzywicka/Desktop/RDS_fMRI/Controls/Processed_566_471_vol/1001/structural/wbrain_s_S03_anatomy_T1_1mm.nii';
% V=spm_vol(dim_temp);
% T=V.mat;
% coords_voxel = mni2cor(peaks, T);



for i = 1:size(coords_voxel, 1)
    system(['fslmaths /Applications/fsl/data/standard/avg152T1_brain.nii.gz -mul 0 -add 1 -roi ' num2str(coords_voxel(i,1)) ...
        ' 1 ' num2str(coords_voxel(i,2)) ' 1 ' num2str(coords_voxel(i,3)) ' 1 0 1 ' names{i} '_point -odt float'])

    system(['fslmaths ' names{i} '_point.nii.gz -kernel sphere 8 -fmean ' names{i} '_sphere' num2str(mm) 'mm -odt float'])
    
    system(['fslmaths ' names{i} '_sphere' num2str(mm) 'mm.nii.gz -bin ' names{i} '_sphere' num2str(mm) 'mm_bin'])
    
end


% delete('*point*');

gunzip('*.gz');

delete('*.gz');

%% reslice
dim_temp = {'/Users/k.siudakrzywicka/Desktop/RDS_fMRI/Controls/Processed_566_471_vol/1001/stats_color/spmT_0010.nii'}; %random T image for reslicing;

bin_roi = strcat(ROI_dir, names', ['_sphere' num2str(mm) 'mm_bin.nii']);

to_reslice = [dim_temp, bin_roi];
to_reslice = strcat(to_reslice, ',1')';


matlabbatch{1}.spm.spatial.realign.write.data = to_reslice;
matlabbatch{1}.spm.spatial.realign.write.roptions.which = [1 0];
matlabbatch{1}.spm.spatial.realign.write.roptions.interp = 4;
matlabbatch{1}.spm.spatial.realign.write.roptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.realign.write.roptions.mask = 1;
matlabbatch{1}.spm.spatial.realign.write.roptions.prefix = 'r';

spm_jobman('run', matlabbatch)

%% threshold at 1 to get rid of weird SPM reslicing effects

resliced = strcat(ROI_dir, 'r', names, ['_sphere' num2str(mm) 'mm_bin.nii']);


for res = 1:length(resliced)
    system(['fslmaths ' resliced{res} ' -thr 1 ' resliced{res}(1:end-4) '_thr'])
end

gunzip('*.gz')

delete('*.gz')

