function ff = get_images_files(params,type)

if ~exist('type'), type = 'func';end

logfile = params.logfile;

ff={};

switch type
    case 'func_stat'
        
        messag = sprintf('Scanning for functional scans...%s',params.funcwc_analyse);
        if isfield(params,'preproc_subdir')
            messag = sprintf('Scanning for functional scans...%s in subdir %s',params.funcwc_analyse,params.preproc_subdir);
        end
        logmsg(logfile,messag);
        
        
        for n=1:length(params.funcdirs)
            if isfield(params,'preproc_subdir')
                funcdirs{n} = spm_select('CPath',fullfile(params.funcdirs{n},params.preproc_subdir),params.subjectdir);
            else
                funcdirs{n} = spm_select('CPath',params.funcdirs{n},params.subjectdir);
            end
            
            f = spm_select('List',funcdirs{n},params.funcwc_analyse);
            ff{n} = [repmat(spm_select('CPath','',funcdirs{n}),size(f,1),1), f];
            
            if isfield(params,'skip')
                ff{n}(params.skip{n},:) = [];
            end
        end
        
        logmsg(logfile,sprintf('  found %d files in %d session(s) ',sum(cellfun('size',ff,1)),length(ff)));
        for n=1:length(params.funcdirs)
            %      logmsg(logfile,sprintf('    with %d files in session %d',size(ff{n},1),n));
            logmsg(logfile,sprintf('    with %d files in session %d (%s)',size(ff{n},1),n,params.funcdirs{n}));
        end
        
        if isfield(params,'concat_series')
            if params.concat_series
                ff = {char(ff)};
            end
        end
        
        
    case 'rp_stat'
        
        logmsg(logfile,'Realignment file ...');
        for n=1:length(params.funcdirs)
            if isfield(params,'preproc_subdir')
                funcdirs{n} = spm_select('CPath',fullfile(params.funcdirs{n},params.preproc_subdir),params.subjectdir);
            else
                funcdirs{n} = spm_select('CPath',params.funcdirs{n},params.subjectdir);
            end
            
            f = spm_select('List',funcdirs{n},params.rpwc);
            ff{n} = fullfile(spm_select('CPath','',funcdirs{n}),f);
            if params.rp && isempty(f)
                logmsg(logfile,'*** Realignment params cannot be found: option discarted ***');
                params.rp = 0;
            end
        end
        
        
    case 'func_preproc'
        %- Scanning for functional scans
        %----------------------------------------------------------------------
        %logmsg(logfile,'Scanning for functional scans...');
        
        messag = sprintf('Scanning for functional scans to preproc ...%s',params.funcwc);
        if isfield(params,'preproc_subdir')
            messag = sprintf('Scanning for functional scans...%s in subdir %s',params.funcwc,params.preproc_subdir);
        end
        
        %    change_sub_dir = 1;
        
        logmsg(logfile,messag);
        
        ff = get_subdir_regex_files(params.funcdirs,params.funcwc,params);
        
        
        
        logmsg(logfile,sprintf('  found %d files in %d session(s) ',sum(cellfun('size',ff,1)),length(ff)));
        for n=1:length(params.funcdirs)
            logmsg(logfile,sprintf('    with %d files in session %d (%s)',size(ff{n},1),n,params.funcdirs{n}));
        end
        
    case 'func_preproc_op'
        %- Scanning for functional scans
        %----------------------------------------------------------------------
        %logmsg(logfile,'Scanning for functional scans...');
        
        messag = sprintf('Scanning for oposite phase ...%s',params.funcwc);
        if isfield(params,'preproc_subdir')
            messag = sprintf('Scanning for oposite phase scans...%s in subdir %s',params.funcwc,params.preproc_subdir);
        end
        
        %    change_sub_dir = 1;
        
        logmsg(logfile,messag);
        
        ff = get_subdir_regex_files(params.funcdirs_op,params.funcwc,params);
        
        
        
        logmsg(logfile,sprintf('  found %d files in %d session(s) ',sum(cellfun('size',ff,1)),length(ff)));
        for n=1:length(params.funcdirs_op)
            logmsg(logfile,sprintf('    with %d files in session %d (%s)',size(ff{n},1),n,params.funcdirs_op{n}));
        end
        
        
        
    case 'anat_preproc'
        
        logmsg(logfile,'Scanning for anatomicallll scan...');
        
        %anatdir = deblank(spm_select('CPath',params.anatdir,params.subjectdir));
        
        ff = char(get_subdir_regex_files(params.anatdir,params.anatwc,params));
        
        %    anat = spm_select('List', anatdir, params.anatwc);
        if isempty(ff)
            warning('Cannot find anatomical scan "%s" in folder"%s"',params.anatwc,anatdir);
        elseif size(ff,1) > 1
            warning('Several files match anatomical scan "%s" in folder "%s"',params.anatwc,anatdir);
        end
        
        logmsg(logfile,sprintf('  found 1 file named %s.',ff));
        
        %    ff = fullfile(anatdir,deblank(anat(1,:)));
        %
        %    if isfield(params,'preproc_subdir')
        %      ff = change_file_path_to_preproc_dir(ff,params.preproc_subdir);
        %      ff = ff{1};
        %    end
        
    case 'contrast_file'
        
        logmsg(logfile,'Scanning for contrast images...');
        ff = {};
        msk = [];
        
        for i=1:length(params.icon)
            ff{i} = [];
            for j=1:length(params.subjects)
                
                confile = fullfile(params.subjects{j},'stats',...
                    params.modelname,sprintf('con_%04d.img',params.icon(i)));
                
                if ~exist(confile)
                    error('File %s does not exist',confile)
                end
                
                ff{i} = strvcat(ff{i}, confile);
            end
        end
        
        logmsg(logfile,sprintf('  Found %d sujects with %d contrast images each.',length(params.subjects),length(params.icon)));
        
    case 'all_anat'
        msk = [];
        
        for i=1:length(params.subjects)
            anatdir = get_subdir_regex(params.subjects{i},params.anat_dir_wc);
            if isfield(params,'preproc_subdir')
                anatdir{1} = fullfile(anatdir{1},params.preproc_subdir);
            end
            anat = spm_select('List', anatdir{1}, '^wms.*\.img$');
            if isempty(anat)
                %try a no modulate file
                anat = spm_select('List', anatdir{1}, '^ws.*\.img$');
            end
            if isempty(anat)
                error('can not find anat file ws* or wms* in dir %s\n',anatdir{1})
            end
            
            msk_file = fullfile(anatdir{1},anat);
            if ~exist(msk_file)
                error('File %s does not exist',msk_file)
            end
            
            msk = strvcat(msk,msk_file );
        end
        
        ff={msk};
        
        
    case 'statistical_mask'
        msk = [];
        
        for i=1:length(params.subjects)
            
            msk_file = fullfile(params.subjects{i},'stats',params.modelname,'mask.img');
            if ~exist(msk_file)
                error('File %s does not exist',msk_file)
            end
            
            msk = strvcat(msk,msk_file );
        end
        
        ff={msk};
        
        
end


