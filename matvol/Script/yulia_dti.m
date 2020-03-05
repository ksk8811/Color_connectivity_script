%mv DTI dir in a new root_dir
new_root_dir = '/servernas/images/yulia/DTI_fsl';

d = get_subdir_regex('/servernas/images/yulia/tourette','.*','DTI');

s = get_parent_path(d);
[rr,sujname] = get_parent_path(s);

sn = r_mkdir(new_root_dir,sujname);
dn = r_movefile(d,sn,'move')

%copy anat

nana = r_mkdir(sn,'anat');

ana = get_subdir_regex(s,'t1mpr');
[s,anadir] = get_parent_path(ana);
ana_orig = get_subdir_regex('/nasDicom/spm_raw/PROTO_SL_TOURETTE/',sujname);
ana_orig = get_subdir_regex_one(ana_orig,anadir)

ff=get_subdir_regex_files(ana_orig,'^s.*hdr')
r_movefile(ff,nana,'copy');
ff=get_subdir_regex_files(ana_orig,'^s.*img')
aa=r_movefile(ff,nana,'link');

%extract B0 unwrap TO coregister T1 on DTI
dn = get_subdir_regex('/servernas/images/yulia/DTI_fsl','.*','DTI')
ff = get_subdir_regex_files(dn,'unwar');
ff = do_fsl_roi(ff,'Bo_unwrap')

%ff = get_subdir_regex_files(dn,'Bo_unwrap');
ff = unzip_volume(ff);

par.interp=1; par.type = 'estimate_and_write';par.prefix = 'r';
job = job_coregister(fana,ff,bmask,par); spm_jobman('run',job)

spm_jobman('interactive',job)
spm_jobman('run',job)

%do the vbm8 segmentation
ana = get_subdir_regex('/servernas/images/yulia/DTI_fsl','.*','anat');
aa = get_subdir_regex_files(ana,'^s.*img$')
job = job_vbm8(aa);
%job = job_vbm8_write_field(aa)
%spm_jobman('run',job)



%extract brodman region
label = {[11 25 24 32 47],[8 9 10 23 46 44 45],[6],[2 3 4],[38 36 34 28],[20 19],[5 7],[48]};
roiname = {'F_limb','F_asso','Premot','SM','T_limb','T_asso','P_asso','Insula'};

roibrodman = '/home/yulia/data/DTI_fsl/roi_brodmann';
v_brodmaan = {'/home/romain/www/brodmann.nii'};

write_multiple_mask(v_brodmaan,label,roiname,roibrodman,'image_calc');
 

%denormalize
fb = get_subdir_regex_files(roibrodman,'.*')
suj = get_subdir_regex('/servernas/images/yulia/DTI_fsl','oure');
sn = r_mkdir(suj,'roi_brodmaan');
snn= r_movefile(fb{1},sn,'link');

snn = get_subdir_regex(suj,'roi_brod')
aainv =  get_subdir_regex_files(ana,'^iy_rs.*nii$');
bmask =  get_subdir_regex_files(snn,'^[FIPST].*nii$',9);

job = job_vbm8_create_wraped(aainv,bmask);
spm_jobman('run',job)

%normalize FA and MD
ana = get_subdir_regex('/servernas/images/yulia/DTI_fsl','oure','anat');
dti = get_subdir_regex('/servernas/images/yulia/DTI_fsl','oure','DTI');
aadir =  get_subdir_regex_files(ana,'^y_rs.*nii$');
FAS = get_subdir_regex_files(dti,{'FA','MD'});
FAS = unzip_volume(FAS);

par.interp=1;
job = job_vbm8_create_wraped(aadir,FAS,par);
spm_jobman('run',job)

%to normalize roi mask
%ff=get_subdir_regex_files(sn,'^[cpt].*')


%GET freesurfer segmentation

ana = get_subdir_regex('/servernas/images/yulia/DTI_fsl','.*','anat');
ana=ana(1:20)
aa = get_subdir_regex_files(ana,'^s.*img$')
 s = get_parent_path(ana);
[rr,sujname] = get_parent_path(s);

freesuj = get_subdir_regex('/servernas/images/yulia/freesurfer',sujname,'mri');
volfree = get_subdir_regex_files(freesuj,{'T1.mgz','aparc.aseg.mgz','aparc.a2005s.aseg.mgz'})

volfreen= r_movefile(volfree,ana,'link');

%volfreen= get_subdir_regex_files(ana,{'T1.mgz','aseg.mgz'});
%a executer sur machine 64 bit
ff=convert_mgz2nii(volfreen);

%coreg free T1 to T1
fT1 = get_subdir_regex_files(ana,'^T1.nii');
fseg = get_subdir_regex_files(ana,'aseg.nii');


job='';
for k=1:length(aa)
  job =  do_coregister(fT1{k},aa{k},fseg{k},'',job);
end
spm_jobman('run',job)

%Do again for the aparc.a2005
ana = get_subdir_regex('/servernas/images/yulia/DTI_fsl','.*','anat');
ana=ana(13:20)

volfree = get_subdir_regex_files(freesuj,{'aparc.a2005s.aseg.mgz'})
 freen= get_subdir_regex_files(ana,{'T1.nii'})
%this is only becaus apar.a2005 was copy after the T1 coreg on the s.*img
for k=1:length(ff)
  hdr_copy_nifti_header(ff{k},freen{k})
end




%get the subject that have no DIT 
d = get_subdir_regex('/servernas/images/yulia/tourette','ourett','t1mpr');
s = get_parent_path(d);
[rr,sujname] = get_parent_path(s);

do={};
for k=1:length(d)
  if isempty(get_subdir_regex('/home/yulia/data/DTI_fsl',sujname{k}))
    do(end+1) = d(k)
  end
end

[s,anadir] = get_parent_path(do); 
[rr,sujname] = get_parent_path(s);



%Get the linda mask
[a,b,c]=xlsread('readMe.xls')
suj = get_subdir_regex('/servernas/images/yulia/DTI_fsl','^20.*');

[p sujname] = get_parent_path(suj)
sn = r_mkdir(suj,'roi_New_stri');
for k=1:length(suj)
  ksuj=0;
  for kk=1:size(b,1)
    if findstr(sujname{k},b{kk})
      ksuj =kk;
      break
    end
  end
  if ksuj==0
    k
  else
    num_suj = b{ksuj,2}(6:end);
    ff=get_subdir_regex_files('/home/yulia/data/Tourette_linda_2010/convertedData',['_' num_suj '.nii$']);
%    ff=get_subdir_regex_files('/home/yulia/data/Tourette_linda_2010/convertedData',['pallidumG_' num_suj '\.nii$'],1);
    if isempty(ff)
      k
    end
    dn = r_movefile(ff,sn{k},'copy')
  end
end

%ff=get_subdir_regex_files(sn,'^pallidumG.*');
%write_multiple_mask(ff,{1003},{'pallidumGa'},sn,'image_calc');

%
snew=get_subdir_regex_one('/home/yulia/data/tourette',sujname);t1=get_subdir_regex(snew, 't1mpr');
t1f=get_subdir_regex_files(t1,'^s[S0].*img$',1);
for k=1:length(t1f)
  v1 = spm_vol(t1f{k});  v2 = spm_vol(deblank(ff{k}));
  if any(any((v1.mat-v2.mat)>1e-3)) ,    fprintf(' %s mask %s\n',t1f{k},ff{k});  end
end

fana=get_subdir_regex_files(ana,'^s.*img',1)
ff=get_subdir_regex_files(dstri,'^[cpt]')
hdr_copy_nifti_header(ff,fana)


%write_transformation T1 DTI
    
snn = get_subdir_regex(suj,'roi_brod');


ff = get_subdir_regex_files(dn,'eddycor_unwar');

for k=1:length(snn)

  T12DTI_transfo = fullfile(snn{k},'T12DT1_transfo.txt');
  mask_T1 = fullfile(snn{k},'wInsula_et_r_Left_cortex.nii');

    if ~exist(T12DTI_transfo)
       cmd = sprintf('flirt -applyxfm -usesqform -in %s -ref %s -omat %s',mask_T1,ff{1},T12DTI_transfo);
      unix(cmd);
   end
end

%PROBTRAK
suj = get_subdir_regex('/servernas/images/yulia/DTI_fsl','^20.*');  
%suj(3) has no yeb
suj(3)=[];suj(23)=[];

snn = get_subdir_regex(suj,'roi_stri');
sny = get_subdir_regex(suj,'roi_yeb');

suj=get_parent_path(snn);
dti = get_subdir_regex(suj,'DTI');

%
%bmloop = { 'THANT_SR.*img','THPF_SR.*img','THRPT_SL.*img','THVA_SL.*img','THVA_SR.*img','THVL_SR.*img','THVL_SL.*img','THVPE_SR.*img','THVPI_SR.*img'};
%bmnameloop = { 'THANT_SR','THPF_SR','THRPT_SL','THVA_SL','THVA_SR','THVL_SR','THVL_SL','THVPE_SR','THVPI_SR'};
bmloop = { 'THANT_SR.*img','THPF_SR.*img','THVA_SR.*img','THVL_SR.*img','THVPE_SR.*img','THVPI_SR.*img'};
bmnameloop = { 'THANT_SR','THPF_SR','THVA_SR','THVL_SR','THVPE_SR','THVPI_SR'};
bmloop = { 'THCM_SR.*img'};
bmnameloop = { 'THCM_SR'};
bmloop = { 'THPF_SR.*img'};
bmnameloop = { 'THPF_SR'};

for k=21:length(snn)
for k=1:20 %length(snn)

  T12DTI_transfo = fullfile(snn{k},'T12DT1_transfo.txt');
  
  if ~exist(T12DTI_transfo),    ff=get_subdir_regex_files(dti(k),'4D.*unw');    cmd = sprintf('flirt -applyxfm -usesqform -in %s -ref %s -omat %s',bm1{1},ff{1},T12DTI_transfo);    unix(cmd);  end
  
  %  bm1 = get_subdir_regex_files(snn{k},'^pallidumD');  bm2 =  get_subdir_regex_files(snn{k},'^thalamusD');
  bm2 = get_subdir_regex_files(snn{k},'^pallidumD');  
  
  bex = get_subdir_regex_files(snn{k},'^rT1_Exc');

  trackdir = get_subdir_regex(dti{k},{'bedpostdir\.bedpostX'})
  par.termination = char(bm2);  par.sge=1;par.type = 'waypoint';  
  par.xfm = char(T12DTI_transfo);   par.exclusion = bex{1};

  for nbm=1:length(bmloop)
    outdir1 = fullfile(dti{k},sprintf('Seed_%s_palD_wp_Ex',bmnameloop{nbm}));
    bm1 = get_subdir_regex_files(sny{k},bmloop(nbm),1);
    process_probtrack(bm1,bm2,outdir1,trackdir,par)
  end

end

for k=1:10 %length(snn)

  T12DTI_transfo = fullfile(snn{k},'T12DT1_transfo.txt');
  
  bm1 = get_subdir_regex_files(snn{k},'^pallidumD');
  bm2 = get_subdir_regex_files(snn{k},'^thalamusD');
 
  trackdir = get_subdir_regex(dti{k},{'bedpostdir\.bedpostX'})

  T12DTI_transfo = fullfile(snn{k},'T12DT1_transfo.txt');
  if ~exist(T12DTI_transfo)
    ff=get_subdir_regex_files(dti(k),'4D.*unw')
    cmd = sprintf('flirt -applyxfm -usesqform -in %s -ref %s -omat %s',bm1{1},ff{1},T12DTI_transfo);
    unix(cmd);
  end
     
  outdir1 = fullfile(dti{k},'Seed_palD_wp_thalD');

  clear par; par.termination = char(bm2);  par.sge=1;par.type = 'waypoint';  par.xfm = char(T12DTI_transfo);

  process_probtrack(bm1,bm2,outdir1,trackdir,par)

  outdir1 = fullfile(dti{k},'Seed_pallD_cla_thalD'); 
  clear par; par.type = 'classification';par.xfm = char(T12DTI_transfo);

  process_probtrack(bm1,bm2,outdir1,trackdir,par)

  bm1 = get_subdir_regex_files(snn{k},'^pallidumG');
  bm2 = get_subdir_regex_files(snn{k},'^thalamusG');
  
  
  outdir1 = fullfile(dti{k},'Seed_palG_wp_thalG');

  clear par; par.termination = char(bm2);  par.sge=1;par.type = 'waypoint';  par.xfm = char(T12DTI_transfo);

  process_probtrack(bm1,bm2,outdir1,trackdir,par)

  outdir1 = fullfile(dti{k},'Seed_pallG_cla_thalG'); 
  clear par; par.type = 'classification';par.xfm = char(T12DTI_transfo);

  process_probtrack(bm1,bm2,outdir1,trackdir,par)


end


fe=get_subdir_regex_files(sn,'^wExcl',1);r_movefile(fe,snn,'link')

fc = get_subdir_regex_files(snn,{'^caude','^putamen','^wExcl'},5);

for k=2:length(fc)
 combine_mask(cellstr(char(fc(k))),'|',1,'rT1_Exclusion_mask_all.nii')
end


%Pour les noyea SARIC EGP IGP  eroSTRPU eroSTRCD 

suj = get_subdir_regex('/servernas/images/yulia/DTI_fsl','oure');
%remove sujet06p no yeb
suj(3)='';

ana = get_subdir_regex(suj,'anat');
dti = get_subdir_regex(suj,'DTI_fsl');

[p,sujname]=get_parent_path(suj)
sujyeb = get_subdir_regex_one('/home/yulia/data/tourette/SARIC/EXPERIENCES',sujname);
roiyeb = get_subdir_regex(sujyeb,'t1pr','MR_Geometry','ROIs_espace_natif_T1');

ff = get_subdir_regex_files(roiyeb,{'^EGP','^IGP','^eroSTRPU','^eroSTRCD'},64);
ff = get_subdir_regex_files(roiyeb,{'^SN','^STN','^TH'},72);

sn = r_mkdir(suj,'roi_yeb');

r_movefile(ff,sn,'copy');
ff=get_subdir_regex_files(sn,'.*img.gz');
unzip_volume(ff)


fana=get_subdir_regex_files(ana,'^s.*img',1)
ff=get_subdir_regex_files(sn,{'^SN.*img$','^STN.*img$','^TH.*img$'},36)
hdr_copy_nifti_header(ff,fana)

fFA = get_subdir_regex_files(dti,'^S.*FA.nii$')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% Extract FA in roi%%%%%%%%%%%%%%%%%%
%faire lambda et MD ... GFA ?
%nombre de connection pallidum thalamus
%faire le tracking a partir des sous noyeau du Th   THANT_SR  THPF_SR THRPT_SL THVA_SL THVA_SR THVL_SR SL  THVPE_SR  THVPI_SR

%essaye seed, THPF THVPE no mask pour voir ou ca passe
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
par.field_prefix='Lr_';
cc=scale_conc(c,par); 
write_conc_res_summary_stat(cc,'toton.csv')
write_conc_res_to_csv(cc,'toton.csv')
