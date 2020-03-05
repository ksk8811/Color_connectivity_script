
addpath '/Users/k.siudakrzywicka/Desktop/tools/MATLAB_repository/'

coords_tal = [ -38, -76, -4; -32,-36,-20;...
    -12, -74, 0; -52, -34, -16;...
    -52 -36 -12;...
    -33, -36, -16; -24, -92, -12; -58 -52, -16;...
    62, -12, -12];

%names = {'Lafer_Souza_PC', 'Lafer_Souza_CC', 'Lafer_Souza_AC', 'Simmons_left', 'Zeki_V4_left'};

names ={'occipital_obj_namingChaoMartin','temporal_obj_namingChaoMartin', ...
    'occipital_col_naminChaoMartin','temporal_col_naminChaoMartin',...
    'verbal_col_know_vs_object_knowChaoMartin',...
    'verbal_col_knowSimmons','col_naminPrice', 'obj_namingPrice',...
    'visual_col_knowZeki'};

coodrs_MNI = tal2mni(coords_tal);

MNI_mat = '/Applications/fsl/data/standard/avg152T1_brain.nii.gz';
gunzip(MNI_mat)

V=spm_vol(MNI_mat); 
T=V.mat;

delete('/Applications/fsl/data/standard/avg152T1_brain.nii')

coords_voxel = mni2cor(coodrs_MNI, T);

cd('/Users/k.siudakrzywicka/Dropbox (PICNIC Lab)/Kasia/Dissertation/ROIs_for_figs')


for i = 1:size(coords_voxel, 1)
    system(['fslmaths /Applications/fsl/data/standard/avg152T1_brain.nii -mul 0 -add 1 -roi ' num2str(coords_voxel(i,1)) ...
        ' 1 ' num2str(coords_voxel(i,2)) ' 1 ' num2str(coords_voxel(i,3)) ' 1 0 1 ' names{i} '_point -odt float'])
    
    system(['fslmaths ' names{i} '_point.nii.gz -kernel sphere 9 -fmean ' names{i} '_sphere -odt float'])
end

