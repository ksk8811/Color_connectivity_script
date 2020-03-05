

cd /Users/k.siudakrzywicka/Desktop/RDS_fMRI/Controls/color_rs_connectivity

files = dir('subject*');
files = {files.name};

for i = 1:length(files)
    func_dir = dir(fullfile(files{i}, '*EP2D*'));
    func_dir = fullfile(func_dir.folder, func_dir.name);
    
    create_intensity_mask_SPM(func_dir, fullfile(func_dir, 'intensity_mask_noSmooth.nii'));
    
end