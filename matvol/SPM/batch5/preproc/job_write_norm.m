function  matlabbatch = job_write_norm(mat,fi,par)
%old version 
%function  matlabbatch = job_write_norm(mat,fi,vox,interp,prefix,modulation)

if ~exist('par')
  par='';
end

if ~isfield(par,'vox')
  par.vox = [NaN NaN NaN];
end

if ~isfield(par,'interp')
  par.interp = 1;
end

if ~isfield(par,'prefix')
  par.prefix = 'w';
end

if ~isfield(par,'modulation')
  par.modulation = 0;
end

if ~isfield(par,'redo')
  par.redo=0;
end


if ~isfield(par,'bb')
  par.bb = [NaN NaN NaN; NaN NaN NaN];
end

fo = addprefixtofilenames(fi,par.prefix);

kk=1;

for k=1:length(mat)

  if exist(deblank(fo{k}(1,:))) & ~par.redo
    fprintf('SKIPING because output exist : %s\n',deblank(fo{k}(1,:)))
  else
    
  
    matlabbatch{kk}.spm.spatial.normalise.write.subj.matname = mat(k); 

    matlabbatch{kk}.spm.spatial.normalise.write.subj.resample = cellstr(char(fi(k))) ;%cell de string

    matlabbatch{kk}.spm.spatial.normalise.write.roptions.preserve = par.modulation; %0;
    matlabbatch{kk}.spm.spatial.normalise.write.roptions.bb = par.bb;
    matlabbatch{kk}.spm.spatial.normalise.write.roptions.vox = par.vox;%[1 1 1];
    matlabbatch{kk}.spm.spatial.normalise.write.roptions.interp = par.interp; % 0
    matlabbatch{kk}.spm.spatial.normalise.write.roptions.wrap = [0 0 0];
    matlabbatch{kk}.spm.spatial.normalise.write.roptions.prefix = par.prefix;
    kk=kk+1;
  end
  
end