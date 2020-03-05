
clear
clc

scan_dir = '/Users/k.siudakrzywicka/Desktop/RDS_fMRI/Controls/color_rs_connectivity/color_connectivity/results/firstlevel/bivariate';
scans = dir(fullfile(scan_dir, 'BETA*007.nii'));
scans = strcat(scan_dir, '/', {scans(1:14).name}, ',1')';
load '/Users/k.siudakrzywicka/Desktop/RDS_fMRI/Controls/color_rs_connectivity/behavioral_corelates/naming_categ.mat';


matlabbatch{1}.spm.stats.factorial_design.dir = {'/Users/k.siudakrzywicka/Desktop/RDS_fMRI/Controls/color_rs_connectivity/whole_brain_behavior_correlations'};
matlabbatch{1}.spm.stats.factorial_design.des.mreg.scans = scans;
                                                        
matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov = struct('c', {}, 'cname', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.des.mreg.incint = 1;
matlabbatch{1}.spm.stats.factorial_design.cov(1).c = behavior(:,1);

matlabbatch{1}.spm.stats.factorial_design.cov(1).cname = 'naming_acc';
matlabbatch{1}.spm.stats.factorial_design.cov(1).iCFI = 1;
matlabbatch{1}.spm.stats.factorial_design.cov(1).iCC = 1;

matlabbatch{1}.spm.stats.factorial_design.cov(2).c = behavior(:,2);
matlabbatch{1}.spm.stats.factorial_design.cov(2).cname = 'naming_logRT';
matlabbatch{1}.spm.stats.factorial_design.cov(2).iCFI = 1;
matlabbatch{1}.spm.stats.factorial_design.cov(2).iCC = 1;

matlabbatch{1}.spm.stats.factorial_design.cov(3).c = behavior(:,3);
matlabbatch{1}.spm.stats.factorial_design.cov(3).cname = 'categ_acc';
matlabbatch{1}.spm.stats.factorial_design.cov(3).iCFI = 1;
matlabbatch{1}.spm.stats.factorial_design.cov(3).iCC = 1;

matlabbatch{1}.spm.stats.factorial_design.cov(4).c = behavior(:,4);
matlabbatch{1}.spm.stats.factorial_design.cov(4).cname = 'categ_logRT';
matlabbatch{1}.spm.stats.factorial_design.cov(4).iCFI = 1;
matlabbatch{1}.spm.stats.factorial_design.cov(4).iCC = 1;

matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;

matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;


spm_jobman('run', matlabbatch);