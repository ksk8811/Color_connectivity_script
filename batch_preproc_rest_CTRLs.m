
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

clear
clc

subjects_dir = '/Users/k.siudakrzywicka/Desktop/RDS_fMRI/Controls/Processed_566_471_vol';
cd(subjects_dir)
fileNames = file_names(pwd);

for i = 2:length(fileNames)
%     
    %subject directory
    suj = {fullfile(fileNames{i})};
    cd(suj{:})
    
    
    %functional and anatomic subdir (regular expressions to search or
    %functional and anatomical subdirs)
    par.dfonc_reg='rest';
    par.danat_reg='structural';
    anat = get_subdir_regex(suj,par.danat_reg);
    
    %for the preprocessing : Volume selection
    par.anat_file_reg = '^s.*mm.nii$';
    par.file_reg  = '^f.*.nii$'; %le nom generique du volume pour les fonctionel
    
    par.TR = 2.990;  %TR for slicetiming and first level
    par.run=1;par.display=1; %params to run the batch, run - running automatically or not; display - show batch in the spm window
    
    %setting paths for functional directories
    dfonc = get_subdir_regex_multi(suj,par.dfonc_reg)

%  
%     
%     %% realign and reslice
%     par.type = 'estimate_and_reslice';
%     j = job_realign(dfonc,par)
%     
%     
%     %% coregister mean fonc on brain_anat
    fanat = get_subdir_regex_files(anat,'^brain.*nii$',1)
%     
%     par.type = 'estimate';
%     for nbs=1:length(suj)
%         fmean(nbs) = get_subdir_regex_files(dfonc{nbs}(1),'^meanf');
%     end
%     
%     fo =get_subdir_regex_files({dfonc{1}},'^rf.*nii',1)
%     fo=fo.'
%     fo={fo}
%     j=job_coregister(fmean,fanat,fo,par)
    
    %% apply normalize
    %add the anat, c1, c2, c3, as well
    
    fy = get_subdir_regex_files(anat,'^y',1);
    c = get_subdir_regex_files(anat,'c[123]',3); %get the segmentations
    j=job_apply_normalize(fy,c,par) %normalise segmentations
    j=job_apply_normalize(fy,fanat,par) %normalise anatomy
%     j=job_apply_normalize(fy,fo,par) %normalise function
    
%     %% smoothing
%     
%     %smooth the data
%     
%     ffonc =  get_subdir_regex_files(dfonc,'^wrf');
%     par.smooth = [6 6 6];
%     j=job_smooth(ffonc,par);
    
end



%