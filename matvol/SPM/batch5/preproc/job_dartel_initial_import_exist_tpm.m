function matlabbatch = job_dartel_initial_import_exist_tpm(fseg,outdir)

if ~iscell(outdir)
  outdir = cellstr(outdir);
end

fseg = cellstr(char(fseg));

matlabbatch{1}.spm.tools.dartel.initial.matnames = fseg;

matlabbatch{1}.spm.tools.dartel.initial.odir = outdir;
matlabbatch{1}.spm.tools.dartel.initial.bb = [NaN NaN NaN
                                              NaN NaN NaN];
matlabbatch{1}.spm.tools.dartel.initial.vox = 1.5;
matlabbatch{1}.spm.tools.dartel.initial.image = 0;
matlabbatch{1}.spm.tools.dartel.initial.GM = 1;
matlabbatch{1}.spm.tools.dartel.initial.WM = 1;
matlabbatch{1}.spm.tools.dartel.initial.CSF = 0;

matlabbatch{2}.spm.tools.dartel.warp1.images{1}(1) = cfg_dep;
matlabbatch{2}.spm.tools.dartel.warp1.images{1}(1).tname = 'Images';
matlabbatch{2}.spm.tools.dartel.warp1.images{1}(1).tgt_spec{1}.name = 'filter';
matlabbatch{2}.spm.tools.dartel.warp1.images{1}(1).tgt_spec{1}.value = 'nifti';
matlabbatch{2}.spm.tools.dartel.warp1.images{1}(1).sname = 'Initial Import: Imported Tissue (GM)';
matlabbatch{2}.spm.tools.dartel.warp1.images{1}(1).src_exbranch = substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1});
matlabbatch{2}.spm.tools.dartel.warp1.images{1}(1).src_output = substruct('.','cfiles', '()',{':', 1});
matlabbatch{2}.spm.tools.dartel.warp1.images{2}(1) = cfg_dep;
matlabbatch{2}.spm.tools.dartel.warp1.images{2}(1).tname = 'Images';
matlabbatch{2}.spm.tools.dartel.warp1.images{2}(1).tgt_spec{1}.name = 'filter';
matlabbatch{2}.spm.tools.dartel.warp1.images{2}(1).tgt_spec{1}.value = 'nifti';
matlabbatch{2}.spm.tools.dartel.warp1.images{2}(1).sname = 'Initial Import: Imported Tissue (WM)';
matlabbatch{2}.spm.tools.dartel.warp1.images{2}(1).src_exbranch = substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1});
matlabbatch{2}.spm.tools.dartel.warp1.images{2}(1).src_output = substruct('.','cfiles', '()',{':', 2});
matlabbatch{2}.spm.tools.dartel.warp1.settings.rform = 0;
matlabbatch{2}.spm.tools.dartel.warp1.settings.param(1).its = 3;
matlabbatch{2}.spm.tools.dartel.warp1.settings.param(1).rparam = [4 2 1e-06];
matlabbatch{2}.spm.tools.dartel.warp1.settings.param(1).K = 0;
matlabbatch{2}.spm.tools.dartel.warp1.settings.param(1).template = {fullfile(outdir{1},'Template_1.nii')};
matlabbatch{2}.spm.tools.dartel.warp1.settings.param(2).its = 3;
matlabbatch{2}.spm.tools.dartel.warp1.settings.param(2).rparam = [2 1 1e-06];
matlabbatch{2}.spm.tools.dartel.warp1.settings.param(2).K = 0;
matlabbatch{2}.spm.tools.dartel.warp1.settings.param(2).template = {fullfile(outdir{1},'Template_2.nii')};
matlabbatch{2}.spm.tools.dartel.warp1.settings.param(3).its = 3;
matlabbatch{2}.spm.tools.dartel.warp1.settings.param(3).rparam = [1 0.5 1e-06];
matlabbatch{2}.spm.tools.dartel.warp1.settings.param(3).K = 1;
matlabbatch{2}.spm.tools.dartel.warp1.settings.param(3).template =  {fullfile(outdir{1},'Template_3.nii')};
matlabbatch{2}.spm.tools.dartel.warp1.settings.param(4).its = 3;
matlabbatch{2}.spm.tools.dartel.warp1.settings.param(4).rparam = [0.5 0.25 1e-06];
matlabbatch{2}.spm.tools.dartel.warp1.settings.param(4).K = 2;
matlabbatch{2}.spm.tools.dartel.warp1.settings.param(4).template =  {fullfile(outdir{1},'Template_4.nii')};
matlabbatch{2}.spm.tools.dartel.warp1.settings.param(5).its = 3;
matlabbatch{2}.spm.tools.dartel.warp1.settings.param(5).rparam = [0.25 0.125 1e-06];
matlabbatch{2}.spm.tools.dartel.warp1.settings.param(5).K = 4;
matlabbatch{2}.spm.tools.dartel.warp1.settings.param(5).template =  {fullfile(outdir{1},'Template_5.nii')};
matlabbatch{2}.spm.tools.dartel.warp1.settings.param(6).its = 3;
matlabbatch{2}.spm.tools.dartel.warp1.settings.param(6).rparam = [0.25 0.125 1e-06];
matlabbatch{2}.spm.tools.dartel.warp1.settings.param(6).K = 6;
matlabbatch{2}.spm.tools.dartel.warp1.settings.param(6).template =  {fullfile(outdir{1},'Template_6.nii')};
matlabbatch{2}.spm.tools.dartel.warp1.settings.optim.lmreg = 0.01;
matlabbatch{2}.spm.tools.dartel.warp1.settings.optim.cyc = 3;
matlabbatch{2}.spm.tools.dartel.warp1.settings.optim.its = 3;
