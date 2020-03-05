
%% to run this script with all fsl functions:
% - install fsl
% - create symbolic link to fsl (should be done automatically during installation)
% - create a symbolic link to matlab (can be done automatically during instalation, if not:

%       *Move to into /usr/local/bin: cd /usr/local/bin.
%       *Then create the link with the ln -s command. For example, if you are using R2016b, run this command: ln -s /usr/local/MATLAB/R2016b/bin/matlab matlab
%       *If there is an error "permission denied" try: sudo ln -s /usr/local/MATLAB/R2016b/bin/matlab matlab
% 
% - run matlab from the terminal
%% setting paths and saving parameters

%subject directory
suj = {'/Users/k.siudakrzywicka/Desktop/RDS_loca/nifti'};


%functional and anatomic subdir (regular expressions to search or
%functional and anatomical subdirs)
par.dfonc_reg='^func.*[123]$';
par.dfonc_reg_oposit_phase = '^func.*_blip$';
par.danat_reg='structural';

%for the preprocessing : Volume selection
par.anat_file_reg  = '^s.*nii$'; %le nom generique du volume pour l'anat
par.file_reg  = '^f.*nii$'; %le nom generique du volume pour les fonctionel

par.TR = 1.26;  %TR for slicetiming and first level
par.run=0;par.display=1; %params to run the batch, run - running automatically or not; display - show batch in the spm window

%setting paths for functional directories
dfonc = get_subdir_regex_multi(suj,par.dfonc_reg)
dfonc_op = get_subdir_regex_multi(suj,par.dfonc_reg_oposit_phase)
dfoncall = get_subdir_regex_multi(suj,{par.dfonc_reg,par.dfonc_reg_oposit_phase })
anat = get_subdir_regex_one(suj,par.danat_reg) %should be no warning

% 
% 

%% Segmentation
anat = get_subdir_regex(suj,par.danat_reg)
fanat = get_subdir_regex_files(anat,par.anat_file_reg,1)

par.GM   = [0 0 1 0]; % Unmodulated / modulated / native_space/ import
par.WM   = [0 0 1 0]; 
par.CSF  = [0 0 1 0];

j = job_do_segment(fanat,par)


% %apply normalize on anat
% fy = get_subdir_regex_files(anat,'^y',1)
% fanat = get_subdir_regex_files(anat,'^ms',1)
% j=job_apply_normalize(fy,fanat,par)


%% anat brain extract using fsl

ff=get_subdir_regex_files(anat,'^c[123]',3);
fo=addsufixtofilenames(anat,'/mask_brain');
do_fsl_add(ff,fo)
fm=get_subdir_regex_files(anat,'^mask_b',1); 
fanat=get_subdir_regex_files(anat,'^s.*nii$',1);
fo = addprefixtofilenames(fanat,'brain_');
do_fsl_mult(concat_cell(fm,fanat),fo);



%% %slice timing
% par.slice_order = 'sequential_ascending';
% par.reference_slice='middel'; 
% 
% j = job_slice_timing(dfonc,par)

%% realign and reslice
par.file_reg = '^f.*nii$'; par.type = 'estimate_and_reslice';
j = job_realign(dfonc,par)

%realign and reslice opposite phase
par.file_reg = '^f.*nii$'; par.type = 'estimate_and_reslice';
j = job_realign(dfonc_op,par)

%% topup and unwarp 
%does not work, I still need to work on that!
par.file_reg = {'^rf.*nii$'}; par.sge=0;
do_topup_unwarp_4D(dfoncall,par)

%% coregister mean fonc on brain_anat
fanat = get_subdir_regex_files(anat,'^brain.*nii$',1)

par.type = 'estimate';
for nbs=1:length(suj)
    fmean(nbs) = get_subdir_regex_files(dfonc{nbs}(1),'^meanf');
end

fo = get_subdir_regex_files(dfonc,'^rf.*nii',1)
j=job_coregister(fmean,fanat,fo,par)

%% apply normalize
fy = get_subdir_regex_files(anat,'^y',1)
j=job_apply_normalize(fy,fo,par)

% %smooth the data
% ffonc = get_subdir_regex_files(dfonc,'^wrf')
% par.smooth = [8 8 8];
% j=job_smooth(ffonc,par);




% %%%%%%%%first level
st = {'/Users/k.siudakrzywicka/Desktop/COLORKNOWLEDGE_IRM/stats'};
odir = '/Users/k.siudakrzywicka/Desktop/COLORKNOWLEDGE_IRM/onsets/IRM';
onset1 = get_subdir_regex_files(odir,'^COLOR.*_01.*.mat$',1);
onset2 = get_subdir_regex_files(odir,'^COLOR.*_02.*.mat$',1);
onset3 = get_subdir_regex_files(odir,'^COLOR.*_03.*.mat$',1);
ons = concat_cell(onset1, onset2, onset3);
par.file_reg = '^w.*';
j = job_first_level12(dfonc,st,ons,par)
% 
% 
% %odir = get_subdir_regex(suj,'onset')
% %f1 = get_subdir_regex_files(odir,'modelO.*A1',1);f2 = get_subdir_regex_files(odir,'modelO.*D2',1);f3 = get_subdir_regex_files(odir,'modelO.*A3',1);f4 = get_subdir_regex_files(odir,'modelO.*D4',1);
% %fons = concat_cell(f1,f2,f3,f4);
% % j = job_first_level12(dfonc,st,fons,par)
% 
% par.file_reg = '^sws'
% 
% 
% spm_jobman('run',j)
% 
% 
% fspm = get_subdir_regex_files(st,'SPM',1)
% j = job_first_level12_estimate(fspm)
% 
% contrast.values = {[-1 1 ], [0 0 -1 1],[0 0 0 0 -1 1],[0 0 0 0 0 0 -1 1] };
% contrast.names = {'rappel_diff','fluence','encodage', 'rappel_imm'};
% contrast.types = {'T','T','T','T'};
% par.delete_previous=1
% j = job_first_level12_contrast(fspm,contrast,par)
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
