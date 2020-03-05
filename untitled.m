
addpath '/Users/k.siudakrzywicka/Desktop/tools/MATLAB_repository/'

coodrs_tal = [-32, -76, -7; -25,-54,-10; -32,-37,-8;  -33, -36, -16];

names = {'Lafer_Souza_PC', 'Lafer_Souza_CC', 'Lafer_Souza_AC', 'Simmons_left'};

coodrs_MNI = tal2mni(coodrs_tal);

MNI_mat = '/Applications/fsl/data/standard/avg152T1_brain.nii';

V=spm_vol('MNI_mat'); 
T=V.mat;

coords_voxel = mni2cor(mni, T);