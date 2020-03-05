function create_pMap(files, name, outdir)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

%this is terrible, but the regular way of putting the expression (sum( doesn't
%work with spm 
    

    matlabbatch{1}.spm.util.imcalc.input = files;
    matlabbatch{1}.spm.util.imcalc.output = name;
    matlabbatch{1}.spm.util.imcalc.outdir = outdir;
    matlabbatch{1}.spm.util.imcalc.expression = sprintf('sum(X)/%i*100', size(files,1));
    matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
    matlabbatch{1}.spm.util.imcalc.options.dmtx = 1;
    matlabbatch{1}.spm.util.imcalc.options.mask = 0;
    matlabbatch{1}.spm.util.imcalc.options.interp = 1;
    matlabbatch{1}.spm.util.imcalc.options.dtype = 4;

    spm_jobman('run', matlabbatch)

end
