
clear
clc

cd '/Users/k.siudakrzywicka/Desktop/RDS_fMRI/Controls/color_rs_connectivity'

files = dir('subject*');
files = {files.name};


for i = 1:length(files)
   
    
    func_struct = dir(fullfile(files{i}, '*EP2D*', 'wauf*.nii'));
    func_file = func_struct.name;
    func_dir = fullfile(func_struct.folder);
    
    copyfile(fullfile(func_dir, func_file), [fullfile(func_dir, func_file(1:end-4)) '_nonmasked.nii']);
    
    system([ 'fslmaths ' fullfile(func_dir, func_file) ' -mas ' fullfile(func_dir, 'intensity_mask_noSmooth.nii') ' ' fullfile(func_dir, func_file)] )
    
    gunzip([fullfile(func_dir, func_file) '.gz'])
    
    
end
