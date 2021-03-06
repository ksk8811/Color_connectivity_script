
switch action
    
    %- Slice Timing
    case 'slicetiming'
        
        jobs = do_slice_timing(curent_ff,params,logfile,jobs);
        curent_ff = addprefixtofilenames(curent_ff,'a');
        
        
        %- Realign
    case 'realign'
        params.realign.type = 'mean_only';
        
        if isfield(params.realign,'reslice')
            if params.realign.reslice
                params.realign.type = 'mean_and_reslice';
            end
        end
        
        single_ser=0;
        if isfield(params.realign,'single_series')
            if params.realign.single_series, single_ser=1;end
        end
        if single_ser
            for k=1:length(curent_ff)
                jobs = do_realign(curent_ff(k),params,jobs);
            end
        else
            if exist('curent_ffop')
                [jobs curent_ffop] = do_realign(curent_ffop,params,jobs);
            end
            [jobs curent_ff] = do_realign(curent_ff,params,jobs);
        end
        
        %- Realign
    case 'realign_and_reslice'
        params.realign.type = 'mean_and_reslice';
        
        jobs = do_realign(curent_ff,params,jobs);
        curent_ff = addprefixtofilenames(curent_ff,'r');
        
        
        %- unwarp_oposite_path
        %----------------------------------------------------------------------
    case 'topup_unwarp'
        switch params.do_preproc{end}
            case 'display'
                params.display=1 ;
            case 'run'
                action = 'run';
                do_single_preproc;
                jobs={};
        end
        
        %do_topup_unwarp(curent_ff,curent_ffop,params)
        do_topup_unwarp_single_series([curent_ffop,curent_ff],params)
        
        curent_ff = addprefixtofilenames(curent_ff,'ut');
        curent_ffop = addprefixtofilenames(curent_ffop,'ut');
        
        
        %- Normalize epi
        %----------------------------------------------------------------------
        
    case 'normalize_mean_epi'
        params.norm.type = 'norm_only'; %   'norm_only' 'norm_only_affine'
        params.norm.reference_volume ='epi'; % 'anat' | 'epi'
        
        a = curent_ff{1}(1,:);
        b=addprefixtofilenames({a},'mean');
        src = b{1};
        
        jobs = do_normalize(src,params,jobs);
        
    case 'normalize_mean_epi_affine'
        params.norm.type = 'norm_only_affine';
        params.norm.reference_volume ='epi'; % 'anat' | 'epi'
        
        a = curent_ff{1}(1,:);
        b=addprefixtofilenames({a},'mean');
        src = b{1};
        
        jobs = do_normalize(src,params,jobs);
        
        %- Normalize anat
        %----------------------------------------------------------------------
    case 'normalize_anat'
        
        params.norm.type = 'norm_only'; % 'seg_and_norm'  'norm_only' 'norm_only_affine'
        params.norm.reference_volume ='anat'; % 'anat' | 'epi'
        
        jobs = do_normalize(anat,params,jobs);
        
    case 'normalize_anat_affine'
        
        params.norm.type = 'norm_only_affine';
        params.norm.reference_volume ='anat'; % 'anat' | 'epi'
        
        jobs = do_normalize(anat,params,jobs);
        
    case 'seg_and_norm_anat'
        
        params.norm.type = 'seg_and_norm'  ;
        params.norm.reference_volume ='anat'; % 'anat' | 'epi'
        
        jobs = do_normalize(anat,params,jobs);
        
    case 'seg_and_norm_vbm'
        
        params.norm.type = 'vbm_norm'  ;
        params.norm.reference_volume ='anat'; % 'anat' | 'epi'
        
        jobs = do_normalize(anat,params,jobs);
        
        
        %- Coregister
        %----------------------------------------------------------------------
    case 'coregister_fonc_on_anat'
        manat = addprefixtofilenames(cellstr(anat),'m');
        
        if ~isfield(params, 'norm')
            ref = anat;
        else
            if  findstr(params.norm.type,'norm_only')
                ref = anat; %there is no bias correction
            else
                ref = manat{1};
                if ~exist(ref)
                    ref = anat;
                end
            end
        end
        
        %check if the mean image is in the curent_ff
        aa = curent_ff;
        amean = curent_ff{1}(end,:);
        [pp ff]=fileparts(amean);
        if strfind(ff(1:4),'mean') %then this is the mean func image so remove it
            aa{1}(end,:)=''
        end
        other = strvcat(aa);

        if (params.do_coreg_on_mean)
            a = curent_ff{1}(1,:);
            b=removeprefixtofilenames({a},'r');
            b=addprefixtofilenames(b,'mean');
            
            [ppz ffz] = fileparts(a);
            if strcmp(ffz(1:3),'utr')
                b=removeprefixtofilenames({a},'utr');
                b=addprefixtofilenames(b,'utmean');
            end
            src = b{1};
            
            
        else
            src = curent_ff{1}(1,:);
            other(1,:)=[];
        end
        
        jobs = do_coregister(src,ref,other,logfile,jobs);
        
    case 'coregister_mean_fonc_on_raw_anat'
        params.do_coreg_on_mean = 1;
        params.norm.type = 'norm_only';
        action = 'coregister_fonc_on_anat';
        do_single_preproc
        
    case 'coregister_first_fonc_on_raw_anat'
        params.do_coreg_on_mean = 0;
        params.norm.type = 'norm_only';
        action = 'coregister_fonc_on_anat';
        do_single_preproc
        
    case 'coregister_first_fonc_on_anat'
        params.do_coreg_on_mean = 0;
        params.norm.type = 'seg_and_norm';
        action = 'coregister_fonc_on_anat';
        do_single_preproc
        
    case 'coregister_mean_fonc_on_anat'
        params.do_coreg_on_mean = 1;
        params.norm.type = 'seg_and_norm';
        action = 'coregister_fonc_on_anat';
        do_single_preproc
        
    case 'coregister_anat_on_mean_fonc'
        
        a = curent_ff{1}(1,:);
        b=removeprefixtofilenames({a},'r');
        b=addprefixtofilenames(b,'mean');
        
        [ppz ffz] = fileparts(a);
        if strcmp(ffz(1:3),'utr')
            b=removeprefixtofilenames({a},'utr');
            b=addprefixtofilenames(b,'utmean');
        end
        
        ref = b{1};
        
        src =   anat;
        other='';
        
        jobs = do_coregister(src,ref,other,logfile,jobs);
        
    case 'coregister_anat_on_first_fonc'
        
        a = curent_ff{1}(1,:);
        b=removeprefixtofilenames({a},'r');
        %    b=addprefixtofilenames(b,'mean');
        
        ref = b{1};
        
        src =   anat;
        other='';
        
        jobs = do_coregister(src,ref,other,logfile,jobs);
        
    case 'coregister_and_reslice_anat_on_mean_fonc'
        
        a = curent_ff{1}(1,:);
        b=removeprefixtofilenames({a},'r');
        b=addprefixtofilenames(b,'mean');
        
        ref = b{1};
        
        src =   anat;
        other='';
        
        jobs = do_coregister_and_reslice(src,ref,other,logfile,jobs);
        
    case 'coregister_mean_fonc_on_Template_apply_on_raw_anat'
        ref = (fullfile(spm('Dir'),'templates','EPI.nii'));
        
        a = curent_ff{1}(1,:);
        b=removeprefixtofilenames({a},'r');
        b=addprefixtofilenames(b,'mean');
        
        [ppz ffz] = fileparts(a);
        if strcmp(ffz(1:3),'utr')
            b=removeprefixtofilenames({a},'utr');
            b=addprefixtofilenames(b,'utmean');
        end
        
        src = b{1};
        
        aa=curent_ff; 
        %check if the mean image is in the curent_ff
        amean = curent_ff{1}(end,:)
        [pp ff]=fileparts(amean)
        if strfind(ff(1:4),'mean') %then this is the mean func image so remove it
            aa{1}(end,:)=''
        end
        
        aa(end+1)={anat};
        
        if isfield(parameters,'norm')
            if isfield(parameters.norm,'mask')
                aa(end+1) = parameters.norm.mask;
            end
        end

        other = strvcat(aa);
        
        jobs = do_coregister(src,ref,other,logfile,jobs);
        
    case 'coregister_first_fonc_on_Template_apply_on_raw_anat'
        ref = (fullfile(spm('Dir'),'templates','EPI.nii'));
        
        a = curent_ff{1}(1,:);
        %    b=removeprefixtofilenames({a},'r');
        %    b=addprefixtofilenames(b,'mean');
        src = a;
        
        aa=curent_ff; aa(end+1)={anat};
        other = strvcat(aa);
        
        jobs = do_coregister(src,ref,other,logfile,jobs);
        
        
        %- Apply anat normalization on fonctional
        %----------------------------------------------------------------------
    case 'apply_anat_norm_on_fonc'
        
        [pth,nm,xt] = fileparts(anat);
        
        if isfield(params.norm,'type')
            if  strfind(params.norm.type,'norm_only')
                norm_matfile = fullfile(pth,[nm '_sn.mat']);
            elseif strfind(params.norm.type,'seg_and_norm')
                norm_matfile = fullfile(pth,[nm '_seg_sn.mat']);
            elseif strfind(params.norm.type,'vbm_norm')
                norm_matfile = fullfile(pth,['y_r',nm,'.nii']);
            end
        else
            norm_matfile = fullfile(pth,[nm '_seg_sn.mat']);
            if ~exist(norm_matfile)
                norm_matfile = fullfile(pth,[nm '_sn.mat']);
                if ~exist(norm_matfile)
                    error('no normalisation matrix neither *_seg_sn nor *_sn')
                end
            end
        end
        
        jobs = do_apply_normalize(norm_matfile,curent_ff,params,jobs);
        curent_ff = addprefixtofilenames(curent_ff,'w');
        
        
        %- Apply epi normalization on fonctional
        %----------------------------------------------------------------------
    case 'apply_mean_epi_norm_on_fonc'
        
        a = curent_ff{1}(1,:);
        b=addprefixtofilenames({a},'mean');
        src = b{1};
        
        [pth,nm,xt] = fileparts(src);
        
        norm_matfile = fullfile(pth,[nm '_sn.mat']);
        
        jobs = do_apply_normalize(norm_matfile,curent_ff,params,jobs);
        curent_ff = addprefixtofilenames(curent_ff,'w');
        
        
        %- Apply epi normalization on anatomy
        %----------------------------------------------------------------------
    case 'apply_mean_epi_norm_on_fonc_and_anat'
        
        a = curent_ff{1}(1,:);
        b=addprefixtofilenames({a},'mean');
        src = b{1};
        
        [pth,nm,xt] = fileparts(src);
        
        norm_matfile = fullfile(pth,[nm '_sn.mat']);
        
        vol2normalize = curent_ff;
        vol2normalize{length(vol2normalize)+1} = anat;
        
        jobs = do_apply_normalize(norm_matfile,vol2normalize,params,jobs);
        curent_ff = addprefixtofilenames(curent_ff,'w');
        
        
        %Smooth
        %----------------------------------------------------------------------
    case 'smooth'
        
        logmsg(logfile,sprintf('Smoothing %d files ("%s"...) with fwhm = %d mm',sum(cellfun('size',curent_ff,1)),curent_ff{1}(1,:),params.smoothing));
        nbjobs = length(jobs) + 1;
        jobs{nbjobs}.spatial{1}.smooth.data = cellstr(strvcat(curent_ff));
        jobs{nbjobs}.spatial{1}.smooth.fwhm = params.smoothing;
        
    case {'freesurferall','freesurfercrop','freesurfer','freesurfer_qcache'}
        
        do_freesurfer_cmd
        
        %- Save and Run job
        %----------------------------------------------------------------------
    case 'run'
        [p,f]=fileparts(logfile);
        jname = ['jobs_preproc','_',f];
        if isfield(params,'preproc_subdir'),
            jname=[jname,'_',params.preproc_subdir];
        end
        
        d=dir([jname,'*']);
        
        if ~isempty(d)
            savexml([jname,num2str(length(d)+1),'.xml'],'jobs');
        else
            savexml([jname,'.xml'],'jobs');
        end
        
        if ~isempty(jobs)
            spm_jobman('run',jobs);
        end
        
    case 'run_dist'
        if ~isempty(jobs)
            [p,f]=fileparts(logfile);
            jname = ['jobs_preproc','_',f];
            if isfield(params,'preproc_subdir'),
                jname=[jname,'_',params.preproc_subdir];
            end
            
            d=dir([jname,'*']);
            
            if ~isempty(d)
                jname = [jname,num2str(length(d)+1),'.xml'];
            else
                jname = [jname,'.xml'];
            end
            
            savexml(jname,'jobs');
            
            if ~exist('job_to_distrib')
                job_to_distrib={};
            end
            
            job_to_distrib{end+1} = fullfile(pwd,jname);
            
        end
        
    case 'run_dist_free'
        
        if ~exist('job_to_distrib')
            job_to_distrib={};
        end
        
        if ~isempty(jobs)
            if ~isempty(jobs{1}.free_cmd)
                job_to_distrib{end+1} = jobs{1}.free_cmd;
            end
        end
        
        
    case 'display'
        
        spm_jobman('interactive',jobs);
        spm('show');
        
    otherwise
        error('do_preproc parametre %s is unknown',action)
end
