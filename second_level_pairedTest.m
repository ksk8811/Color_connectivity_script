
%% PARAMS: DO CHANGE %%
conditions = 2; %1 - obj good col vs bad col, 2 obj vs mondrians
controls_dir = '/Users/k.siudakrzywicka/Desktop/RDS_fMRI/Controls/Processed_566_471_vol/';
model_dir = 'stats_color';

if conditions == 1
   con1 = 1;
   con2 = 5;
   final_dir = {'/Users/k.siudakrzywicka/Desktop/RDS_fMRI/Controls/second_level/objectsGC_vs_objWC_noCONTROL_pairedTest'};
elseif conditions == 2
   con1 = 6;
   con2 = 7;
   final_dir = {'/Users/k.siudakrzywicka/Desktop/RDS_fMRI/Controls/second_level/19_pp/objects_vs_abstract_color_pairedTest'};
end

if ~exist(final_dir{:})
    mkdir(final_dir{:})
end

%% FUNCTION: DO NOT CHANGE %%


scans1 = dir([controls_dir '**/' model_dir sprintf('/spmT_%0.4d.nii', con1)]);
scans1 = fullfile({scans1.folder}, strcat({scans1.name}, ',1'))';

scans2 = dir([controls_dir '**/' model_dir sprintf('/spmT_%0.4d.nii', con2)]);
scans2 = fullfile({scans2.folder}, strcat({scans2.name}, ',1'))';


matlabbatch{1}.spm.stats.factorial_design.dir = final_dir;
for i = 1:length(scans1)
    matlabbatch{1}.spm.stats.factorial_design.des.pt.pair(i).scans = {
                                                                        scans1{i}
                                                                        scans2{i}
                                                                     };
end
matlabbatch{1}.spm.stats.factorial_design.des.pt.gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.pt.ancova = 0;
matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
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

spm_jobman('run',matlabbatch)