function lcogn_single_firstlevel(param_file,ask)

%----------------------------------------------------------------------

if nargin==0
  param_file='default_user_param'; ask=0;
elseif nargin==1
  ask=0;
end

%- Parameters for preprocessing a group of subjects
%----------------------------------------------------------------------

get_user_param
params=parameters;params.rootdir=rootdir;clear parameters;

%- List of tasks to be performed
%----------------------------------------------------------------------
if ~ask
    todo.deletefiles = 0;
    todo.specify     = 1;
    todo.estimate    = 1;
    todo.deletecontrasts = 0;    
    todo.contrasts   = 0;
    todo.results     = 0;
    todo.run         = 1;
    todo.sendmail    = 0;
else
    todo.deletefiles = ask('yes','Delete previous SPM model');
    todo.specify     = ask('yes','Specify first level model');
    todo.estimate    = ask('yes','Estimate first level model');
    todo.deletecontrasts = ask('yes','Delete previous contrasts');
    todo.contrasts   = ask('yes','Specify and estimate contrasts');
    todo.results     = ask('yes','Display results');
    todo.run         = ask('yes','Run Batch');
    todo.sendmail    = ask('yes','Send mail afterwards');
end


%-Parameters checking
%----------------------------------------------------------------------

statdir = fullfile(params.rootdir,[params.modelname '_fix_effect']);

if ~exist(statdir)
  disp(sprintf('Creating new output directory for stat model "%s".',statdir));
  mkdir(params.rootdir,[params.modelname '_fix_effect']);
end

cd(statdir);

logfile =  fullfile(statdir,[params.logfile '_fix_effect']);

logmsg(logfile,sprintf('Fix effect analysis in folder %s...',statdir));

spm_select('clearvfiles');  

%-Get functional scans and realignment parameters file, for each session
%-----------------------------------------------------------------------
%Sessiondir = spm_select('CPath', fullfile('..'),  params.rootdir);

logmsg(logfile,'Scanning for functional scans...');

files={};onset_def_file={};

for ns=1:length(subjects)
  subject_dir = fullfile(params.rootdir,subjects{ns});
  for nf=1:length(params.funcdirs{ns})
    params.funcdirs{ns}{nf} = spm_select('CPath',params.funcdirs{ns}{nf},subject_dir);
    f = spm_select('List',params.funcdirs{ns}{nf},params.funcwc_analyse);
    files{end+1} = [repmat(spm_select('CPath','',params.funcdirs{ns}{nf}),size(f,1),1), f];

    if ~isempty(params.skip)
      files{end}(params.skip,:) = [];
    end
    
    f = spm_select('List',params.funcdirs{ns}{nf},params.rpwc);
    rp{nf} = fullfile(spm_select('CPath','',params.funcdirs{ns}{nf}),f);
    if params.rp && isempty(f)
      logmsg(logfile,'*** Realignment parameters cannot be found: option discarted ***');
      params.rp = 0;
    end
  end

  %- Get subject-specific variables and display them
  %----------------------------------------------------------------------

  if isfield(params,'onset_matfile')
    for kk=1:length(params.onset_matfile)
      onset_def_file{end+1} = fullfile(subject_dir,params.onset_matfile{kk});
    end
  end
  
  if isfield(params,'user_regressor')
    if ~exist('user_regressor'), user_regressor = {};end
    for kk=1:length(params.user_regressor)
      user_regressor{end+1} = fullfile(subject_dir, params.user_regressor{kk});
    end
  end
  
end


logmsg(logfile,sprintf('  found %d files in %d session(s) ',sum(cellfun('size',files,1)),length(files)));
for n=1:length(files)
	logmsg(logfile,sprintf('    with %d files in session %d',size(files{n},1),n));
end
%keyboard

jobs = {};
nbjobs = 0;

%- Delete previous SPM.mat
%----------------------------------------------------------------------
if todo.deletefiles
    logmsg(logfile,'Deleting previous analysis...');
    fls = {'^SPM.mat$','^mask\..{3}$','^ResMS\..{3}$','^RPV\..{3}$',...
         '^beta_.{4}\..{3}$','^con_.{4}\..{3}$','^ResI_.{4}\..{3}$',...
         '^ess_.{4}\..{3}$', '^spm\w{1}_.{4}\..{3}$'};

    for i=1:length(fls)
        j = spm_select('List',statdir,fls{i});
        for k=1:size(j,1)
            spm_unlink(fullfile(statdir,deblank(j(k,:))));
        end
    end
else
    if exist(fullfile(statdir,'SPM.mat'),'file')
        logmsg(logfile,'Stats directory already contains an SPM model!');
    end
end
    
%- Model specification
%----------------------------------------------------------------------
if todo.specify
    logmsg(logfile,'Model Specification...');
    nbjobs = nbjobs + 1;
    
    timing.units   = 'secs';
    timing.RT      = params.TR;
    timing.fmri_t  = 16;%TODO with the slice timing
    timing.fmri_t0 = 1; %TODO ide

    jobs{nbjobs}.stats{1}.fmri_spec.timing = timing;
    jobs{nbjobs}.stats{1}.fmri_spec.dir = cellstr(statdir);
    
    switch lower(params.bases.type)
        case 'hrf'
            jobs{nbjobs}.stats{1}.fmri_spec.bases.hrf.derivs = [0 0];
		case 'hrf+deriv'
            jobs{nbjobs}.stats{1}.fmri_spec.bases.hrf.derivs = [1 0];
        case 'hrf+2derivs'
            jobs{nbjobs}.stats{1}.fmri_spec.bases.hrf.derivs = [1 1];
        case 'fir'
            jobs{nbjobs}.stats{1}.fmri_spec.bases.fir = ...
                struct('length',params.bases.length,'order',params.bases.order);
        case 'fourier'
            jobs{nbjobs}.stats{1}.fmri_spec.bases.fourier = ...
                struct('length',params.bases.length,'order',params.bases.order);
        otherwise
            error('Unknown basis function');
    end
    
    nbsess = length(files);

    if ~( nbsess==length(onset_def_file) )
      error('bad onset by session definition')
    end
    
    for i=1:nbsess
        jobs{nbjobs}.stats{1}.fmri_spec.sess(i).scans = cellstr(files{i});
        jobs{nbjobs}.stats{1}.fmri_spec.sess(i).hpf = params.HF_cut;
	jobs{nbjobs}.stats{1}.fmri_spec.sess(i).multi = onset_def_file(i);

%	ncond = max(condition(find(session==i)));
%        for j=1:ncond
%            ons = onset(find(condition==j & session==i));
%            dur = duration(find(condition==j & session==i));
%            jobs{nbjobs}.stats{1}.fmri_spec.sess(i).cond(j).name = ['sess' num2str(i) '.cond' num2str(j)];
%            jobs{nbjobs}.stats{1}.fmri_spec.sess(i).cond(j).onset = ons / 1000;
%            jobs{nbjobs}.stats{1}.fmri_spec.sess(i).cond(j).duration = dur / 1000;
%        end
%keyboard
        if params.rp
%	  if exist('user_regressor')
%does not work only one file	    jobs{nbjobs}.stats{1}.fmri_spec.sess(i).multi_reg{1} = cellstr(user_regressor{i});
	    jobs{nbjobs}.stats{1}.fmri_spec.sess(i).multi_reg = cellstr(rp{i});
%	  else
%	    jobs{nbjobs}.stats{1}.fmri_spec.sess(i).multi_reg = cellstr(rp{i});
%	  end
	else
	  if exist('user_regressor')
	    jobs{nbjobs}.stats{1}.fmri_spec.sess(i).multi_reg = cellstr(user_regressor{i});
	  end
	end
    end
end

%    keyboard
    
%- Model estimation
%----------------------------------------------------------------------
if todo.estimate
    logmsg(logfile,'Model Estimation...');
    nbjobs = nbjobs + 1;
    jobs{nbjobs}.stats{1}.fmri_est.spmmat = cellstr(fullfile(statdir,'SPM.mat'));
end

%- Delete previous contrasts
%----------------------------------------------------------------------
if todo.deletecontrasts
    logmsg(logfile,'Contrasts Deletion...');
    if ~todo.contrasts
        nbjobs = nbjobs + 1;
        jobs{nbjobs}.stats{1}.con.spmmat = cellstr(fullfile(statdir,'SPM.mat'));
        jobs{nbjobs}.stats{1}.con.delete = 1;
    end
end

%- Contrasts specification
%----------------------------------------------------------------------
if todo.contrasts
    logmsg(logfile,'Contrasts Specifications...');
    nbjobs = nbjobs + 1;
    evalstr = [	'[names, values] = ' params.contrast_mfile ];
    eval(evalstr);
    
	%- Adding 'Effect of interest' F-test
	%names = {'Effects of interest' names{:}};
	%nbc = 
	%values = {eye(nbc) values{:}};
	
	jobs{nbjobs}.stats{1}.con.spmmat = cellstr(fullfile(statdir,'SPM.mat'));
	for i=1:length(names)
    	if size(values{i},1) == 1
	        jobs{nbjobs}.stats{1}.con.consess{i}.tcon.name = names{i};
    		jobs{nbjobs}.stats{1}.con.consess{i}.tcon.convec = values{i};
		%jobs{nbjobs}.stats{1}.con.consess{i}.tcon.sessrep = 'none';
	else
    		jobs{nbjobs}.stats{1}.con.consess{i}.fcon.name = names{i};
    	        for j=1:size(values{i},1)
			jobs{nbjobs}.stats{1}.con.consess{i}.fcon.convec{j} = values{i}(j,:);
		end
		%jobs{nbjobs}.stats{1}.con.consess{i}.fcon.sessrep = 'none';
	end
	end
end

%- Display results
%----------------------------------------------------------------------
if todo.results
	logmsg(logfile,'Display results...');
	nbjobs = nbjobs + 1;
	
	jobs{nbjobs}.stats{1}.results.spmmat = cellstr(fullfile(statdir,'SPM.mat'));
	jobs{nbjobs}.stats{1}.results.print  = 1;
	jobs{nbjobs}.stats{1}.results.conspec.title = ''; % determined automatically if empty
	jobs{nbjobs}.stats{1}.results.conspec.contrasts = Inf; % Inf for all contrasts
	jobs{nbjobs}.stats{1}.results.conspec.threshdesc = params.report.type;
	jobs{nbjobs}.stats{1}.results.conspec.thresh = params.report.thresh;
	jobs{nbjobs}.stats{1}.results.conspec.extent = 0;
end

%- Send an email
%----------------------------------------------------------------------
if todo.sendmail
	logmsg(logfile,'Send email...');
	nbjobs = nbjobs + 1;
	
	jobs{nbjobs}.tools{1}.sendmail.recipient = 'antoinette.jobert@cea.fr';
	jobs{nbjobs}.tools{1}.sendmail.subject = '[SPM] [%DATE%] On behalf of SPM5';
	jobs{nbjobs}.tools{1}.sendmail.message = 'Hello from SPM!';
	jobs{nbjobs}.tools{1}.sendmail.attachments = {fullfile(statdir, ...
		['spm_' datestr(now,'yyyy') datestr(now,'mmm') datestr(now,'dd') '.ps'])};
	jobs{nbjobs}.tools{1}.sendmail.params.smtp = 'mx.intra.cea.fr';
	jobs{nbjobs}.tools{1}.sendmail.params.email = 'guillaume.flandin@cea.fr';
	jobs{nbjobs}.tools{1}.sendmail.params.zip = 'Yes';
end

%- Save and Run job
%----------------------------------------------------------------------
logmsg(logfile,sprintf('Job batch file saved in %s.',fullfile(statdir,'jobs_model.mat')));
save(fullfile(statdir,'jobs_model.mat'),'jobs');
if todo.run
    spm_jobman('run',jobs);
else
    spm_jobman('interactive',jobs);
    spm('show');
end
