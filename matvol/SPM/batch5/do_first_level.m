function do_first_level(param_file)
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
    params.funcdirs = parameters.funcdirs{n};
    params.subjectdir = parameters.subjects{n};
    if isfield(parameters,'anatdir')
        params.anatdir = parameters.anatdir{n};
    end
    if ~isfield(params,'logfile')
        params.logfile = 'batch_firstlevel.log';
    end
    logfile = params.logfile;
    
    cd(params.subjectdir);
    
    %- do the firstlevel stat
    %----------------------------------------------------------------------
    if isfield(params,'do_firstlevel')
        
        wd = fullfile(params.subjectdir,'stats');
        if ~exist(wd,'dir'),      mkdir(params.subjectdir,'stats');    end
        statdir = fullfile(wd,params.modelname);
        
        dothissuj=1;
        if isfield( params,'skipstat_if_exist')
            if params.skipstat_if_exist
                if exist(statdir)
                    dothissuj=0;
                end
            end
        end
        
        if dothissuj
            
            if isfield(params,'delete_stat_dir')
                unix(sprintf('rm -rf %s',fullfile(wd,params.modelname)))
            end
            
            if ~exist(statdir,'dir')
                disp(sprintf('Creating new output directory for stat model "%s".',params.modelname));
                mkdir(wd,params.modelname);
            end
            params.statdir = statdir;
            
            logmsg(logfile,sprintf('First level analysis in folder %s...',statdir));
            
            %-Get functional scans and realignment parameters file
            %-----------------------------------------------------------------------
            files = get_images_files(params,'func_stat');
            if params.rp
                rp = get_images_files(params,'rp_stat');
            end
            
            %- Jobs definition
            %----------------------------------------------------------------------
            jobs = {};
            nbjobs = 0;
            
            for k=1:length(params.do_firstlevel)
                action = params.do_firstlevel{k};
                do_single_stat
            end
            
            %    if strcmp(action,'display')
            %      b=questdlg('continue') ;
            %      b=inputdlg('continue') ;
            %      if strcmp(b,'No')
            %	break
            %      end
            %    end
        else
            fprintf('Skipping sujet %s \n',statdir)
        end
    end
    
    fprintf('\n\n')
    
end %Subject loop

cd(cwd);

%keyboard

if strcmp(action,'run_dist')
    do_job_distribute(job_to_distrib,parameters);
end

if strcmp(action,'display')
    
    spm_jobman('interactive',all_job);
    spm('show');
    
end