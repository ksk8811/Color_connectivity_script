%script non linear deformation + enchainement dtifit et bedpost


suj = get_subdir_regex;
%spm = get_subdir_regex(suj, 'spm')
T1dir = get_subdir_regex(suj,'S0[234]_t1mpr')
dtidir = get_subdir_regex(suj,'TR1[10]$')
dti = get_subdir_regex(suj,'dti');
T1_f = get_subdir_regex_files(T1dir,'^s.*nii$')
ff = get_subdir_regex_files(dti,'^4D_eddycor.nii');

%pour dwi : creation de mean_b0:


%mv DTI dir in a new root_dir
%extract B0 unwrap TO coregister T1 on DTI

do_fsl_roi(ff,'Bounwarp1',0,1)
do_fsl_roi(ff,'Bounwarp2',20,1)
do_fsl_roi(ff,'Bounwarp3',41,1)

fb = get_subdir_regex_files(dti,'Boun',6);

ff_mean = addsufixtofilenames(dti,'mean_B0')

do_fsl_mean(fb,ff_mean)

do_delete(fb)

%ok pour mean_b0


%pour dti: creation de dti_b0:

%copy T1 coregister to B0 
fB0 = do_fsl_roi(ff,'dti_Bo')

fB0 =  get_subdir_regex_files(dti,'dti_Bo.nii.gz$');
fB0 = unzip_volume(fB0);
%fB0 = get_subdir_regex_files(dti, 'dti_Bo.nii$')

%par.interp=0; par.type = 'estimate_and_write';par.prefix = 'rDTI_';
 par.type = 'estimate';

job = job_coregister(T1_f,fB0,'',par); 
spm_jobman('run',job)





pp.preproc_subdir='new_seg_B0';
pp.wanted_number_of_file=1;

T1_f = get_subdir_regex_files(T1dir,'^s.*nii$',pp) ;

% non linear deformation form anat to dti


B0_f = get_subdir_regex_files(dti,'mean_B0',pp)
B0_f = gunzip(B0_f)
job=job_new_segment(B0_f) ;
spm_jobman('run',job)
job=job_new_segment(T1_f) ;
spm_jobman('run',job)

anat = get_subdir_regex_files(T1dir,'^c3s.*nii$',pp);
epi = get_subdir_regex_files(dti,'^c3.*nii$',pp);

par.transfoname='SegC3_uw07_T1W_to_B0'
par.sge=1;
do_minc_nlin_trasfo(anat,epi,par)

aa = get_subdir_regex(T1dir, 'new_seg')

transfo = get_subdir_regex_files(aa,'mean_T1W_to_B0_nlin_inv.xfm',1)

eddy = get_subdir_regex_files(dti,{'^4D_eddycor.nii'},1);

do_minc_normalize(eddy,eddy,transfo);


%%% run dti fit and bedpostX

[p,sujname] = get_parent_path(suj);

par.do_fit=0; par.do_bedpost = 1;
par.queu = 'server_ondule';
par.data_to_fit = 'mimc_mean_T1W_to_B0_nlin_inv_4D_eddycor'; %sans extension sans .nii.gz

for nbsuj=1:length(suj)
  process_dti('','','',dti{nbsuj},sujname{nbsuj},par);
end
