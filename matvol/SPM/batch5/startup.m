function startup(spm_path)

if isempty(which('get_user_param'))

  %- Setting SPM5 batch's path
  %-------------------------------------------------------
  p = fileparts(mfilename('fullpath'));

  addpath(p,'-BEGIN')
%  addpath(fullfile(p,'proto_def'),'-BEGIN')
  addpath(fullfile(p,'preproc'),'-BEGIN')
  addpath(fullfile(p,'firstlevel'),'-BEGIN')
  addpath(fullfile(p,'secondlevel'),'-BEGIN')
  addpath(fullfile(p,'tools'),'-BEGIN');
  addpath(fullfile(p,'retino'),'-BEGIN');
  fprintf('Lcogn SPM5 batch is installed in %s.\n',p);

  if ~isempty(which('spm'))
    spm('defaults','FMRI');
  end

end

if exist('spm_path')

  %- Initializing SPM5 defaults)
  %-------------------------------------------------------
  if isempty(which('spm'))
    addpath(genpath(spm_path), '-begin');
  
    spmver = spm('ver');
    if ~strcmp(spmver,'SPM5')
      error('Wrong SPM version: %s.',spmver);
    end
  
    spm('defaults','FMRI');
    fprintf('SPM5 is installed in %s.\n',spm('Dir'));
  end
end


