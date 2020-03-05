
%% to run this script with all fsl functions:
% - install fsl
% - create symbolic link to fsl (should be done automatically during installation)
% - create a symbolic link to matlab (can be done automatically during instalation, if not:

%       *Move to into /usr/local/bin: cd /usr/local/bin.
%       *Then create the link with the ln -s command. For example, if you are using R2016b, run this command: ln -s /usr/local/MATLAB/R2016b/bin/matlab matlab
%       *If there is an error "permission denied" try: sudo ln -s /usr/local/MATLAB/R2016b/bin/matlab matlab
%       *if you don't know where your matlab dir is, type matlabroot to the command
%window
%
% - run matlab from the terminal

%FYI there are some weird stuff going on with nii.gz. Check if your data ar
%e all in the same format (.nii or .nii.gz) If not unify it, because
%otherwise it gets lost.
%% setting paths and saving parameters

clear
clc
 % SPECIFY PATHS
addpath(genpath('/Users/k.siudakrzywicka/Desktop/RDS_fMRI/RDS_localizers/scripts/matvol/SPM/batch5'))
addpath(genpath('/Users/k.siudakrzywicka/Desktop/RDS_fMRI/RDS_localizers/scripts/matvol/Tools'))
addpath(genpath('/Users/k.siudakrzywicka/Desktop/RDS_fMRI/RDS_localizers/scripts/matvol/Wrappers'))

subjects_dir = '/Users/k.siudakrzywicka/Desktop/RDS_fMRI/Controls/Processed_566_471_vol'; %CHANGE HERE
cd(subjects_dir)
fileNames = file_names(pwd);



do_segment = 0;
do_brainExt = 0;
do_realign = 0;
do_topup = 0;
do_coreg = 0;
do_normalise = 0;
do_smooth = 0;
do_1stLev = 0;
do_contrasts = 1;

%%

for i = 1:length(fileNames)
    
    %subject directory
    suj = {fullfile(fileNames{i})};
    cd(suj{:})
    
    
    %functional and anatomic subdir (regular expressions to search or
    %functional and anatomical subdirs)
    par.dfonc_reg='^func.*[12]$';
    par.dfonc_reg_oposit_phase = '^func.*_blip$';
    par.danat_reg='structural';
    
    %for the preprocessing : Volume selection
    par.anat_file_reg = '^s.*mm.nii$';
    par.file_reg  = '^f.*.nii$'; %le nom generique du volume pour les fonctionel
    
    par.TR = 1.022;  %TR for slicetiming and first level
    par.run=1;par.display=1; %params to run the batch, run - running automatically or not; display - show batch in the spm window
    
    %setting paths for functional directories
    dfonc = get_subdir_regex_multi(suj,par.dfonc_reg)
    dfonc_op = get_subdir_regex_multi(suj,par.dfonc_reg_oposit_phase)
    dfoncall = get_subdir_regex_multi(suj,{par.dfonc_reg,par.dfonc_reg_oposit_phase })
    
    anat = get_subdir_regex(suj,par.danat_reg)
    fanat = get_subdir_regex_files(anat,par.anat_file_reg,1)%IF PATIENT put in the image with lesion substracted

    %
    %
    
    %% Segmentation
    if do_segment
        % if you have a lesion, then first make the mask so that 0 is lesion, then multiply your anat by the lesion image. transformated image put in the script.
        

        par.GM   = [0 0 1 0]; % Unmodulated / modulated / native_space/ import
        par.WM   = [0 0 1 0];
        par.CSF  = [0 0 1 0];

        j = job_do_segment(fanat,par)
    
    
    end
    
    %% anat brain extract using fsl
    %THIS IS NOT FSL BET!  adds via fsl_add the images of c1, c2 ad c3 to create the brain mask.
    %It then concatenates the brain mask with the anatomy, and thus extract the
    %brain. Worked fine for my extremely tricky patient, where BET failed
    %tremendousely (OR I dont know how to use it. could be that. it was probably that).
    if do_brainExt
        fanat = get_subdir_regex_files(anat,par.anat_file_reg,1);%taking a raw anat image, without any modifications

       
        fo=addsufixtofilenames(anat,'/mask_brain');
        do_fsl_add(ff,fo)
        to_remove = file_names('*gz');
        fm=get_subdir_regex_files(anat,'^mask_b',1);
        fo = addprefixtofilenames(fanat,'brain_');
        do_fsl_mult(concat_cell(fm,fanat),fo);

    end
    
    
    %% %slice timing
    % par.slice_order = 'sequential_ascending';
    % par.reference_slice='middel';
    %
    % j = job_slice_timing(dfonc,par)
    
    %% realign and reslice
    if do_realign
        par.type = 'estimate_and_reslice';
        j = job_realign(dfonc,par)

        %realign and reslice opposite phase
        par.type = 'estimate_and_reslice';
        j = job_realign(dfonc_op,par)
    end
    
    %% topup and unwarp
    %don't forget to substract the last slice if the no of slices in your epi
    %is uneven
    if do_topup
        par.file_reg = {'^rf.*nii$'}; par.sge=0;
        do_topup_unwarp_4D(dfoncall,par)
    end
    
    %% coregister mean fonc on brain_anat
    
    if do_coreg
        fanat = get_subdir_regex_files(anat,'^brain.*nii$',1)

        par.type = 'estimate';
        for nbs=1:length(suj)
            fmean(nbs) = get_subdir_regex_files(dfonc{nbs}(1),'^utmeanf');
        end

        fo =get_subdir_regex_files({dfonc{1}{1:2}},'^utrf.*nii',1)
        fo=fo.'
        fo={fo}
        j=job_coregister(fmean,fanat,fo,par)
    end
    
    %% apply normalize - for patients use BCBToolkit!
    %add the anat as well
    
    if do_normalise
    
        fo =get_subdir_regex_files({dfonc{1}{1:2}},'^utrf.*nii',1)
        fo=fo.'
        fo={fo}
        
        fy = get_subdir_regex_files(anat,'^y',1)
        j=job_apply_normalize(fy,fo,par)
    end
    
    
    %% smoothing
    
    %smooth the data
    
    if do_smooth
    
        ffonc =  get_subdir_regex_files(dfonc,'^wutrf');
        par.smooth = [6 6 6];
        j=job_smooth(ffonc,par);
    end 
    
    %% first level
    if do_1stLev
        odir =  [suj{:} '/Onsets'];
        par.file_reg = '^s.*';
        par.rp = 1;

        %% words

        st = [suj{:} '/stats_words'];
        if ~exist(st, 'dir')
            mkdir(st)
        end

        onset = get_subdir_regex_files(odir,'onsets_words.mat$',1);
        dfonc1 = {{dfonc{1}{1}}};
        j = job_first_level12(dfonc1,{st},onset,par)

        fspm = get_subdir_regex_files(st,'SPM',1)
        j = job_first_level12_estimate(fspm, par)

        
        
        %% colors

        st = [suj{:} '/stats_color'];
        if ~exist(st, 'dir')
            mkdir(st)
        end

        onset = get_subdir_regex_files(odir,'onsets_color.mat$',1);
        dfonc1 = {{dfonc{1}{2}}};
        j = job_first_level12(dfonc1,{st},onset,par)
        fspm = get_subdir_regex_files(st,'SPM',1)
        j = job_first_level12_estimate(fspm, par)
        
    end
    if do_contrasts
        
%         % WORDS
%         st = [suj{:} '/stats_words'];
%         fspm = get_subdir_regex_files(st,'SPM',1)
%         
%         
%         contrast.values = [mat2cell(eye(6,6), [1 1 1 1 1 1 ])' mat2cell((eye(5,5)-1)*(1+1/4)+1, [1 1 1 1 1])' ...
%             mat2cell([0 1 -0.33 -0.33 -0.33 0], 1), mat2cell([1 0 -0.33 -0.33 -0.33 0], 1),...
%             {[-1 1], [1 -1], [0 0 1 -0.5 -0.5 0], [0 0 -0.5 1 -0.5 0], [0 0 -0.5 -0.5 1 0], [0 0 -0.5 0.5 0.5 -0.5],[0 0 0.5 -0.5 -0.5 0.5] }];
%         contrast.names = [{'numbers','words','faces', 'houses', 'tools', 'body'}...
%             strcat({'numbers','words','faces', 'houses', 'tools'}, '_vs_others_noBODY'), ...
%             'words_vs_faces+houses+tools', 'numbers_vs_faces+houses+tools',...
%             'words_vs_numbers', 'numbers_vs_words', 'faces_vs_(houses+tools)', 'houses_vs_(faces+tools)', ...
%             'tools_vs_(faces+houses)', '(tools+houses)_vs_(faces+body)', '(faces+body)_vs_(tools+houses)'];
%         contrast.types = repmat({'T'},1,20);
%         par.delete_previous=1;
%         j = job_first_level12_contrast(fspm,contrast,par);

        %COLORS
        st = [suj{:} '/stats_color'];
        fspm = get_subdir_regex_files(st,'SPM',1)
        
        
        contrast.values =[mat2cell(eye(5,5), [1 1 1 1 1 ])'...
            {[0 0 -1 1] [0 -1 0 0 1] [1 -1] [0 -0.5 -0.5 0.5 0.5] -[0 -0.5 -0.5 0.5 0.5]...
            [-1 0 0 0 1] [1 0 0 0 -1]...
            [0 -0.5 0.5 -0.5 0.5] [0.33 -0.5 -0.5 0.33 0.33]...
            [0 0.5 -0.5 -0.5 0.5], [0.5 -1 1 -1 0.5], [-0.5 -0.5 1 -1 1]}];
        contrast.names = {'object_wrong_color','object_grey_scale','mondirans_grey_scale', 'mondrian_color', 'object_good_color', ...
            'mondrian_color_vs_greyScale', 'object_color_vs_greyScale','object_wrong_color_vs_greyScale', 'all_color_vs_greyscale','all_greyscale_vs_color' ...
            'object_good_vs_bad_color' 'object_bad_vs_good_color'...
            'objectsCOLvsGS_vs_mondrianCOLvsGS','all_color_vs_greyscale_inc_wrongCol', 'objects_vs_mondriands', 'color_x_shape_interaction', 'color_x_shape_interaction2'};
        contrast.types = repmat({'T'},1,length(contrast.names));
        par.delete_previous=1;
        j = job_first_level12_contrast(fspm,contrast,par);

        cd ..
    end
    
end



%