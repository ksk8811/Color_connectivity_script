function jobs = do_normalize(anat,parameters,jobs)

anat = cellstr(char(anat));

if ~exist('jobs')
    nbjobs = 1;
else
    nbjobs = length(jobs) + 1;
end

if ~isfield(parameters,'logfile')
    parameters.logfile='';
end
if ~isfield(parameters,'redo')
    parameters.redo=1;
end

standard_normalize = 0;

if isfield(parameters.norm,'template')
    template = cellstr(parameters.norm.template);
else
    if isfield(parameters.norm,'reference_volume')
        switch parameters.norm.reference_volume
            case 'anat'
                template = cellstr(fullfile(spm('Dir'),'templates','T1.nii'));
            case 'epi'
                template = cellstr(fullfile(spm('Dir'),'templates','EPI.nii'));
        end
    end
end

switch parameters.norm.type
    case 'norm_only'
        
        logmsg(parameters.logfile,sprintf('Normalizing "%s" onto T1.nii',anat{1}));
        
        %Using Normalise
        jobs{nbjobs}.spatial{1}.normalise{1}.estwrite.roptions.vox = [1 1 1];
        jobs{nbjobs}.spatial{1}.normalise{1}.estwrite.eoptions.template = template;
        %   jobs{nbjobs}.spatial{1}.normalise{1}.estwrite.eoptions.weight = cellstr(fullfile(spm('Dir'),'apriori','brainmask.nii'));
        %   jobs{nbjobs}.spatial{1}.normalise{1}.estwrite.eoptions.cutoff = 25;
        %   jobs{nbjobs}.spatial{1}.normalise{1}.estwrite.eoptions.reg = 1;
        %   jobs{nbjobs}.spatial{1}.normalise{1}.estwrite.roptions.interp = 1;
        %   jobs{nbjobs}.spatial{1}.normalise{1}.estwrite.roptions.wrap = [0 0 0];
        jobs{nbjobs}.spatial{1}.normalise{1}.estwrite.subj(1).source = anat;
        jobs{nbjobs}.spatial{1}.normalise{1}.estwrite.subj(1).resample = anat;
        
        %   [pth,nm,xt] = fileparts(anat);
        %   anat_matfile = fullfile(pth,[nm '_sn.mat']);
        
    case 'norm_only_affine'
        
        logmsg(parameters.logfile,sprintf('Normalizing "%s" onto T1.nii',anat{1}));
        
        %Using Normalise
        jobs{nbjobs}.spatial{1}.normalise{1}.estwrite.eoptions.template = template;
        %   jobs{nbjobs}.spatial{1}.normalise{1}.estwrite.eoptions.weight = cellstr(fullfile(spm('Dir'),'apriori','brainmask.nii'));
        %   jobs{nbjobs}.spatial{1}.normalise{1}.estwrite.eoptions.cutoff = 25;
        %   jobs{nbjobs}.spatial{1}.normalise{1}.estwrite.eoptions.reg = 1;
        %   jobs{nbjobs}.spatial{1}.normalise{1}.estwrite.roptions.interp = 1;
        %   jobs{nbjobs}.spatial{1}.normalise{1}.estwrite.roptions.wrap = [0 0 0];
        jobs{nbjobs}.spatial{1}.normalise{1}.estwrite.eoptions.nits = 0;
        jobs{nbjobs}.spatial{1}.normalise{1}.estwrite.roptions.vox = [1 1 1];
        for nbs=1:length(anat)
            jobs{nbjobs}.spatial{1}.normalise{1}.estwrite.subj(nbs).source = anat(nbs);
            jobs{nbjobs}.spatial{1}.normalise{1}.estwrite.subj(nbs).resample = anat(nbs);
        end
        
        %   [pth,nm,xt] = fileparts(anat);
        %   anat_matfile = fullfile(pth,[nm '_sn.mat']);
        
    case 'seg_and_norm'
        
        
        [p f e] = fileparts(anat{1});
        wanat   = fullfile(p,['wm' f e]);
        
        if exist(wanat) & (parameters.redo==0)
            logmsg(parameters.logfile,sprintf('Skipping anat Segmentation because image %s exist',wanat));
            
        else
            
            
            %Using Segment
            logmsg(parameters.logfile,sprintf('  Unified Segmentation on "%s"',anat{1}));
            jobs{nbjobs}.spatial{1}.preproc.data = anat;
            
            if isfield(parameters.norm,'outputGM')
                jobs{nbjobs}.spatial{1}.preproc.output.GM = parameters.norm.outputGM;
            end
            if isfield(parameters.norm,'outputWM')
                jobs{nbjobs}.spatial{1}.preproc.output.WM = parameters.norm.outputWM;
            end
            
            if isfield(parameters.norm,'outputCSF')
                jobs{nbjobs}.spatial{1}.preproc.output.CSF = parameters.norm.outputCSF;
            end
            
            if isfield(parameters.norm,'mask')
                jobs{nbjobs}.spatial{1}.preproc.opts.msk = parameters.norm.mask;
            end
            
            [pth,nm,xt] = fileparts(anat{1});
            anat_matfile = fullfile(pth,[nm '_seg_sn.mat']);
            
            logmsg(parameters.logfile,sprintf('  Writing Normalized Bias Corrected "%s"',anat{1}));
            jobs{nbjobs}.spatial{2}.normalise{1}.write.subj.matname = cellstr(anat_matfile);
            jobs{nbjobs}.spatial{2}.normalise{1}.write.subj.resample = addprefixtofilenames(anat,'m');
            jobs{nbjobs}.spatial{2}.normalise{1}.write.roptions.vox = [1 1 1];
            
        end
        
    case 'vbm_norm'
        
        [p f e] = fileparts(anat{1});
        wanat   = fullfile(p,['wmr' f e]);
        
        if exist(wanat) & (parameters.redo==0)
            logmsg(parameters.logfile,sprintf('Skipping anat Segmentation because image %s exist',wanat));
            
        else
            
            jobs(nbjobs) = job_vbm8(anat);
            
            %Using vbm8
            logmsg(parameters.logfile,sprintf('  Unified Segmentation with VBM8 on "%s"',anat{1}));
            
            if isfield(parameters.normVBM,'outputGM')
                jobs{nbjobs}.spm.tools.vbm8.estwrite.output.GM = parameters.normVBM.outputGM;
            end
            if isfield(parameters.normVBM,'outputWM')
                jobs{nbjobs}.spm.tools.vbm8.estwrite.output.WM = parameters.normVBM.outputWM;
            end
            
            if isfield(parameters.normVBM,'outputCSF')
                jobs{nbjobs}.spm.tools.vbm8.estwrite.output.CSF = parameters.normVBM.outputCSF;
            end
                       
            if isfield(parameters,'nodisplay')
                jobs{nbjobs}.spm.tools.vbm8.estwrite.output.extopts.print=0
            end
            
        end
        
end

if isfield(parameters,'display_job')
    spm_jobman('interactive',jobs);
    spm('show');
end

if isfield(parameters,'run_job')
    spm_jobman('run',jobs);
end
