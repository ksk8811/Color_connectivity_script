roiy=get_subdir_regex('/home/sabine/data_nucleipark','^2','roi_yeb');
suj=get_parent_path(roiy);

roiy=get_subdir_regex(suj,'roi_yeb');
anat=get_subdir_regex(suj,'_t1');
fonc=get_subdir_regex(suj,{'^OFF','^S.*rest1_5'});


%coregister T1 on mean fonc
fa = get_subdir_regex_files(anat,'^s.*img')
ff = get_subdir_regex_files(fonc,'^mean.*img')
roif=get_subdir_regex_files(roiy,'img$')

par.type = 'estimate';
job = job_coregister(fa,ff,roif,par); 
spm_jobman('run',job)


%do the  normalisation
roif=get_subdir_regex_files(roiy,{'PPN.*img$','STN_S..img$','SN_S..img$','EGP_S..img$','IGP_S..img$'});

matnorm = get_subdir_regex_files(fonc,'^mean.*_sn.mat');
par.vox=[2 2 2];
j=job_apply_normalize(matnorm,roif,par);
spm_jobman('run',j)

%make the mean (and a 4D vol to check)
outdir='/home/sabine/data_nucleipark/ROI_NucleiPark_AAL/YEB';
roif=get_subdir_regex_files(roiy,'^w.*img');

yeb_regex = {'wIGP_SL','wIGP_SR','wEGP_SL','wEGP_SR','wSN_SL','wSN_SR','wSTN_SL','wSTN_SR','wPPN_SL','wPPN_SR'};
for kk=1:length(yeb_regex)
  ff = get_subdir_regex_files(roiy,[yeb_regex{kk},'.img'],1);
  do_fsl_mean(ff,fullfile(outdir,['mean_' yeb_regex{kk}]));
  do_fsl_merge(ff,fullfile(outdir,['4D_' yeb_regex{kk}]));
end

roif=get_subdir_regex_files(outdir,'4D')


%%%%%%%%%%%
%extract signal as reg
clear all

suj=get_subdir_regex('/home/sabine/data_nucleipark','^2');
%roiy=get_subdir_regex(suj,'roi_yeb');


statdir = get_subdir_regex(suj,'stat','^Global_no_reg$');

%if subject specific  
%roif=get_subdir_regex_files(roiy,{'wPPN.*img$','wIGP_S..img$'})
%same for all suj
roif=get_subdir_regex_files('/home/sabine/data_nucleipark/ROI_NucleiPark_AAL/YEB','mean');

outdir= get_subdir_regex(suj,'stat');
outdir = r_mkdir(outdir,'YEB');

extract_roi_signal_as_reg(statdir,roif,outdir)
