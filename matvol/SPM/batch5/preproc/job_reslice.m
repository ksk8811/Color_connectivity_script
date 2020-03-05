function  matlabbatch = job_reslice(fref,fmove,interp,prefixx)


  for k=1:length(fref)
%-----------------------------------------------------------------------
% Job configuration created by cfg_util (rev $Rev: 2787 $)
%-----------------------------------------------------------------------
	  matlabbatch{k}.spm.spatial.coreg.write.ref = fref(k);

matlabbatch{k}.spm.spatial.coreg.write.source = cellstr(char(fmove(k)));

matlabbatch{k}.spm.spatial.coreg.write.roptions.interp = interp;
matlabbatch{k}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
matlabbatch{k}.spm.spatial.coreg.write.roptions.mask = 0;
matlabbatch{k}.spm.spatial.coreg.write.roptions.prefix = prefixx;
end
