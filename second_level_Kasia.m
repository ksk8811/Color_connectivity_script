
clear
clc

subjects_dir={'/Users/k.siudakrzywicka/Desktop/RDS_fMRI/Controls/Processed/'};

suj = get_subdir_regex(subjects_dir,'^10*');

par.run=0;
par.display=1;

dirout_words = '/Users/k.siudakrzywicka/Desktop/RDS_fMRI/Controls/second_level/words_Kasia';
dirout_color = '/Users/k.siudakrzywicka/Desktop/RDS_fMRI/Controls/second_level/color_Kasia';

if ~exist(dirout_words, 'dir')
    mkdir(dirout_words)
end

if ~exist(dirout_color, 'dir')
    mkdir(dirout_color)
end

%%
matlabbatch{1}.spm.stats.factorial_design.dir = {dirout_words};
for i = 1:length(suj)
    matlabbatch{1}.spm.stats.factorial_design.des.t1.scans{1,i} = sprintf('%sstats_words/con_0009.nii,1', suj{i});
end

matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = matlabbatch{1}.spm.stats.factorial_design.des.t1.scans'


matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;