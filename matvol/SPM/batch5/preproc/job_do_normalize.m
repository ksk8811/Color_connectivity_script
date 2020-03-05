function  matlabbatch = job_do_normalize(img,par)
%function  job = job_do_normalize(img,par)
%  img the list of images to be normalize
%  par structure of parameters defaults value are :
%      par.regtype = 'mni';
%      par.nits = 16;  % non linear iteration;
%      par.template=fullfile(spm('Dir'),'templates','T1.nii');
%        write option
%      par.preserve = 0;
%      par.bb = [-78 -112 -50 ; 78 76 85];
%      par.vox = [1 1 1];
%      par.interp = 1;
%      par.wrap = [0 0 0];
%      par.prefix = 'w';
%
%      par.run  = 0 ;  if not 0 : it will run the job
%      par.display = 1; if not 0 : it will display the job 


if ~exist('par')
  par='';
end

default_par.regtype = 'mni';
default_par.nits = 16;  % non linear iteration;
default_par.mask = '' ;


default_par.template=fullfile(spm('Dir'),'templates','T1.nii');

%write option
default_par.preserve = 0;
default_par.bb = [-78 -112 -50 ; 78 76 85];
default_par.vox = [1 1 1];
default_par.interp = 1;
default_par.wrap = [0 0 0];
default_par.prefix = 'w';
default_par.run  = 0 ;  
default_par.display = 1;

par = complet_struct(par,default_par);

if nargin==0
   img = spm_select(inf,'image','select files to normalize','',pwd);
end

if ~iscell(par.template)
  par.template = cellstr(par.template);
end

if ~iscell(img)
  img = cellstr(img);
end

for k = 1:length(img)
  matlabbatch{1}.spm.spatial.normalise.estwrite.subj(k).source = img(k);
if isempty(par.mask)
  matlabbatch{1}.spm.spatial.normalise.estwrite.subj(k).wtsrc = '';
else
  matlabbatch{1}.spm.spatial.normalise.estwrite.subj(k).wtsrc = par.mask(k);

end

  matlabbatch{1}.spm.spatial.normalise.estwrite.subj(k).resample = img(k);
end

matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.template = par.template;
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.weight = '';
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.smosrc = 8;
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.smoref = 0;
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.regtype = par.regtype;
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.cutoff = 25;
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.nits = par.nits;
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.reg = 1;

matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.preserve = par.preserve;
matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.bb = par.bb;
matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.vox = par.vox;
matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.interp = par.interp;
matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.wrap = par.wrap;
matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.prefix = par.prefix;

if par.display
  spm_jobman('interactive',matlabbatch);
  spm('show');
end

if par.run
  spm_jobman('run',matlabbatch);
end


