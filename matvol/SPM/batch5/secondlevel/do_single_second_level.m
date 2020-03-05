switch action
    
    case 'smooth_contrast'
        
        nbjobs = nbjobs + 1;
        
        logmsg(params.logfile,sprintf('Smoothing %d contrast files with fwhm = %d mm',sum(cellfun('size',ff,1)),params.smooth_con));
        jobs{nbjobs}.spatial{1}.smooth.data = cellstr(strvcat(ff));
        jobs{nbjobs}.spatial{1}.smooth.fwhm = params.smooth_con;
        
        
    case 'mean_anat'
        nbjobs = nbjobs + 1;
        
        logmsg(params.logfile,'Creating mean anat.');
        
        msk = get_images_files(params,'all_anat');
        
        jobs{nbjobs}.util{1}.imcalc.input = cellstr(msk{1});
        jobs{nbjobs}.util{1}.imcalc.output = fullfile(rfxdir,'mean_anat.img');
        
        jobs{nbjobs}.util{1}.imcalc.expression = 'mean(X)';
        
        jobs{nbjobs}.util{1}.imcalc.options.dmtx = 1;
        
    case 'mean_mask'
        nbjobs = nbjobs + 1;
        
        logmsg(params.logfile,'Creating mean mask.');
        
        msk = get_images_files(params,'statistical_mask');
        
        jobs{nbjobs}.util{1}.imcalc.input = cellstr(msk{1});
        jobs{nbjobs}.util{1}.imcalc.output = fullfile(rfxdir,'groupmask.img');
        
        if isfield (params,'group_mask_threshold')
            exp=sprintf('mean(X)>%f',params.group_mask_threshold)
            jobs{nbjobs}.util{1}.imcalc.expression = exp;
        else
            jobs{nbjobs}.util{1}.imcalc.expression = 'mean(X)>0.5';
        end
        jobs{nbjobs}.util{1}.imcalc.options.dmtx = 1;
        
    case 'specify'
        nbjobs = nbjobs + 1;
        
        logmsg(params.logfile,'Specifying models.');
        
        switch params.anova
            case 1 % full factorial
                jobs{nbjobs}.stats{1}.factorial_design.des.fd.fact = params.factors;
                
                for k=1:length(params.factors)
                    fact(k) = params.factors(k).levels;
                end
                level=ones(1,length(fact));
                if length(params.icon)~= prod(fact)
                    error('no good icon number')
                end
                
                for i=1:length(params.icon)
                    jobs{nbjobs}.stats{1}.factorial_design.des.fd.icell(i).levels = level;
                    jobs{nbjobs}.stats{1}.factorial_design.des.fd.icell(i).scans = cellstr(sff{i});
                    level = addlevel(level,fact);
                end
                
                jobs{nbjobs}.stats{1}.factorial_design.masking.im = 1; % implicit masking
                jobs{nbjobs}.stats{1}.factorial_design.masking.tm.tm_none = []; % threshold masking
                
                if isfield(parameters,'explicit_mask')
                    switch parameters.explicit_mask
                        case 'group_mask_mean'
                            jobs{nbjobs}.stats{1}.factorial_design.masking.em = cellstr(fullfile(rfxdir,'groupmask.img'));
                        case 'gray_template'
                            [p]=fileparts(which('spm')) ;
                            tt = fullfile(p,'tpm','grey.nii');
                            jobs{nbjobs}.stats{1}.factorial_design.masking.em = cellstr(tt);
                        otherwise
                            if exist(parameters.explicit_mask)
                                jobs{nbjobs}.stats{1}.factorial_design.masking.em = cellstr(parameters.explicit_mask);
                            else
                                error('do not find %s',parameters.explicit_mask);
                            end
                    end
                end
                
                jobs{nbjobs}.stats{1}.factorial_design.dir = cellstr(rfxdir);
                
            case 2 %flexible factorial
                jobs{nbjobs}.stats{1}.factorial_design.des.fblock.fac =	params.factors;
                
                nb_suj = size(sff{1},1);
                nb_con = length(sff);
                
                for n_suj=1:nb_suj
                    for n_con=1:nb_con
                        jobs{nbjobs}.stats{1}.factorial_design.des.fblock.fsuball.fsubject(n_suj).scans{n_con} = sff{n_con}(n_suj,:);
                        jobs{nbjobs}.stats{1}.factorial_design.des.fblock.fsuball.fsubject(n_suj).conds(n_con,1) = n_con;
                        jobs{nbjobs}.stats{1}.factorial_design.des.fblock.fsuball.fsubject(n_suj).conds(n_con,2) = n_suj;
                    end
                    
                end
                
                if isfield(parameters,'maininters')
                    jobs{nbjobs}.stats{1}.factorial_design.des.fblock.maininters = parameters.maininters;
                end
                
                if isfield(parameters,'explicit_mask')
                    
                    switch parameters.explicit_mask
                        case 'group_mask_mean'
                            jobs{nbjobs}.stats{1}.factorial_design.masking.em = cellstr(fullfile(rfxdir,'groupmask.img'));
                        case 'gray_template'
                            [p]=fileparts(which('spm')) ;
                            tt = fullfile(p,'tpm','grey.nii');
                            jobs{nbjobs}.stats{1}.factorial_design.masking.em = cellstr(tt);
                        otherwise
                            if exist(parameters.explicit_mask)
                                jobs{nbjobs}.stats{1}.factorial_design.masking.em = cellstr(parameters.explicit_mask);
                            else
                                error('do not find %s',parameters.explicit_mask);
                            end
                    end
                    
                end
                jobs{nbjobs}.stats{1}.factorial_design.dir = cellstr(rfxdir);
                
                if isfield(parameters,'covariate')
                    jobs{nbjobs}.stats{1}.factorial_design.cov = parameters.covariate;
                end
                
                
            case {1,2}
                fprintf('etoui')
                
            case 0 %one sample ttest
                for i=1:length(params.icon)
                    
                    jobs{nbjobs}.stats{i}.factorial_design.des.t1.scans =  cellstr(sff{i});
                    
                    jobs{nbjobs}.stats{i}.factorial_design.masking.im = 1; % implicit masking
                    jobs{nbjobs}.stats{i}.factorial_design.masking.tm.tm_none = [];
                    
                    if isfield(parameters,'explicit_mask')
                        
                        % threshold masking
                        switch parameters.explicit_mask
                            case 'group_mask_mean'
                                jobs{nbjobs}.stats{i}.factorial_design.masking.em = cellstr(fullfile(rfxdir,'groupmask.img'));
                            case 'gray_template'
                                [p]=fileparts(which('spm')) ;
                                tt = fullfile(p,'tpm','grey.nii');
                                jobs{nbjobs}.stats{i}.factorial_design.masking.em = cellstr(tt);
                            case ''
                                
                            otherwise
                                if exist(parameters.explicit_mask)
                                    jobs{nbjobs}.stats{i}.factorial_design.masking.em = cellstr(parameters.explicit_mask);
                                else
                                    error('do not find %s',parameters.explicit_mask);
                                end
                        end
                    end
                    
                    jobs{nbjobs}.stats{i}.factorial_design.dir = cellstr(fullfile(rfxdir,params.namecon{i}));
                end
                
            case -1 % two sample ttest
                
                for i=1:length(params.icon)
                    jobs{nbjobs}.stats{i}.factorial_design.des.t2.scans1 =  cellstr(sff1{i});
                    jobs{nbjobs}.stats{i}.factorial_design.des.t2.scans2 =  cellstr(sff2{i});
                    jobs{nbjobs}.stats{i}.factorial_design.masking.im = 1; % implicit masking
                    jobs{nbjobs}.stats{i}.factorial_design.masking.tm.tm_none = [];
                    
                    if isfield(parameters,'covariate'), jobs{nbjobs}.stats{i}.factorial_design.cov = parameters.covariate; end
                    
                    if isfield(parameters,'explicit_mask')
                        % threshold masking
                        switch parameters.explicit_mask
                            case 'group_mask_mean'
                                jobs{nbjobs}.stats{i}.factorial_design.masking.em = cellstr(fullfile(rfxdir,'groupmask.img'));
                            case 'gray_template'
                                [p]=fileparts(which('spm')) ;
                                tt = fullfile(p,'tpm','grey.nii');
                                jobs{nbjobs}.stats{i}.factorial_design.masking.em = cellstr(tt);
                            case ''
                                
                            otherwise
                                if exist(parameters.explicit_mask), jobs{nbjobs}.stats{i}.factorial_design.masking.em = cellstr(parameters.explicit_mask);
                                else warning('do not find parameters.explicit_mask %s \n you should not define it\n',parameters.explicit_mask); end
                        end
                        jobs{nbjobs}.stats{i}.factorial_design.dir = cellstr(fullfile(rfxdir,params.namecon{i}));
                    end
                end
                
        end
        
        %- Display results
        %----------------------------------------------------------------------
    case 'results'
        if ~params.anova
            nbjobs = nbjobs + 1;
            
            logmsg(params.logfile,'Display results...');
            for i=1:length(params.namecon)
                jobs{nbjobs}.stats{i}.results.spmmat = cellstr(fullfile(rfxdir,params.namecon{i},'SPM.mat'));
                jobs{nbjobs}.stats{i}.results.print  = 1;
                jobs{nbjobs}.stats{i}.results.conspec.title = ''; % determined automatically if empty
                
                
                %        jobs{nbjobs}.stats{i}.results.conspec.threshdesc = 'FWE'; % 'FWE' | 'FDR' | 'none'
                %        jobs{nbjobs}.stats{i}.results.conspec.thresh = 0.05;
                %        jobs{nbjobs}.stats{i}.results.conspec.extent = 0;
                
                jobs{nbjobs}.stats{i}.results.conspec.contrasts = Inf; % Inf for all contrasts
                jobs{nbjobs}.stats{i}.results.conspec.threshdesc = params.report.type;
                jobs{nbjobs}.stats{i}.results.conspec.thresh = params.report.thresh;
                jobs{nbjobs}.stats{i}.results.conspec.extent = params.report.extent;
                
            end
        else
            logmsg(params.logfile,'WARNING no results yet for anova second level');
            
        end
        
        
        
        
        %-Model estimation
        %----------------------------------------------------------------------
    case 'estimate'
        nbjobs = nbjobs + 1;
        
        logmsg(params.logfile,'Estimating models.');
        if ~params.anova
            for i=1:length(params.namecon)
                jobs{nbjobs}.stats{i}.fmri_est.spmmat = cellstr(fullfile(rfxdir,params.namecon{i},'SPM.mat'));
            end
        else
            jobs{nbjobs}.stats{1}.fmri_est.spmmat = cellstr(fullfile(rfxdir,'SPM.mat'));
        end
        
        
        %- Contrasts specification
        %----------------------------------------------------------------------
    case 'contrasts'
        
        
        if ~params.anova
            nbjobs = nbjobs + 1;
            logmsg(params.logfile,'Contrasts specification.');
            
            for i=1:length(params.namecon)
                jobs{nbjobs}.stats{i}.con.spmmat = cellstr(fullfile(rfxdir,params.namecon{i},'SPM.mat'));
                jobs{nbjobs}.stats{i}.con.consess{1}.tcon.name = sprintf('Positive effect of %s',params.namecon{i});
                jobs{nbjobs}.stats{i}.con.consess{1}.tcon.convec = 1;
                jobs{nbjobs}.stats{i}.con.consess{2}.tcon.name = sprintf('Negative effect of %s',params.namecon{i});
                jobs{nbjobs}.stats{i}.con.consess{2}.tcon.convec = -1;
            end
        else
            logmsg(params.logfile,'WARNING no contrast yet for anova second level');
            
            %        jobs{nbjobs}.stats{1}.con.spmmat = cellstr(fullfile(rfxdir,'SPM.mat'));
            %        jobs{nbjobs}.stats{1}.con.consess{1}.fcon.name = 'Effects of interest';
            %        m = eye(length(params.icon));
            %        for i=1:length(params.icon)
            %            jobs{nbjobs}.stats{1}.con.consess{1}.fcon.convec{i} = m(i,:);
            %        end
            
            
        end
        
        
        %- Save and Run job
        %----------------------------------------------------------------------
    case 'run'
        logmsg(params.logfile,sprintf('Job batch file saved in %s.',fullfile(rfxdir,'jobs_rfx_model.mat')));
        
        d=dir(fullfile(rfxdir,'jobs_rfx_model*.*'));
        
        if ~isempty(d)
            savexml(fullfile(rfxdir,['jobs_rfx_model',num2str(length(d)+1),'.xml']),'jobs');
        else
            savexml(fullfile(rfxdir,'jobs_rfx_model.xml'),'jobs');
        end
        
        spm_jobman('run',jobs);
        
    case 'display'
        spm_jobman('interactive',jobs);
        spm('show');
        
    otherwise
        error('The action %s in parameters.do_secondlevel is not defined',action);
end
