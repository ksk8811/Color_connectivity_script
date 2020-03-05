function do_preproc(param_file)
% Toplevel batch for preprocessings
%

if nargin==0
  param_file='';
end

%- Parameters for preprocessing a group of subjects
%----------------------------------------------------------------------
if isstruct(param_file)
  parameters = param_file;
end

get_user_param

%- Loop over subjects
%----------------------------------------------------------------------
cwd = pwd;

%Begin Subjects loop
for n=1:length(parameters.subjects)
  
  params = parameters;

  %- Change varialbles that are subject specific
  %----------------------------------------------------------------------
  params.subjectdir = parameters.subjects{n};
  if isfield(params,'funcdirs')
      params.funcdirs = parameters.funcdirs{n};
  end
  if isfield(parameters,'funcdirs_op')
      params.funcdirs_op = parameters.funcdirs_op{n};
  end

  if isfield(parameters,'anatdir')
    if iscell(parameters.anatdir)
      params.anatdir = parameters.anatdir{n};
    end
  end
    
  if ~isfield(params,'logfile')
      params.logfile = 'batch_preproc.log';
  end
  logfile = params.logfile;
  
  
  cd(params.subjectdir);
  
  %- do the preprocessing first
  %----------------------------------------------------------------------
  if isfield(params,'do_preproc')
    %- select data for preprocessing
    %----------------------------------------------------------------------
    logmsg(logfile,sprintf('Preprocessing data in folder %s...',params.subjectdir));

    %spm_select('clearvfiles');  
    
    %- Scanning for anatomical scan
    try
      anat = get_images_files(params,'anat_preproc');
    catch
      disp(['Subject #' int2str(n) ' : no anat found']);
    end

    
    %- Scanning for functional scans
    if isfield(params,'funcdirs')
        curent_ff = get_images_files(params,'func_preproc');
        if isfield(parameters,'funcdirs_op')
            curent_ffop = get_images_files(params,'func_preproc_op');
        end
    end

    %- Jobs definition
    %----------------------------------------------------------------------
    jobs = {};
    nbjobs = 0;
    
    for k=1:length(params.do_preproc)
      action = params.do_preproc{k};
      do_single_preproc
    end
  end
  
  if strcmp(action,'display')
%    b=questdlg('continue') ;
%    if strcmp(b,'No')
%      break
%    end
  end
  
end %Subject loop

cd(cwd);

if strcmp(action,'run_dist')
  do_job_distribute(job_to_distrib,parameters);
end
if strcmp(action,'run_dist_free')
  do_job_distribute_free(job_to_distrib,parameters);
end
