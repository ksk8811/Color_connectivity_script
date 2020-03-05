
%% to run this script with all fsl functions:
% - install fsl
% - create symbolic link to fsl (should be done automatically during installation)
% - create a symbolic link to matlab (can be done automatically during instalation, if not:

%       *Move to into /usr/local/bin: cd /usr/local/bin.
%       *Then create the link with the ln -s command. For example, if you are using R2016b, run this command: ln -s /usr/local/MATLAB/R2016b/bin/matlab matlab
%       *If there is an error "permission denied" try: sudo ln -s /usr/local/MATLAB/R2016b/bin/matlab matlab
% 
% - run matlab from the terminal

%FYI there are some weird stuff going on with nii.gz. Check if your data ar
%e all in the same format (.nii or .nii.gz) If not unify it, because
%otherwise it gets lost. 
%% setting paths and saving parameters

%subject directory
suj = {'/Users/k.siudakrzywicka/Desktop/RDS_fMRI/RDS_localizers/2017_04_05/'};


%functional and anatomic subdir (regular expressions to search or
%functional and anatomical subdirs)
par.dfonc_reg='^func.*[12]$';
par.dfonc_reg_oposit_phase = '^func.*_blip$';
par.danat_reg='structural';

%for the preprocessing : Volume selection
par.anat_file_reg_lesMasked  = '^s.*masked.nii$'; %le nom generique du volume pour l'anat
par.anat_file_reg = '^s.*mm.nii$';
par.file_reg  = '^f.*._cut.nii$'; %le nom generique du volume pour les fonctionel

par.TR = 1.022;  %TR for slicetiming and first level
par.run=0;par.display=1; %params to run the batch, run - running automatically or not; display - show batch in the spm window

%setting paths for functional directories
dfonc = get_subdir_regex_multi(suj,par.dfonc_reg)
dfonc_op = get_subdir_regex_multi(suj,par.dfonc_reg_oposit_phase)
dfoncall = get_subdir_regex_multi(suj,{par.dfonc_reg,par.dfonc_reg_oposit_phase })
% 
% 

%% Segmentation

% if you have a lesion, then first make the mask so that 0 is lesion, then multiply your anat by the lesion image. transformated image put in the script. 
anat = get_subdir_regex(suj,par.danat_reg)
fanat = get_subdir_regex_files(anat,par.anat_file_reg_lesMasked,1)%taking the image with lesion substracted

par.GM   = [0 0 1 0]; % Unmodulated / modulated / native_space/ import
par.WM   = [0 0 1 0]; 
par.CSF  = [0 0 1 0];

j = job_do_segment(fanat,par)




%% anat brain extract using fsl
%THIS IS NOT FSL BET!  adds via fsl_add the images of c1, c2 ad c3 to create the brain mask. 
%It then concatenates the brain mask with the anatomy, and thus extract the
%brain. Worked fine for my extremely tricky patient, where BET failed
%tremendousely (OR I dont know how to use it. could be that. it was probably that).
fanat = get_subdir_regex_files(anat,par.anat_file_reg,1);%taking a raw anat image, without any modifications

ff=get_subdir_regex_files(anat,'^c[123]',3);
fo=addsufixtofilenames(anat,'/mask_brain');
do_fsl_add(ff,fo)
fm=get_subdir_regex_files(anat,'^mask_b',1); 
fo = addprefixtofilenames(fanat,'brain_');
do_fsl_mult(concat_cell(fm,fanat),fo);




%% %slice timing
% par.slice_order = 'sequential_ascending';
% par.reference_slice='middel'; 
% 
% j = job_slice_timing(dfonc,par)

%% realign and reslice
par.type = 'estimate_and_reslice';
j = job_realign(dfonc,par)

%realign and reslice opposite phase
par.type = 'estimate_and_reslice';
j = job_realign(dfonc_op,par)

%% topup and unwarp 
%don't forget to substract the last slice if the no of slices in your epi
%is uneven
par.file_reg = {'^rf.*nii$'}; par.sge=0;
do_topup_unwarp_4D(dfoncall,par)

%% coregister mean fonc on brain_anat
fanat = get_subdir_regex_files(anat,'^brain.*nii$',1)

par.type = 'estimate';
for nbs=1:length(suj)
    fmean(nbs) = get_subdir_regex_files(dfonc{nbs}(1),'^utmeanf');
end

fo =get_subdir_regex_files({dfonc{1}{1:2}},'^utrf.*nii',1)
fo=fo.'
fo={fo}
j=job_coregister(fmean,fanat,fo,par)

%% apply normalize - for patients use BCBToolkit!
%add the anat as well

fy = get_subdir_regex_files(anat,'^y',1)
j=job_apply_normalize(fy,fo,par)

%smooth the data
ffonc = get_subdir_regex_files(dfonc,'^wutrf')
par.smooth = [6 6 6];
j=job_smooth(ffonc,par);




 %% first level
    
    odir =  [suj{:} '/onsets/'];
    par.file_reg = '^s6.*';
    par.rp = 1;
    
    %% words
    
    st = [suj{:} '/stats_words'];
    if ~exist(st, 'dir')
        mkdir(st)
    end
    
    onset = get_subdir_regex_files(odir,'onsets_words.mat$',1);
    dfonc1 = {{dfonc{1}{1}}};
    j = job_first_level12(dfonc1,{st},onset,par)
    %%
    
    fspm = get_subdir_regex_files(st,'SPM',1)
    j = job_first_level12_estimate(fspm, par)
    %%
    
    contrast.values = [mat2cell(eye(6,6), [1 1 1 1 1 1 ])' mat2cell((eye(5,5)-1)*(1+1/4)+1, [1 1 1 1 1])' ...
        mat2cell([0 1 -0.33 -0.33 -0.33 0], 1), mat2cell([1 0 -0.33 -0.33 -0.33 0], 1),...
        {[-1 1], [1 -1]}];
    contrast.names = [{'numbers','words','faces', 'houses', 'tools', 'body'}...
        strcat({'numbers','words','faces', 'houses', 'tools'}, '_vs_others_noBODY'), ...
        'words_vs_faces+houses+tools', 'numbers_vs_faces+houses+tools',...
        'words_vs_numbers', 'numbers_vs_words'];
    contrast.types = repmat({'T'},1,15);
    par.delete_previous=1;
    j = job_first_level12_contrast(fspm,contrast,par);
    %
    %% colors
    
    st = [suj{:} '/stats_color'];
    if ~exist(st, 'dir')
        mkdir(st)
    end
    
    onset = get_subdir_regex_files(odir,'onsets_color.mat$',1);
    dfonc1 = {{dfonc{1}{2}}};
    j = job_first_level12(dfonc1,{st},onset,par)
    fspm = get_subdir_regex_files(st,'SPM',1)
    %%
    j = job_first_level12_estimate(fspm, par)
    %%
    
    contrast.values =[mat2cell(eye(5,5), [1 1 1 1 1 ])' {[0 0 -1 1] [0 -1 0 0 1] [0 -0.5 -0.5 0.5 0.5] -[0 -0.5 -0.5 0.5 0.5] [-1 0 0 0 1]}];
    contrast.names = {'object_wrong_color','object_grey_scale','mondirans_grey_scale', 'mondrian_color', 'object_good_color', ...
        'mondrian_color_vs_greyScale', 'object_color_vs_greyScale', 'all_color_vs_greyscale','all_greyscale_vs_color' 'object_good_vs_bad+color'};
    contrast.types = repmat({'T'},1,10);
    par.delete_previous=1;
    j = job_first_level12_contrast(fspm,contrast,par);
    
% % %%%%%%%%first level - color
% mkdir('/Users/k.siudakrzywicka/Desktop/RDS_localizers/2017_04_05/stats_colors6')
% st = {'/Users/k.siudakrzywicka/Desktop/RDS_localizers/2017_04_05/stats_colors6'};
% odir = '/Users/k.siudakrzywicka/Desktop/RDS_localizers/2017_04_05/onsets';
% onset = get_subdir_regex_files(odir,'onsets_color.mat$',1);
% 
% par.file_reg = '^s6.*';
% par.rp = 1;
% dfonc1 = {{dfonc{1}{2}}};
% j = job_first_level12(dfonc1,st,onset,par)
% 
% % contrast.values = {[0 0 -1 1 ], [0 0 -1 1],[0 0 0 0 -1 1],[0 0 0 0 0 0 -1 1] };
% % contrast.names = {'rappel_diff','fluence','encodage', 'rappel_imm'};
% % contrast.types = {'T','T','T','T'};
% % par.delete_previous=1
% % j = job_first_level12_contrast(fspm,contrast,par)
% 
% % %%%%%%%%first level - words
% mkdir('/Users/k.siudakrzywicka/Desktop/RDS_localizers/2017_04_05/stats_words6')
% st = {'/Users/k.siudakrzywicka/Desktop/RDS_localizers/2017_04_05/stats_words6'};
% odir = '/Users/k.siudakrzywicka/Desktop/RDS_localizers/2017_04_05/onsets';
% onset = get_subdir_regex_files(odir,'onsets_words.mat$',1);
% 
% par.file_reg = '^s6.*';
% par.rp = 1;
% dfonc1 = {{dfonc{1}{1}}};
% j = job_first_level12(dfonc1,st,onset,par)




% spm_jobman('run',j)
% 
% 
% fspm = get_subdir_regex_files(st,'SPM',1)
% j = job_first_level12_estimate(fspm)
% 

% 
% 
% 
% %second level
% 
% %que les control !
% %suj = get_subdir_regex(pwd,'^2')
% 
% st = get_subdir_regex(suj,'stat','modelB')
% 
% j = job_second_level_ttest(st,dirout)
% 
% 
