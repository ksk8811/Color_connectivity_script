function matlabbatch=job_vbm8_write_field(f)
%-----------------------------------------------------------------------
% Job configuration created by cfg_util (rev $Rev: 3357 $)
%-----------------------------------------------------------------------
matlabbatch{1}.spm.tools.vbm8.write.data = f; 
matlabbatch{1}.spm.tools.vbm8.write.extopts.dartelwarp = 1;
matlabbatch{1}.spm.tools.vbm8.write.extopts.ornlm = 0.7;
matlabbatch{1}.spm.tools.vbm8.write.extopts.mrf = 0.15;
matlabbatch{1}.spm.tools.vbm8.write.extopts.cleanup = 1;
matlabbatch{1}.spm.tools.vbm8.write.extopts.print = 0;
matlabbatch{1}.spm.tools.vbm8.write.output.GM.native = 0;
matlabbatch{1}.spm.tools.vbm8.write.output.GM.warped = 0;
matlabbatch{1}.spm.tools.vbm8.write.output.GM.modulated = 0;
matlabbatch{1}.spm.tools.vbm8.write.output.GM.dartel = 0;
matlabbatch{1}.spm.tools.vbm8.write.output.WM.native = 0;
matlabbatch{1}.spm.tools.vbm8.write.output.WM.warped = 0;
matlabbatch{1}.spm.tools.vbm8.write.output.WM.modulated = 0;
matlabbatch{1}.spm.tools.vbm8.write.output.WM.dartel = 0;
matlabbatch{1}.spm.tools.vbm8.write.output.CSF.native = 0;
matlabbatch{1}.spm.tools.vbm8.write.output.CSF.warped = 0;
matlabbatch{1}.spm.tools.vbm8.write.output.CSF.modulated = 0;
matlabbatch{1}.spm.tools.vbm8.write.output.CSF.dartel = 0;
matlabbatch{1}.spm.tools.vbm8.write.output.bias.native = 0;
matlabbatch{1}.spm.tools.vbm8.write.output.bias.warped = 0;
matlabbatch{1}.spm.tools.vbm8.write.output.bias.affine = 0;
matlabbatch{1}.spm.tools.vbm8.write.output.label.native = 0;
matlabbatch{1}.spm.tools.vbm8.write.output.label.warped = 0;
matlabbatch{1}.spm.tools.vbm8.write.output.label.dartel = 0;
matlabbatch{1}.spm.tools.vbm8.write.output.jacobian.warped = 0;
matlabbatch{1}.spm.tools.vbm8.write.output.warps = [1 1];
