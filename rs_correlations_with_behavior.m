
scan_dir = '/Users/k.siudakrzywicka/Desktop/RDS_fMRI/Controls/color_rs_connectivity/color_connectivity/results/firstlevel/bivariate';
scans = dir(fullfile(scan_dir, 'BETA*007.nii'));
scans = strcat({scans(1:14).name}, ',1')';


matlabbatch{1}.spm.stats.factorial_design.dir = '/Users/k.siudakrzywicka/Desktop/RDS_fMRI/Controls/color_rs_connectivity/whole_brain_behavior_correlations';
matlabbatch{1}.spm.stats.factorial_design.des.mreg.scans = scans;

matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov = struct('c', {}, 'cname', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.des.mreg.incint = 1;
matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.multi_cov.files = {'/Users/k.siudakrzywicka/Desktop/RDS_fMRI/Controls/color_rs_connectivity/behavioral_corelates/naming_categ.mat'};
matlabbatch{1}.spm.stats.factorial_design.multi_cov.iCFI = 1;
matlabbatch{1}.spm.stats.factorial_design.multi_cov.iCC = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;

spm_jobman('run', matlabbatch);