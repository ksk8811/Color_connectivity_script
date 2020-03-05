%for all subject
suj=get_subdir_regex({'/home/sabine/data_img/data_momic/Controles','/home/sabine/data_img/data_momic/Patients/MM_Patients'},'^[CP]','^20');
ana = get_subdir_regex(suj,'t1mpr')

dti = get_subdir_regex(suj,'DTI$');
dti = get_subdir_regex(suj,'Diff_ok$');

ff = get_subdir_regex_files(dti,'eddycor_unwar',1);
aa = get_subdir_regex_files(ana,'^s.*img$',1);

%mv DTI dir in a new root_dir
%extract B0 unwrap TO coregister T1 on DTI

do_fsl_roi(ff,'Bounwarp1',0,1)
do_fsl_roi(ff,'Bounwarp2',20,1)
do_fsl_roi(ff,'Bounwarp3',41,1)
fb = get_subdir_regex_files(dti,'Boun');
of=addsufixtofilenames(dti,'/Bo_unwarp')
do_fsl_mean(fb,of)

ff = get_subdir_regex_files(dti,'Bo_unwarp');
ff = unzip_volume(ff);

fother=get_subdir_regex_files(anac,{'T1.nii','^a.*nii$'},3)

job =  job_coregister(aa,ff,fother);

spm_jobman('interactive',job)
spm_jobman('run',job)

%do the vbm8 segmentation
job = job_vbm8(aa);
spm_jobman('run',job)
 

%extract brodman region
label = {4,6,48};
roiname = {'Mot','preMot','Insula'};
label = {23,24,25,26,27,27};
roiname = {'Aterior_corona_radiataR','Aterior_corona_radiataL','Superior_corona_radiataR','Superior_corona_radiataL','Posterior_corona_radiataR','Posterior_corona_radiataL'};

roibrodman = '/home/sabine/data_img/data_momic/Patients/MM_Patients/broadman_roi';
v_brodmaan = {'/home/romain/www/brodmann.nii'};
%only one time
%write_multiple_mask(v_brodmaan,label,roiname,roibrodman,'image_calc');
 

%denormalize
fb = get_subdir_regex_files(roibrodman,'.*')
suj = get_parent_path(ana);

sn = r_mkdir(suj,'roi_brodmaan');
snn= r_movefile(fb{1},sn,'link');

snn = get_subdir_regex(suj,'roi_brod')
aainv =  get_subdir_regex_files(ana,'^iy_rs.*nii$');
bmask =  get_subdir_regex_files(snn,'^[IMp].*nii$');

par.interp=1;
job = job_vbm8_create_wraped(aainv,bmask,par);
spm_jobman('run',job)

%denormalize exclusion mask
em = get_subdir_regex_files('/home/sabine/data_momic/Patients/MM_Patients/broadman_roi/exclusion_mask','^Ex');
em = get_subdir_regex_files('/home/sabine/data_momic/Patients/MM_Patients/broadman_roi/white_mater','corona');

snn= r_movefile(em{1},sn,'link');
Bex = get_subdir_regex_files(sn,'corona.*nii$',6)
par.interp=0;
job = job_vbm8_create_wraped(aainv,Bex,par);
spm_jobman('run',job)

return

%normalize FA and MD
%ana = 
%dti = 
aadir =  get_subdir_regex_files(ana,'^y_rs.*nii$');
FAS = get_subdir_regex_files(dti,{'FA.nii','MD'});
FAS = unzip_volume(FAS);
FAS = get_subdir_regex_files(dti,{'FA.nii','MD'});

par.interp=1;
job = job_vbm8_create_wraped(aadir,FAS,par);
spm_jobman('run',job)

%smooth the normalized FA and MD (with default value s m)
FAS = get_subdir_regex_files(dti,{'^w.*FA.nii','^w.*MD'});
job=job_smooth(FAS);
spm_jobman('run',job)

%add L2 and L3
FAS = get_subdir_regex_files(dti,{'^w.*L3','^w.*L2'});

for k=1:length(FAS)
  job = job_image_calc(FAS(k),'Lrad.nii','(i1+i2)*50',1,16,dti{k});
  spm_jobman('run',job)

end


%GET freesurfer segmentation
 suj=get_subdir_regex({'/home/sabine/data_img/data_momic/Controles','/home/sabine/data_img/data_momic/Patients/MM_Patients'},'^[nCP]','^20');
 %pour recuperer les sujet qui n'ont pas de sous repertoir 'anat_free'
[s,suj] = get_subdir_regex(suj,'anat_free')

 
ana = get_subdir_regex(suj,'t1mpr');
aa = get_subdir_regex_files(ana,'^s.*img$')

if 0 %pour faire tourner freesurfer
  par.version = 4;
  par.free_sujdir ='/home/sabine/data_momic/freesurfer'
  par.distrib.subdir = 'distrib';                      
  par.free_cmd = 'freesurfer';                         
  do_freesurfer(aa,par)
end


%suj = get_parent_path(ana);
[rr,sujname] = get_parent_path(suj);


freesuj = get_subdir_regex_one('/home/sabine/data_img/data_momic//freesurfer/',sujname,'mri');
volfree = get_subdir_regex_files(freesuj,{'T1.mgz','^aseg.mgz','aparc.a2005s.aseg.mgz'},3)
%volfree = get_subdir_regex_files(freesuj,{'aparc.a2005s.aseg.mgz'})

ana_free = r_mkdir(suj,'anat_free');

volfreen= r_movefile(volfree,ana_free,'link');

%volfreen= get_subdir_regex_files(ana_free,{'T1.mgz','aseg.mgz'});
%a executer sur machine 64 bit
ff=convert_mgz2nii(volfreen);

%coregister with original T1
 ff=get_subdir_regex_files(ana_free,'T1.nii')
 ffo=get_subdir_regex_files(ana_free,'aseg.nii')
  job='';
for k=1:length(aa)
  job =  do_coregister(ff{k},aa{k},ffo{k},'',job);
end
spm_jobman('run',job)

%when the coregister is already done, just copy the T1.nii hdr

freen= get_subdir_regex_files(ana_free,{'T1.nii'})
ff= get_subdir_regex_files(ana_free,{'aparc.a2005s.aseg.nii'})
%this is only becaus apar.a2005 was copy after the T1 coreg on the s.*img
for k=1:length(ff)
  hdr_copy_nifti_header(ff{k},freen{k})
end


%extract gray left and rigth region
ana_free = get_subdir_regex(suj,'anat_free')

label = {3,42,12,51};
label = {1125 1126 1145 2125 2126 2145 };roiname = find_free_label_name(label);

roiname = {'Left_cortex','Right_cortex','Left_putamen','Right_putamen'};

volfree = get_subdir_regex_files(ana_free,'^aseg.nii');

write_multiple_mask(volfree,label,roiname,ana_free,'image_calc',aa)         

%essayer le 1126    ctx-lh-G_precentral

%intercept with broadman denorm
snn = get_subdir_regex(suj,'roi_brod');
bmask =  get_subdir_regex_files(snn,'^w.*[ta].nii$');
volfreeL = get_subdir_regex_files(ana_free,{'Left_co'})
volfreeR = get_subdir_regex_files(ana_free,{'Right_co'})
for kk=1:length(volfree)
    for jj=1:size(bmask{kk},1)
      combine_mask({deblank(bmask{kk}(jj,:)),volfreeL{kk}},'&',1);
combine_mask({deblank(bmask{kk}(jj,:)),volfreeR{kk}},'&',1);
    end
end

%reslice them to dti
fB0 = get_subdir_regex_files(dti,'Bo_unwarp');

bmask =  get_subdir_regex_files(snn,{'^wExclu.*nii','^w.*cortex.nii'},8);
Bex = get_subdir_regex_files(sn,'^wSuperior_corona.*nii$',2)

par.interp=1; par.type = 'write';par.prefix = 'rDTI_';

job = job_coregister(bmask,fB0,'',par); 
spm_jobman('run',job)


%write_transformation T1 DTI
    
snn = get_subdir_regex(suj,'roi_brod');

ff = get_subdir_regex_files(dti,'eddycor_unwar');

for k=1:length(snn)

  T12DTI_transfo = fullfile(snn{k},'T12DT1_transfo.txt');
  mask_T1 = fullfile(snn{k},'wInsula_et_r_Left_cortex.nii');

    if ~exist(T12DTI_transfo)
       cmd = sprintf('flirt -applyxfm -usesqform -in %s -ref %s -omat %s',mask_T1,ff{1},T12DTI_transfo);
      unix(cmd);
   end
end
%%%%%%%%%%%%%%fsl process dti B100 tronc
d=get_subdir_regex('/nasDicom/spm_raw/PROTO_MOMIC/',{'-Pilote','-romain','-Test','.*'},'b1000.*AP$');
suj=get_parent_path(d);
[p,sujname] = get_parent_path(suj);
sujd = get_subdir_regex('/nasDicom/dicom_raw/PROTO_MOMIC/',sujname)
bval_f = get_subdir_regex_files(sujd, 'b1000.*bvals$',1);
bvec_f = get_subdir_regex_files(sujd, 'b1000.*bvecs$',1);

dti_files = get_subdir_regex_files(d,'.*img$')

ff=addprefixtofilenames(sujname,'/home/sabine/data_momic/DTI_tronc/'); new_dti_dir=addsufixtofilenames(ff,'/DTI_tronc')
par.do_merge=1;  par.do_bet=1; par.do_eddcor=1; par.sge=1;

for nbsuj=1:length(suj)
  process_dti(dti_files(nbsuj),bval_f(nbsuj),bvec_f(nbsuj),new_dti_dir{nbsuj},sujname(nbsuj),par);
end

 par.data_to_unwarp='4D_eddycor';
 par.do_unwrap=1                 

 for nbsuj=1:length(dic)
   ser_FM=get_subdir_regex(dic(nbsuj),'_MAPPING');
   mag =  get_subdir_regex_files(ser_FM{1},'^s.*01\.img',1);
   phase = get_subdir_regex_files(ser_FM{2},'^s.*img',1);

   par.inmag = char(mag);      par.inphase = char(phase);
   par.tediff = 2.46;      par.esp = 0.52;      par.unwarp_outvol = '4D_eddycor_unwarp';
   par.unwarpdir = 'y'; %Use x, y, z, x-, y- or z- only.

   process_dti('','','',dti{nbsuj},sujnames{nbsuj},par);
 end

%after a r_move
dti = get_subdir_regex({'/home/sabine/data_img/data_momic/Controles','/home/sabine/data_img/data_momic/Patients/MM_Patients'},'^[CP]','^20','DTI_tronc');
 suj=get_parent_path(dti);[pp sujname] = get_parent_path(suj);

%%%%%%%%%%%redoo DTI unwarp
suj=get_subdir_regex({'/home/sabine/data_img/data_momic/Controles','/home/sabine/data_img/data_momic/Patients/MM_Patients'},'^[CP]','^20');
dti = get_subdir_regex(suj,'Diff_ok');%dti = get_subdir_regex(suj,'DTI$');

%ff = get_subdir_regex_files(dti,{'4D_eddycor.nii.gz','4D_eddycor.ecc','bv..s$','nodif'},5);ndti = r_mkdir(suj,'Diff_ok');r_movefile(ff,ndti,'copy')

[pp,sujname]=get_parent_path(suj)                             
[pp,csujname]=get_parent_path(pp) 
%%%Erreur fatal et tous les nom se melange je remplace     aa = get_subdir_regex('/nasDicom/spm_raw/PROTO_MOMIC',sujname)
for k=1:length(suj)
  aa(k)= get_subdir_regex('/nasDicom/spm_raw/PROTO_MOMIC',sujname(k))
end

reg_gre_dir = {'GRE','mapping'};
par.sge=1;par.queu = 'server_ondule';par.data_to_fit = '4D_eddycor_unwarp';par.data_to_unwarp = '4D_eddycor';
par.do_unwrap=1; par.do_fit=1;

for ns=1:length(suj)
  ser_FM=get_subdir_regex(aa(ns),reg_gre_dir);
  mag =  get_subdir_regex_files(ser_FM{1},'^s.*01\.img',1);
  phase = get_subdir_regex_files(ser_FM{2},'^s.*img',1);

  par.inmag = char(mag);      par.inphase = char(phase);
  par.tediff = 2.46;      par.esp = 0.355*2;      %j'en profite pour booste un peu 0.355*2
  par.unwarp_outvol = '4D_eddycor_unwarp';
  par.unwarpdir = 'y'; %Use x, y, z, x-, y- or z- only.
  char(par.inmag)
  char(suj(ns))
  process_dti('','','',dti{ns},csujname{ns},par);

end

%redoo bedpostx for some subjects   ss=suj([8 9 18]);  dti = get_subdir_regex(ss,'DTI$'); (but for all in 07/2012
ppar.do_bedpost = 1;ppar.data_to_fit = '4D_eddycor_unwarp';
for k=18:length(dti)
  process_dti('','','',dti{k},sujname{k},ppar);
end

%do new subject process dti
suj=get_subdir_regex({'/home/sabine/data_img/data_momic/Controles','/home/sabine/data_img/data_momic/Patients/MM_Patients'},'graphically','^20');

reg_dti_dir = 'b1500_o.._1_7.*iso$';
reg_bvals = 'b1500_o';
reg_gre_dir = 'GRE';

ndti = r_mkdir(suj,'Diff_ok');
[pp,sujname]=get_parent_path(suj)                             
[pp,csujname]=get_parent_path(pp) 

par.do_merge=1;  par.do_bet=1; par.do_eddcor=1; 
par.sge=1;par.queu = 'server_ondule';par.data_to_fit = '4D_eddycor_unwarp';par.data_to_unwarp = '4D_eddycor';
par.correct_bvec=1; par.do_unwrap=1; par.do_fit=1;

for nbsuj=1:length(suj)

  sujdir = suj{nbsuj}
  dti_dirs = get_subdir_regex(sujdir,reg_dti_dir);

  dti_files = get_subdir_regex_files(dti_dirs,'.*img$')  bval_f = get_subdir_regex_files(sujdir,[reg_bvals '.*bvals$'],3);
  bvec_f = get_subdir_regex_files(sujdir,[reg_bvals '.*bvecs$'],3);

  ser_FM=get_subdir_regex(suj(nbsuj),reg_gre_dir);
  mag =  get_subdir_regex_files(ser_FM{1},'^s.*01\.img',1);
  phase = get_subdir_regex_files(ser_FM{2},'^s.*img',1);

  par.inmag = char(mag);      par.inphase = char(phase);
  par.tediff = 2.46;      par.esp = 0.355;      par.unwarp_outvol = '4D_eddycor_unwarp';
  par.unwarpdir = 'y'; %Use x, y, z, x-, y- or z- only.
  process_dti(dti_files,bval_f,bvec_f,ndti{nbsuj},csujname{nbsuj},par);


end

%PROBTRAK
snn = get_subdir_regex(suj,'roi_brod');
dti = get_subdir_regex(suj,'DTI$');

%on the DTI space

for k=1:length(snn)
  
  bm1 = get_subdir_regex_files(snn{k},'^rDTI_wMot_et_r_Right',1);
  bm2 = get_subdir_regex_files(snn{k},'^rDTI_wMot_et_r_Left',1);

  trackdir = get_subdir_regex(dti{k},{'bedpostdir\.bedpostX'})
  par.sge=1;

  b_ex =  get_subdir_regex_files(snn{k},'rDTI_wExclusion_inter_hemi_tronc',1)
  par.exclusion = b_ex{1};
  
  par.delete_if_exist = 0;
  par.modeuler=1;
  
  if 0
    outdir1 = fullfile(dti{k},'Seed_MotL_cla_MotR'); 
    par.type = 'classification';
    process_probtrack(bm2,bm1,outdir1,trackdir,par)

    outdir1 = fullfile(dti{k},'Seed_MotR_cla_MotL'); 
    par.type = 'classification';
    process_probtrack(bm1,bm2,outdir1,trackdir,par)

    par.type = 'multiplemask';
    par.length=1;

    outdir1 = fullfile(dti{k},'Multiple_MotR_L_ex_hemiTronc_LENGTH')
    process_probtrack('toto',[bm1,bm2],outdir1,trackdir,par)

    par.length=0
    outdir1 = fullfile(dti{k},'Multiple_MotR_L_ex_hemiTronc')
    process_probtrack('toto',[bm1,bm2],outdir1,trackdir,par)

  else
    par.length=0;
    par.termination = char(bm2); par.type = 'waypoint';
    outdir1 = fullfile(dti{k},'Seed_MotR_wp_MotL_me');
    process_probtrack(bm1,bm2,outdir1,trackdir,par)

%    par.length=1;    outdir1 = fullfile(dti{k},'Seed_MotR_wp_MotL_me_LENGTH');    process_probtrack(bm1,bm2,outdir1,trackdir,par)

    par.length=0;
    par.termination = char(bm1); par.type = 'waypoint';
    outdir1 = fullfile(dti{k},'Seed_MotL_wp_MotR_me');
    process_probtrack(bm2,bm1,outdir1,trackdir,par)

%    par.length=1;   outdir1 = fullfile(dti{k},'Seed_MotL_wp_MotR_me_LENGTH');    process_probtrack(bm2,bm1,outdir1,trackdir,par)

    clear par
  end

end

%again for preMot
dti = get_subdir_regex(suj,'Diff_ok');
rdir=get_subdir_regex(dti,'MaskTrafique')
[dti,q]=get_parent_path(rdir);[suj,q]=get_parent_path(dti);ccdir=get_subdir_regex(suj,'CC');

for k=1:length(rdir)
  trackdir = get_subdir_regex(dti{k},{'bedpostdir\.bedpostX'});
  par.sge=1;  par.type =  'classification';
  outdir1 = fullfile(dti{k},'CC_ALL38');
  bm1 = get_subdir_regex_files(ccdir(k),'^rfsl',1);
  %bm2=get_subdir_regex_files(rdir(k),{'rh.*Mot','rh.*_mask','rh.*post','rh.*S_cen'},4);
  bm2=get_subdir_regex_files(rdir(k),'^rDTI',22)
  bm22=get_subdir_regex_files(ccdir(k),'rDTI_wMNI',16);
  bm2 = concat_cell(bm2,bm22);
  
  process_probtrack(bm1,bm2,outdir1,trackdir,par);
end


snn = get_subdir_regex(suj,'roi_brodmaan');
snn2 = get_subdir_regex(suj,'anat_free');
dti = get_subdir_regex(suj,'DTI$');

for k=1:length(snn)
  
%  bm1 = get_subdir_regex_files(snn{k},'^rDTI_wpreMot_et_r_Right',1);
%  bm2 = get_subdir_regex_files(snn{k},'^rDTI_wpreMot_et_r_Left',1);

  trackdir = get_subdir_regex(dti{k},{'bedpostdir\.bedpostX'})

  b_ex =  get_subdir_regex_files(snn{k},'rDTI_wExclusion_inter_hemi_tronc',1)
  par.exclusion = b_ex{1};
  par.sge=1;  par.type = 'multiplemask';  par.length=0;

  outdir1 = fullfile(dti{k},'Multiple_preMotR_L_ex_hemiTronc');
  %process_probtrack('toto',[bm1,bm2],outdir1,trackdir,par)

  bm2 = get_subdir_regex_files(snn2{k},'rDTI_r_ctx-[lr]h-S_central',2);
  outdir1 = fullfile(dti{k},'Multiple_Scentral');
  process_probtrack('toto',bm2,outdir1,trackdir,par)
 
  bm2 = get_subdir_regex_files(snn2{k},'rDTI_r_ctx-[lr]h-G_postcentral',2);
  outdir1 = fullfile(dti{k},'Multiple_postcentral');
  process_probtrack('toto',bm2,outdir1,trackdir,par)
  
  bm2 = get_subdir_regex_files(snn2{k},'rDTI_r_ctx-[lr]h-G_precentral.nii',2);
  outdir1 = fullfile(dti{k},'Multiple_precentral');
  process_probtrack('toto',bm2,outdir1,trackdir,par)
  

  bm1 = get_subdir_regex_files(snn2{k},'^rDTI_r_ctx-rh-.*central',3);
  bm2 = get_subdir_regex_files(snn2{k},'^rDTI_r_ctx-lh-.*central',3);
  bm1 = cellstr(char(bm1));   bm2=cellstr(char(bm2));

  par.modeuler=1;    par.type = 'classification';

  outdir1 = fullfile(dti{k},'cla_G_postcentral_R2Lcentral');
  process_probtrack(bm1(1),bm2,outdir1,trackdir,par);
  outdir1 = fullfile(dti{k},'cla_G_precentral_R2Lcentral');
  process_probtrack(bm1(2),bm2,outdir1,trackdir,par);
  outdir1 = fullfile(dti{k},'cla_S_central_R2Lcentral');
  process_probtrack(bm1(3),bm2,outdir1,trackdir,par);

  outdir1 = fullfile(dti{k},'cla_G_postcentral_L2Rcentral');
  process_probtrack(bm2(1),bm1,outdir1,trackdir,par);
  outdir1 = fullfile(dti{k},'cla_G_precentral_L2Rcentral');
  process_probtrack(bm2(2),bm1,outdir1,trackdir,par);
  outdir1 = fullfile(dti{k},'cla_S_central_L2Rcentral');
  process_probtrack(bm2(3),bm1,outdir1,trackdir,par);

  clear par;

end



for k=1:length(snn)
  
%  bm1 = get_subdir_regex_files(snn{k},'^rDTI_wpreMot_et_r_Right',1);
%  bm2 = get_subdir_regex_files(snn{k},'^rDTI_wpreMot_et_r_Left',1);

  trackdir = get_subdir_regex(dti{k},{'bedpostdir\.bedpostX'})

  b_ex =  get_subdir_regex_files(snn{k},'rDTI_wExclusion_inter_hemi_tronc',1)
  par.exclusion = b_ex{1};
  par.sge=1;  par.type = 'multiplemask';  par.length=0;

  bm2 =  get_subdir_regex_files({snn2{k},snn{k}},{'rDTI_r_ctx-[lr]h-S_central','^rDTI_wSuperior_corona_radiata'});  bm2=cellstr(char(bm2));
  outdir1 = fullfile(dti{k},'Multiple_Scentral_Sup_corona_radiata');
  process_probtrack('toto',bm2,outdir1,trackdir,par)

end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% EXTRACT THE STATS %%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
group = {'/home/sabine/data_img/data_momic/Controles','/home/sabine/data_img/data_momic/Patients/MM_Patients'};

for nbgroup = 1:length(group)
  suj = get_subdir_regex(group{nbgroup},'^[CP]','^20');

  [pp,sujname] = get_parent_path(suj);  [pp,sujname] = get_parent_path(pp);
  [ppp,poolnam] = fileparts(pp{1});
  
  cc.pool = poolnam;
  cc.suj = sujname;  


  dti = get_subdir_regex_one(suj,'DTI$');
  dtiHR = get_subdir_regex_one(dti,'Seed_MotR_cla_MotL');
  dtiHL = get_subdir_regex_one(dti,'Seed_MotL_cla_MotR');

  par.name_prefix ='MorR_'; par.name={'2L'};
  cc =  get_val_from_probtrack(dtiHR,par,cc);

  par.name_prefix ='MorL_'; par.name={'2R'};
  cc =  get_val_from_probtrack(dtiHL,par,cc);

  clear par;
  par.name_prefix = 'cla_Left_postcentral_';
  dtiHL = get_subdir_regex_one(dti,'cla_G_postcentral_L2Rcentral');
  cc =  get_val_from_probtrack(dtiHL,par,cc);

  par.name_prefix = 'cla_Left_precentral_';
  dtiHL = get_subdir_regex_one(dti,'cla_G_precentral_L2Rcentral');
  cc =  get_val_from_probtrack(dtiHL,par,cc);

  par.name_prefix = 'cla_Left_central_';
  dtiHL = get_subdir_regex_one(dti,'cla_S_central_L2Rcentral');
  cc =  get_val_from_probtrack(dtiHL,par,cc);

  par.name_prefix = 'cla_Right_postcentral_';
  dtiHL = get_subdir_regex_one(dti,'cla_G_postcentral_R2Lcentral');
  cc =  get_val_from_probtrack(dtiHL,par,cc);

  par.name_prefix = 'cla_Right_precentral_';
  dtiHL = get_subdir_regex_one(dti,'cla_G_precentral_R2Lcentral');
  cc =  get_val_from_probtrack(dtiHL,par,cc);

  par.name_prefix = 'cla_Right_central_';
  dtiHL = get_subdir_regex_one(dti,'cla_S_central_R2Lcentral');
  cc =  get_val_from_probtrack(dtiHL,par,cc);

  c(nbgroup) = cc;
  clear cc;
end

write_conc_res_summary_stat(c,'toton.csv')
write_conc_res_to_csv(c,'toton.csv')


%normalize the fdt_path
suj = get_subdir_regex(group,'^[CP]','^20');
dtiseed = get_subdir_regex(suj,'DTI$','^Multiple');%dtiseed = get_subdir_regex(suj,'DTI$','^Seed_Mot._wp_Mot');
[p s]=get_parent_path(dtiseed,2) ;
ana = get_subdir_regex(p,'t1mpr');

aadir =  get_subdir_regex_files(ana,'^y_rs.*nii$',1);
fdt_f = get_subdir_regex_files(dtiseed,'^fdt_path.nii',1);
fdt_f = unzip_volume(fdt_f);

par.interp=1;
job = job_vbm8_create_wraped(aadir,fdt_f,par);
spm_jobman('run',job)

%compute the mean FA among the fiber distance
dti = get_subdir_regex_one(suj,'DTI')
%dtiseed = get_subdir_regex_one(dti,'^Seed_MotL_wp_MotR$');dtiseedL = get_subdir_regex_one(dti,'^Seed_MotL_wp_MotR_LENGTH$');
dtiseed = get_subdir_regex(dti,'^Seed_Mot._wp_Mot.$');dtiseedL = get_subdir_regex(dti,'^Seed_Mot._wp_Mot._LENGTH$');
dtiall = get_parent_path(dtiseed)
FA = get_subdir_regex_files(dtiall,'^w[CP].*FA.nii',1)
cwd=pwd;
for kk=1:length(dtiseed)
  cd(dtiseed{kk});
  cmd = sprintf('fslmaths %s -div %s path_dist',fullfile(dtiseedL{kk},'wfdt_paths.nii'),fullfile(dtiseed{kk},'wfdt_paths.nii'));
  unix(cmd);
  
  cmd = sprintf('fslmeants -i %s -o fa.txt -m path_dist.nii.gz --showall',FA{kk});
  unix(cmd);
  
  cmd = sprintf('fslmeants -i path_dist.nii.gz -o dist.txt -m path_dist.nii.gz --showall');
  unix(cmd);
  
end

dtiseed = get_subdir_regex_one(dti,'^Seed_MotL_wp_MotR$');

fpath = get_subdir_regex_files(dtiseed,'wfdt',1);fpatho=addprefixtofilenames(fpath,'normWT_'); 
fwt = get_subdir_regex_files(dtiseed,'waytot');
for k=1:length(fpath)
  waytot = load(fwt{k});
  cmd = sprintf('fslmaths %s -div %d %s',fpath{k},sum(waytot),fpatho{k}); unix(cmd);
end

 
 dtiseed = get_subdir_regex_one(suj,'DTI$','^Seed_MotL_wp_MotR$');
 dtiseed = get_subdir_regex(suj,'DTI$','^Seed_MotR_wp_MotL$');

ff=figure; clear FAsuj fam 
 for kk=[1:length(dtiseed)]
   cd(dtiseed{kk});

   fa= load('fa.txt');fa=fa(4,1:end-1);
   dist =load('dist.txt');dist=dist(4,1:end-1);

   %   figure; hist3([fa;dist]',[50 50])
   %    set(gcf,'renderer','opengl');
   %    set(get(gca,'child'),'FaceColor','interp','CDataMode','auto');
 
   %[a,b]=hist(dist,50); 
   b=linspace(1,100,100);

   for k=1:length(b)-1
     ind = b(k)<=dist & dist<b(k+1);
     fam(k)= mean(fa(ind));  
     fastd(k) = std(fa(ind));
   end

   figure(ff);hold on 
   %   errorbar(b(1:end-1),fam,fastd);
   if kk<11 %Control
     plot(b(1:end-1),fam,'b.')
   else
     plot(b(1:end-1),fam,'r.')
   end
   
   FAsuj(kk,:) = fam;
end

plot(b(1:end-1),mean(FAsuj(1:10,:)),'b','LineWidth',4)
plot(b(1:end-1),mean(FAsuj(11:end,:)),'r','LineWidth',4)




%%<label index="28" x="115" y="99" z="99">Posterior corona radiata L</label>



%copy the segolene CC mask
ds=get_subdir_regex('/home/segolene/data','MOMIC.*'); ds(3) =[];

[pp sujname] = get_parent_path(ds);

for k=1:length(ds)
  ind = findstr(sujname{k},'_');
  nn = sujname{k}(ind(1)+1:ind(2)-1);
  
  dd =  get_subdir_regex({'/home/sabine/data_img/data_momic/Controles','/home/sabine/data_img/data_momic/Patients/MM_Patients'},'^[CP]',['^2.*'  nn]);
  if isempty(dd)
    ind_to_remove(k) = k;
  else
    do(k) = dd;
  end
  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Compute FA on the CC mask along the AP axis

sn = r_mkdir(do,'CCseg')
ff = get_subdir_regex_files(ds,'^[lr].*[gr]$')

ffn = r_movefile(ff,sn,'copy');
sn = get_subdir_regex(suj,'CCseg')
ff=get_subdir_regex_files(sn,'^r.*.img');ffo=get_subdir_regex_files(sn,'_CC.img') 

job = job_coregister(ff,fana,ffo,par); 

aadir =  get_subdir_regex_files(ana,'^y_rs.*nii$');

bmask = get_subdir_regex_files(do,'^rDTI.*img')
par.interp=1;
job = job_vbm8_create_wraped(aadir,bmask,par);

wfa=get_subdir_regex_files(dti,'^w.*FA.nii$');
ff=get_subdir_regex_files(do,'^wl.*img')

for k=1:length(wfa)
  volFA = spm_vol(wfa{k}) ;
  volCC = spm_vol(ff{k});
  
  for nbs =1:volFA.dim(2)
    %get the coronal slices
    slice_CC = spm_slice_vol(volCC,spm_matrix([0 nbs 0  -pi/2 0 0]),volFA.dim([1 3]),0);
    slice_FA = spm_slice_vol(volFA,spm_matrix([0 nbs 0  -pi/2 0 0]),volFA.dim([1 3]),0);
    
    ind_CC = find(slice_CC>0);
    val_FA(k,nbs)    = mean(slice_FA(ind_CC));
    val_FAmed(k,nbs) = median(slice_FA(ind_CC));
    
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Compute FA on the fdt path mask along the Z axis

cspiD= get_subdir_regex(dti,'Seed_MotD_wp_CspiD_me');
cspiL= get_subdir_regex(dti,'Seed_MotL_wp_CspiL_me');

wfa=get_subdir_regex_files(dti,'^w.*FA.nii$',1);

ffdtL=get_subdir_regex_files(cspiD,'^wfdt_path',1); %inversion left and rigth
ffdtD=get_subdir_regex_files(cspiL,'^wfdt_path',1); %inversion left and rigth

for k=1:length(wfa)
  volFA = spm_vol(wfa{k}) ;
  volCCL = spm_vol(ffdtL{k});
  volCCD = spm_vol(ffdtD{k});
  
  for nbs =1:volFA.dim(3)
    %get the coronal slices
    slice_CCL = spm_slice_vol(volCCL,spm_matrix([0 0 nbs ]),volFA.dim([1 2]),0);
    slice_CCD = spm_slice_vol(volCCD,spm_matrix([0 0 nbs ]),volFA.dim([1 2]),0);

    slice_FA = spm_slice_vol(volFA,spm_matrix([0 0 nbs ]),volFA.dim([1 2]),0);
    
    ind_CCD = find(slice_CCD>0);
    ind_CCL = find(slice_CCL>0);
    
    %val_FA(k,nbs)    = mean(slice_FA(ind_CC));
    val_FAwmD(k,nbs) = sum(slice_FA(ind_CCD).*slice_CCD(ind_CCD))./sum(slice_CCD(ind_CCD));
    val_FAwmL(k,nbs) = sum(slice_FA(ind_CCL).*slice_CCL(ind_CCL))./sum(slice_CCL(ind_CCL));
    
  end
end

y1 =  val_FAwmD(1:10,:); y2 =  val_FAwmL(1:10,:);
y1 =  val_FAwmD(11:18,:); y2 =  val_FAwmL(11:18,:);
y1 =  val_FAwmD(1:10,:);y2 =  val_FAwmD(11:18,:);
y1 =  val_FAwmL(1:10,:);y2 =  val_FAwmL(11:18,:);

for kk=1:size(y1,2)

  [h,p]=ttest2(y1(:,kk),y2(:,kk),0.05,'right','unequal');
  if isnan(h),    h=0;end
  if ~h
    [h,p]=ttest2(y1(:,kk),y2(:,kk),0.05,'left','unequal');
  end

  difftest(kk)=h*0.275;%for GFA

end

bb1 = std(y1)./sqrt(size(y1,1));
bb2 = std(y2)./sqrt(size(y2,1));

figure
hold on
plot(mean(y1),'g','linewidth',3)
plot(mean(y2),'r','linewidth',3)
plot(mean(y1)+bb1,'g')
plot(mean(y1)-bb1,'g')

plot(mean(y2),'r','linewidth',3)
plot(mean(y2)-bb2,'r')
plot(mean(y2)+bb2,'r')

plot(difftest,'r*')
ylim([0.25 0.65])
xlim([35 90])
 grid on
 ylabel('mean FA')
 xlabel('z axis in MNI')
legend({'Control','Patient'})
%legend({'Control Rigth CST','Control Left CST'})
%legend({'Patient Rigth CST','Patient Left CST'})

title('mean FA on the left CST along the z axis')
%title('mean FA on the right CST along the z axis')
%title('Patient mean FA on the along the z axis')

set(gcf,'position',[6   506   883   438])


%%for all subject

%stat on CC seed
clear all

group = {'/home/sabine/data_img/data_momic/Controles','/home/sabine/data_img/data_momic/Patients/MM_Patients'}

for nbgroup = 1:length(group)
  suj = get_subdir_regex(group{nbgroup},'^[mCP]','^20');
  %dti_track = get_subdir_regex(suj,'Diff','CC_ALL38');
  dti_track = get_subdir_regex(suj,'Diff','CC_to_foncatlas_px2$');
  dti = get_parent_path(dti_track);  suj = get_parent_path(dti);
  
  [pp,sujname] = get_parent_path(suj,2);
  [ppp,poolnam] = fileparts(pp{1});

  cc.pool = poolnam;  cc.suj = sujname;  
  
  par.wm = get_subdir_regex_files(dti,{'^rfree.*FA','^rfree.*L1','^rfree.*Lrad'},3);  
  par.wm_name={'FA','L1','Lr'};
  par.wm_scale = [1 100 100];
  par.name_prefix = 'CC_'; %  par.name_change = '';% {'M1D_GmRest','M1G_DmRest'};
  
  cc =  get_val_from_probtrack(dti_track,par,cc);
  cc=orderfields(cc);
  c(nbgroup) = cc;
  clear cc;

end

write_conc_res_to_csv(c,'toto.csv')         
write_conc_res_summary_stat(c,'totoS.csv')

%stat on roi volume
clear all

group = {'/home/sabine/data_img/data_momic/Controles','/home/sabine/data_img/data_momic/Patients/MM_Patients'}

for nbgroup = 1:length(group)
  suj = get_subdir_regex(group{nbgroup},'^[mCP]','^20');
  dti_track = get_subdir_regex(suj,'Diff','CC_ALL38');
  %dti_track = get_subdir_regex(suj,'DTI','phieCC$');
  dti = get_parent_path(dti_track);
  suj = get_parent_path(dti);
  roidir =  get_subdir_regex(suj,'Diff','MaskTrafique');
  ccdir =  get_subdir_regex(suj,'CCseg');
  
  ana=get_subdir_regex(dti,'anat');

%  bm2 = get_subdir_regex_files(roidir,'^rDTI',24);
%  bm2 = get_subdir_regex_files(ccdir,'rDTI_wMNI',16);
  bm2 = get_subdir_regex_files(ccdir,'^wMNI',16);
 % bm2 = get_subdir_regex_files(ccdir,'^l.*img',1);
 
  [pp,sujname] = get_parent_path(suj,2);
  [ppp,poolnam] = fileparts(pp{1});

  cc.pool = poolnam;
  cc.suj = sujname;  

  sf=get_subdir_regex_files(ana,'seg8.txt',1);

  for ks=1:length(sf)
    b=load(sf{ks}); %   r(k).gm(ks) = b(1); %   r(k).wm(ks) = b(2); %   r(k).csf(ks) = b(3);
    cc.tot(ks) =sum( b);
  end

if 1
  for nn = 1:size(bm2{1},1)
    [p,f,e] =  fileparts(bm2{1}(nn,:));
    fname=f(1:end-4);
    
    if findstr(f,'_M1D_G-Rest')
      if findstr(f,'sphere5'), fname='rDTI_M1D_G-Rest_sphere5';      else,	fname='rDTI_M1D_G-Rest';      end
    end
    if findstr(f,'_M1G_D-Rest')
      if findstr(f,'sphere5'), fname='rDTI_M1G_D-Rest_sphere5';      else,	fname='rDTI_M1G_D-Rest';      end
    end
    
    %bmm = get_subdir_regex_files(ccdir,f,1);
    %AAAAAAAAAAAARg    bmm = get_subdir_regex_files(roidir,['^' f '.nii'],1)
    clear bmm;
    for ns=1:length(bm2)
      bmm{ns} = deblank(bm2{ns}(nn,:));
    end
    
    vol = do_fsl_getvol(bmm,0.5);    
    fname=nettoie_dir(fname);
    
    cc = setfield(cc,['Vol_', fname],vol(:,2)'./cc.tot);
  end
else
  vol = do_fsl_getvol(bm2)xcysdsdd
  cc = setfield(cc,['Vol_T1_CCseg'],vol(:,2)'./cc.tot); 

end
  c(nbgroup) = cc;
  clear cc;
end

write_res_to_csv(c,'vols05.csv')         

%creation d'une sphere centre sur le local maxima
clear all

group = {'/home/sabine/data_img/data_momic/Controles','/home/sabine/data_img/data_momic/Patients/MM_Patients'}
suj = get_subdir_regex(group,'^[mCP]','^20');
dti_track = get_subdir_regex(suj,'Diff','CC_ALL38');
%dti_track = get_subdir_regex(suj,'DTI','phieCC$');
dti = get_parent_path(dti_track);
suj = get_parent_path(dti);
roidir =  get_subdir_regex(suj,'Diff','MaskTrafique');
ccdir =  get_subdir_regex(suj,'CCseg');

%bm=get_subdir_regex_files(roidir,'^rDTI.*Rest',2)
bm=get_subdir_regex_files(roidir,'^rDTI.*Rest.*[1234567890][1234567890].nii',2);

for kk=1:length(bm)
  [pa,f,e] =  fileparts(bm{kk}(1,:));
  ii=findstr(f,'Rest_');
  indm = f(ii+5:end-4);
  i=findstr(indm,'_');
  ix=str2num(indm(1:i(1)-1));
  iy=str2num(indm(i(1)+1:i(2)-1));
  iz=str2num(indm(i(2)+1:end));
  
  p.radius=10; p.centre=[ix iy iz];
  o=maroi_sphere(p);
  roi = maroi_matrix(o);
  fname=fullfile(pa,[f(ii(1)-6:ii(1)+3),'_sphere10.nii'])

  do_write_image(roi,fname);


end
 
%normalize roi_img and reslice then to dti
ana = get_subdir_regex(suj,'t1mpr');
aadir =  get_subdir_regex_files(ana,'^iy_rs.*nii$',1);
bm=get_subdir_regex_files(roidir,'sphere10',2)

par.interp=1;
job = job_vbm8_create_wraped(aadir,bm,par);
spm_jobman('run',job)

fB0 = get_subdir_regex_files(dti,'Bo_unwarp',1);
par.interp=1; par.type = 'write';par.prefix = 'rDTI_';

bmask=get_subdir_regex_files(roidir,'^w.*sphere10',2);

job = job_coregister(bmask,fB0,'',par); 
spm_jobman('run',job)

%again for preMot
dti = get_subdir_regex(suj,'Diff_ok');
rdir=get_subdir_regex(dti,'MaskTrafique')
[dti,q]=get_parent_path(rdir);[suj,q]=get_parent_path(dti);ccdir=get_subdir_regex(suj,'CC');

par.nb_tirage=20000;
par.delete_if_exist=1

for k=1:length(dti)
  trackdir = get_subdir_regex(dti{k},{'bedpostdir\.bedpostX'});
  par.sge=1;  par.type =  'classification';
  outdir1 = fullfile(dti{k},'CC_sphere10_fonc');
  bm1 = get_subdir_regex_files(ccdir(k),'^rfsl',1);

  bm2=get_subdir_regex_files(roidir(k),'^rDTI.*sphere10',2)
  
  process_probtrack(bm1,bm2,outdir1,trackdir,par);
end



%run mrtrix
%creation d'une sphere centre sur le local maxima

group = {'/home/sabine/data_momic/Controles','/home/sabine/data_momic/Patients/MM_Patients'}
suj = get_subdir_regex(group,'^[mCP]','^20');
dti_track = get_subdir_regex(suj,'Diff','CC_ALL38');
dti = get_parent_path(dti_track);
suj = get_parent_path(dti);

dtimrtrix = get_subdir_regex(dti,'mrtrix');
rdir=get_subdir_regex(dti,'MaskTrafique')
ccdir=get_subdir_regex(suj,'CC');

%roidir =  get_subdir_regex(suj,'Diff','MaskTrafique');
%ccdir =  get_subdir_regex(suj,'CCseg');

ff=get_subdir_regex_files(dti,'4D_eddycor_unwarp',1);
mdir = r_mkdir(dti,'mrtrix')

process_mrtrix(ff,mdir)

%do the trackto

%bm1 = get_subdir_regex_files(ccdir,'^rfsl',1); do_fsl_bin(bm1,'bin_')
bm1 = get_subdir_regex_files(ccdir,'^bin_rfsl',1);

%bm2=get_subdir_regex_files(rdir,'^rDTI',24);
%bm22=get_subdir_regex_files(ccdir,'rDTI_wMNI',16);
%bm2 = concat_cell(bm2,bm22);

bm2=get_subdir_regex_files(rdir,'^rDTI.*sphere10',2);
%bm2 = do_fsl_bin(bm2,'bin_')
bm2=get_subdir_regex_files(rdir,'^bin_rDTI.*[lr]h')
bm2=get_subdir_regex_files(ccdir,'rDTI_wMNI',16); %prefix bin_ oublier apres do_fsl_bin
 
sdata = get_subdir_regex_files(dtimrtrix,'CSD8',1);
par.track_name='seed_CC';
par.target = bm2;
par.track_num=100000;
par.track_maxnum=100000;

process_mrtrix_trackto(sdata,bm1,par)

bm1=get_subdir_regex_files(ana,'^bin_p2',1);
par.track_num = 1500000; par.track_name='seed_wm_bin_p2_maskT1_curv2';
par.mask_filename=get_subdir_regex_files(ana,'bin09_T1mask',1)

%%%%%%%%%%%%%%%%%%%%Filter track
track_in = get_subdir_regex_files(dtimrtrix,'seed_wm_bin_p2_maskT1_curv2.trk',1)

%par.test=1;
I1 = get_subdir_regex_files(rdir,'sphere10',2)
I2 = get_subdir_regex_files(ccdir,'^bin_rfsl',1);
par.roi_include = concat_cell(I1,I2);
%unzip_volume(par.roi_include); and do the selection again
par.track_name = 'seed_wm_Include_CC_both_sphere10.trk';
mrtrix_filter_trackt(track_in,par)

par.test='/home/sabine/doit_fileter';
I1 = get_subdir_regex_files(rdir,'G-Rest_sphere10',1);I2 = get_subdir_regex_files(ccdir,'^bin_rfsl',1);
par.roi_include = concat_cell(I1,I2);par.track_name = 'seed_wm_Include_CC_G-Rest_sphere10.trk';
mrtrix_filter_trackt(track_in,par)

I1 = get_subdir_regex_files(rdir,'D-Rest_sphere10',1);I2 = get_subdir_regex_files(ccdir,'^bin_rfsl',1);
par.roi_include = concat_cell(I1,I2);par.track_name = 'seed_wm_Include_CC_D-Rest_sphere10.trk';
mrtrix_filter_trackt(track_in,par)

par.test='/home/sabine/doit_filter_postcentral';
I1 = get_subdir_regex_files(ccdir,'^wMNI_Postcentral_',2);par.track_name = 'seed_wm_Include_CC_D-Rest_sphere10.trk';
I1 = get_subdir_regex_files(ccdir,'^wMNI_Supp_Motor_Area',2);par.track_name = 'seed_wm_Include_CC_D-Rest_sphere10.trk';
I1 = get_subdir_regex_files(ccdir,'rDTI_r_ctx-rh-G_postcentral',2);I2 = get_subdir_regex_files(ccdir,'^bin_rfsl',1);
par.roi_include = concat_cell(I1,I2);
mrtrix_filter_trackt(track_in,par)

par.test='/home/sabine/doit'
I1 = get_subdir_regex_files(ccdir,'^wMNI_Frontal_Sup_[LR]',2);par.track_name = 'seed_wm_Include_CC_Frontal_Sup.trk';
par.roi_include = concat_cell(I1,I2);
mrtrix_filter_trackt(track_in,par)

I1 = get_subdir_regex_files(ccdir,'^wMNI_Frontal_Sup_Medial_[LR]',2);par.track_name = 'seed_wm_Include_CC_Frontal_Sup_Medial.trk';
par.roi_include = concat_cell(I1,I2);
mrtrix_filter_trackt(track_in,par)

I1 = get_subdir_regex_files(ccdir,'^wMNI_Occipital_Sup_[LR]',2);par.track_name = 'seed_wm_Include_CC_Occipital_Sup_.trk';par.roi_include = concat_cell(I1,I2);
mrtrix_filter_trackt(track_in,par)

I1 = get_subdir_regex_files(ccdir,'^wMNI_Parietal_Sup',2);par.track_name = 'seed_wm_Include_CC_Parietal_Sup.trk';par.roi_include = concat_cell(I1,I2);
mrtrix_filter_trackt(track_in,par)

I1 = get_subdir_regex_files(ccdir,'^wMNI_Postcentral',2);par.track_name = 'seed_wm_Include_CC_Postcentral.trk';
par.roi_include = concat_cell(I1,I2);mrtrix_filter_trackt(track_in,par)

I1 = get_subdir_regex_files(ccdir,'^wMNI_SupraMarginal',2);par.track_name = 'seed_wm_Include_CC_SupraMarginal.trk';
par.roi_include = concat_cell(I1,I2);mrtrix_filter_trackt(track_in,par)


%Do the stat on mrtrix nr of fiber
group = {'/home/sabine/data_img/data_momic/Controles','/home/sabine/data_img/data_momic/Patients/MM_Patients'};
pool={'cont','pat'};

for k=1:2
  suj = get_subdir_regex(group{k},'^[mCP]','^20');
  dti_track = get_subdir_regex(suj,'Diff','CC_ALL38');

  dti = get_parent_path(dti_track);
  suj = get_parent_path(dti);
  mdir = r_mkdir(dti,'mrtrix')

  [p sujname] = get_parent_path(suj);  [p sujname] = get_parent_path(p);
  
 % ft=get_subdir_regex_files(mdir,'^seed.*[lr]h')
 % ft=get_subdir_regex_files(mdir,'^seed_CC_to_rDTI_wMNI.*trk')
%  ft=get_subdir_regex_files(mdir,'sphere10.*trk',2)
  ft=get_subdir_regex_files(mdir,'seed_wm_Include_CC_both_sphere10.trk',1)
  
  [pp nn]=get_parent_path(ft);nn=cellstr(nn{1});
  nnn=remove_str_from_cell_list(nn,'seed_CC_to_rDTI_');
  nnn=nettoie_dir(remove_str_from_cell_list(nnn,'.trk'))
  nnn = {'M1D_G_Rest','M1G_D_Rest'}
  
  r(k).pool = pool{k};
  r(k).suj = sujname;
  if k==1
    r=count_mrtrix_track(ft,r(k),nnn);
  else
    r(k) =count_mrtrix_track(ft,r(k),nnn);
  end
  
end


for k=1:2
  r(k).rh_sur_lh_G_postcentral=r(k).r_ctx_lh_G_postcentral./r(k).r_ctx_rh_G_postcentral;
  r(k).rh_sur_lh_G_precentral=r(k).r_ctx_lh_G_precentral./r(k).r_ctx_rh_G_precentral;
  r(k).rh_sur_lh_S_central=r(k).r_ctx_lh_S_central./r(k).r_ctx_rh_S_central;
  r(k).rh_sur_lh_G_precentral_mask=r(k).r_ctx_lh_G_precentral_mask./r(k).r_ctx_rh_G_precentral_mask;
  r(k).rh_sur_lh_S_central_ant_mask=r(k).r_ctx_lh_S_central_ant_mask./r(k).r_ctx_rh_S_central_ant_mask;
end

write_res_to_csv(r,'mt.csv')


%get the volume from seg8.txt file
group = {'/home/sabine/data_img/data_momic/Controles','/home/sabine/data_img/data_momic/Patients/MM_Patients'};
pool={'cont','pat'};

for k=1:2
  suj = get_subdir_regex(group{k},'^[mCP]','^20');
  dti_track = get_subdir_regex(suj,'Diff','CC_ALL38');

  dti = get_parent_path(dti_track);
  suj = get_parent_path(dti);
  mdir = r_mkdir(dti,'mrtrix');
  ana=get_subdir_regex(dti,'anat');
  [p sujname] = get_parent_path(suj);  [p sujname] = get_parent_path(p);
  r(k).pool = pool{k};
  r(k).suj = sujname;
  sf=get_subdir_regex_files(ana,'seg8.txt',1);

  for ks=1:length(sf)
    b=load(sf{ks});
    r(k).gm(ks) = b(1);
    r(k).wm(ks) = b(2);
    r(k).csf(ks) = b(3);
    r(k).tot(ks) =sum( b);
  end
end


%avril 2012

 suj=get_subdir_regex({'/home/sabine/data_img/data_momic/Controles','/home/sabine/data_img/data_momic/Patients/MM_Patients'},'^[CP]','^20');
 dti = get_subdir_regex(suj,'Diff_ok$');
 ana=get_subdir_regex(dti,'anat_coreg')
dd=get_subdir_regex(dti,'one')
mdir=get_subdir_regex(dd,'mrtrix')

ff=get_subdir_regex_files(dti,'^4D_eddycor_.*gz$');
par.susan_noise=150
transform_4D_to_oneB04D(ff,par)

T1_f = get_subdir_regex_files(ana,'^s.*img$',1) ;
B0_f=get_subdir_regex_files(dti,'meanB0_susan150.nii.gz',1);
B0_f = unzip_volume(B0_f)

job=job_new_segment(B0_f) ;
spm_jobman('run',job)

anat = get_subdir_regex_files(ana,'^p3s.*nii$',1);
epi = get_subdir_regex_files(dti,'^c3meanB0_susan150.*nii$');
par.transfoname='anatp3_to_B0susanec3'
par.sge=1;
do_minc_nlin_trasfo(anat,epi,par)

%aa = get_subdir_regex(ana, 'new_seg')
transfo = get_subdir_regex_files(ana,sprintf('%s_nlin_inv.xfm',par.transfoname),1)

od = get_subdir_regex(dti,'oneB0');

%eddy = get_subdir_regex_files(dti,'^Bo_unwarp.nii$',1);
eddy = get_subdir_regex_files(dti,'^meanB0_susan150.nii$',1);
eddy = get_subdir_regex_files(od,'^4D_eddycor_unwarp_trackvis.nii.gz',1);

do_minc_normalize(eddy,eddy,transfo);
ltr
aainv =  get_subdir_regex_files(ana,'^y_rs.*nii$');
ff=get_subdir_regex_files(dti,'mimc_anatp3_to_B0c3_nlin_inv',1);
ff=get_subdir_regex_files(dti,'mimc.*susan.*',1);
par.interp=1;
job = job_vbm8_create_wraped(aainv,ff,par);
spm_jobman('run',job)

 c5b c5c  C7 P4 P5 P8 Pe1 

dd=get_subdir_regex(dti,'oneB0_4Ddir')
ff=get_subdir_regex_files(dd,'^mimc',1);
mdir = r_mkdir(dd,'mrtrix')
 par.fsl_mask = 'brainmask_short.nii.gz'

process_mrtrix(ff,mdir,par)

mdir=get_subdir_regex(dti,'new_mrtrix');roi=get_subdir_regex(dti,'roi_resting_atlas')

sdata = get_subdir_regex_files(mdir,'CSD8',1);
par.track_name='seed_white_bsteam';par.track_num=500000;par.track_maxnum=500000;par.mask_filename='wbsteam_mask.nii';
bm1 = get_subdir_regex_files(ana,'^white_bsteam',1)
process_mrtrix_trackto(sdata,bm1,par)

sdata = get_subdir_regex_files(mdir,'CSD8',1);bm1 = get_subdir_regex_files(roi,'rfree',1)
par.track_name='seed_CC';par.track_num=1000000;par.track_maxnum=1000000;
par.mask_filename='wholedtimask.nii';
process_mrtrix_trackto(sdata,bm1,par)

sdata = get_subdir_regex_files(mdir,'CSD8',1);bm1 = get_subdir_regex_files(roi,'whitematter.nii',1)
par.track_name='seed_white_matter';par.track_num=1500000;par.track_maxnum=par.track_num;
process_mrtrix_trackto(sdata,bm1,par)

strk =  get_subdir_regex_files(mdir,[par.track_name '.trk'],1);
volout = addsufixtofilenames(mdir,[par.track_name])
T1_f=get_subdir_regex_files(ana,'s.*img')
%mrtrix_tracks2prob(strk,volout,T1_f)
mrtrix_tracks2prob(strk,volout,0.5)

%%%%%%%%%%%%copy ROI from data_decuss   ARG sujnam change
 da = get_subdir_regex('/home/sabine/data_momic/data_decuss/Analyse_Connectomist','^[cp]')
dr=get_subdir_regex(da,'ROI')
 ff=get_subdir_regex_files(dr,'MOMIC')
ss=get_subdir_regex({'/home/sabine/data_img/data_momic/Controles','/home/sabine/data_img/data_momic/Patients/MM_Patients'},'^[CP]')

sujo={}
for k=1:length(ff)
 [p f]=fileparts(ff{k}(1,:));
ind=findstr(f,'MOMIC_');
qsdf =  f(ind+6:ind+13);
if strcmp(qsdf(end),'-'), qsdf(end)=[];end

nam{k} = qsdf; % f(ind+6:ind+13);
qsdf =  get_subdir_regex(ss,['^2.*',nam{k}]);
if ~isempty(qsdf)
sujo(end+1) =qsdf;
else
fprintf('Arg no suj %s\n',nam{k})
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%tracking dentate to thalamus

fana=get_subdir_regex_files(ana,'^s.*hdr',1)
fdti = get_subdir_regex_files(dti,'nodif_brain_mask',1)
for k=1:length(fana)
    T12DTI_transfo = fullfile(roi{k},'T1_2DTI_transfo.txt');
    cmd = sprintf('flirt -applyxfm -usesqform -in %s -ref %s -omat %s',fana{k},fdti{k},T12DTI_transfo);
    unix(cmd);

end
suj=get_subdir_regex({'/home/sabine/data_img/data_momic/Controles','/home/sabine/data_img/data_momic/Patients/MM_Patients'},'^[CP]','^20');
dti = get_subdir_regex_one(suj,'Diff_ok$');bet = get_subdir_regex_one(dti,'bedpostX');
ana=get_subdir_regex_one(dti,'anat_coreg') ;
%cdir=get_subdir_regex(suj,'CC');fc=get_subdir_regex_files(cdir,'^rT1_l',1);

for k=[1:length(suj)]

  bm1 = get_subdir_regex_files(ana{k},'wDentatewfu_Gauche.nii.gz',1);
  bm2 = get_subdir_regex_files(ana{k},'r_Right_thalamus.nii.gz',1);  
  %bm2 = concat_cell(bm1,bm2);
  transfo = get_subdir_regex_files(ana(k),'T1_2DTI_transfo',1);
  
  par.xfm = char(transfo);
  par.sge=1; par.probtrackx2 = 1; par.onewaycondition =1;

  par.delete_if_exist = 1;
  par.modeuler=1;
  %par.exclusion = fc{k};%CC char(get_subdir_regex_files(ana(k),'bin_wmask_dentele_gauche_full',1));
  par.exclusion = char(get_subdir_regex_files(ana(k),'mask_CC_cerebDroit_thalG.nii.gz',1));
  par.termination = bm2{1}

  outdir1 = fullfile(dti{k},'dentate_gauche_thalamus_droit_probt2_exCCDentate_newuw');
  par.type = 'waypoint';
  process_probtrack(bm1,bm2,outdir1,bet(k),par)

  %%%%%%%%%%%%%%%%%%%%
  %par.exclusion = fc{k}; %CC char(get_subdir_regex_files(ana(k),'bin_wmask_dentele_droit_full',1));
  par.exclusion = char(get_subdir_regex_files(ana(k),'mask_CC_cerebGauche_thalD.nii.gz',1));

  bm1 = get_subdir_regex_files(ana{k},'wDentatewfu_Droit.nii.gz',1);
  bm2 = get_subdir_regex_files(ana{k},'r_Left_thalamus.nii.gz',1);
  %bm2 = concat_cell(bm1,bm2);
  par.termination = bm2{1}

  outdir1 = fullfile(dti{k},'dentate_droit_thalamus_gauche_probt2_exCCDentate_newuw');
  process_probtrack(bm1,bm2,outdir1,bet(k),par)

end

%%%%%%%%%%%%%%
%%%%%%tracking CC to roi_atlas
suj=get_subdir_regex({'/home/sabine/data_img/data_momic/Controles','/home/sabine/data_img/data_momic/Patients/MM_Patients'},'^[CP]','^20');
dti = get_subdir_regex_one(suj,'Diff_ok$');bet = get_subdir_regex_one(dti,'bedpostX');mdir=get_subdir_regex(dti,'new_mrt')
roi = get_subdir_regex(dti,'roi_resting_atlas');fstop = get_subdir_regex_files(roi,'inv_who',1);wm = get_subdir_regex_files(dti,'^rfree.*[LF].*[1Ad].nii',3);  

for k=[1:length(suj)]

  bm1 = get_subdir_regex_files(roi{k},'^rfree_rT1',1);
  bm2 = get_subdir_regex_files(roi{k},'ka',30);    %bm2 = concat_cell(bm1,bm2);
  transfo = get_subdir_regex_files(roi(k),'T1_2DTI_transfo',1);
  
  par.xfm = char(transfo);
  par.sge=1; par.probtrackx2 = 1; par.onewaycondition =1;
  par.delete_if_exist = 1;  par.modeuler=1;  par.termination = fstop{k}
  
  outdir1 = fullfile(dti{k},'CC_to_foncatlas_px2_stop');
  par.type = 'classification';
  process_probtrack(bm1,bm2,outdir1,bet(k),par)

end

%same with mrtirx
roiname = {'ac','face','foot','hand','pc','sma','v1'};
track_in = get_subdir_regex_files(mdir,'^seed_CC.trk',1);    fa = get_subdir_regex_files(ana,'^s.*img',1);
for k=1:length(roiname)
    ff = get_subdir_regex_files(roi,['^' roiname{k} ,'.*kadti'],2);
    par.roi_include = ff; par.track_name=[roiname{k} '_left_right_seed_CC.trk'];
    mrtrix_filter_trackt(track_in,par)
    ff = get_subdir_regex_files(mdir,par.track_name);
    mrtrix_tracks2prob(ff,fa);
end

cdir=get_subdir_regex(suj,'CC'); fcc = get_subdir_regex_files(cdir,'^rT1',1);

for k=1:length(roiname)
    ff = get_subdir_regex_files(mdir,[roiname{k} '_left_right_seed_CC_prob.nii'],1);
    do_fsl_reslice(ff,fcc);ff = get_subdir_regex_files(mdir,['^rfsl_' roiname{k} '_left_right_seed_CC_prob.nii'],1);
    fo = addsufixtofilenames(ff,'_onCC');
    do_fsl_mult(concat_cell(ff,fcc),fo);
end
%%%%%%%%%%%%%%%%%%%
%GET the stat on
clear all
roiname = {'ac','face','foot','hand','pc','sma','v1','S_central','G_precentral','G_postcentral'};
group = {'/home/sabine/data_img/data_momic/Controles','/home/sabine/data_img/data_momic/Patients/MM_Patients'}
for nb_group = 1:length(group)
    if nb_group==1
        suj = get_subdir_regex(group{nb_group},'^[mCP]','^20');
        %suj([2 3  8 9  16 17 18 22 23])='';
    else
        suj = get_subdir_regex(group{nb_group},'^[mCP]','^20');
        %suj = get_subdir_regex(group{nb_group},{'^P[135789]$','^P10$'},'^20');
    end
    dti = get_subdir_regex(suj,'Diff');        ana=get_subdir_regex(dti,'anat');mdir = get_subdir_regex(dti,'new_mr');
    
    [pp,sujname] = get_parent_path(suj,2);    [ppp,poolnam] = fileparts(pp{1});    
    cout.pool = poolnam;    cout.suj = sujname;
    %FA=get_subdir_regex_files(dti,'^r_T1.*FA.nii',1);
    %FA=get_subdir_regex_files(dti,{'^r_T1.*L1',},1);
    FA=get_subdir_regex_files(dti,{'^r_T1.*rad',},1);

    for k=1:length(roiname)
       ff = get_subdir_regex_files(mdir,['^rfsl_.*' roiname{k} '_left_right_seed_CC_prob.nii_onfreeCC'],1);
       %ff = get_subdir_regex_files(mdir,['^rfsl_.*' roiname{k} '_left_right_seed_CC_prob.nii_onCC'],1);
       fname = ['CC_Lrad_' roiname{k}];
       vv =get_wheited_mean(FA,ff);
       cout = setfield(cout,fname,vv);
    end
cOK(nb_group) = cout;
end
cc=reduce_cell(cOK,{[2 3  8 9  16 17 18 22 23 24 25 26],[2 3 4 5 7 12]})

%%%%%%%%%same but with wMNI roi  tracking CC
mdir=get_subdir_regex(dti,'new_mrtr'); cdir = get_subdir_regex(suj,'CC');fcc = get_subdir_regex_files(cdir,'^rT1',1);ana=get_subdir_regex(dti,'anat');
roiname = {'Frontal_Sup','Frontal_Sup_Medial','Occipital_Sup','Parietal_Sup','Postcentral','Precentral','Supp_Motor_Area','SupraMarginal'};
track_in = get_subdir_regex_files(mdir,'^seed_CC.trk',1);    fa = get_subdir_regex_files(ana,'^s.*img',1);
par.cmd_file='filter_trk.sh';
for k=1:length(roiname)
    ff = get_subdir_regex_files(cdir,['^wMNI_' roiname{k} ,'_[RL]'],2);
    par.roi_include = ff; par.track_name=[roiname{k} '_left_right_seed_CC.trk'];
    %mrtrix_filter_trackt(track_in,par)
    ff = get_subdir_regex_files(mdir,par.track_name,1);
    mrtrix_tracks2prob(ff,fa,par);
end


for k=1:length(roiname)
    %ff = get_subdir_regex_files(mdir,['^ctx_' roiname{k} '_left_right_seed_CC_prob.nii'],1); do_fsl_reslice(ff,fcc);
    ff = get_subdir_regex_files(mdir,['^rfsl_.*' roiname{k} '_left_right_seed_CC_prob.nii.gz$'],1);
    fo = addsufixtofilenames(ff,'_onfreeCC');
    do_fsl_mult(concat_cell(ff,fcc),fo);
end

%%%%%%%%%same but with wMNI roi  tracking CC
roiname = {'S_central','G_precentral','G_postcentral'}
for k=1:length(roiname)
    ff = get_subdir_regex_files(ana,['^r_.*' roiname{k} ],2);
    par.roi_include = ff; par.track_name=['ctx_' roiname{k} '_left_right_seed_CC.trk'];
    %mrtrix_filter_trackt(track_in,par)
    ff = get_subdir_regex_files(mdir,par.track_name,1);
    mrtrix_tracks2prob(ff,fa,par);
end

%%%%%%%%% CST track on roi_decuss
ft=get_subdir_regex_files(mdir,'^CST',6);
roiname = {'CST_L_BAD_ipsi','CST_L_contra','CST_L_ipsi','CST_R_BAD_ipsi','CST_R_contra','CST_R_ipsi'};
mrtrix_tracks2prob(ff,fa)
 fcc=get_subdir_regex_files(mdir,'^bin.*ecuss',1)
for k=1:length(roiname)
    ff = get_subdir_regex_files(mdir,[ roiname{k} '_prob.nii'],1); 
    fo = addsufixtofilenames(ff,'_decuss');
    do_fsl_mult(concat_cell(ff,fcc),fo);
end

clear all
roiname = {'CST_L_BAD_ipsi','CST_L_contra','CST_L_ipsi','CST_R_BAD_ipsi','CST_R_contra','CST_R_ipsi'};
group = {'/home/sabine/data_img/data_momic/Controles','/home/sabine/data_img/data_momic/Patients/MM_Patients'}
for nb_group = 1:length(group)
    if nb_group==1
        suj = get_subdir_regex(group{nb_group},'^[mCP]','^20');
    else
        suj = get_subdir_regex(group{nb_group},'^[mCP]','^20');
    end
    dti = get_subdir_regex(suj,'Diff');        ana=get_subdir_regex(dti,'anat');mdir = get_subdir_regex(dti,'new_mr');
    ff=get_subdir_regex_files(mdir,'^bin_.*uss');suj=get_parent_path(ff,3)
    dti = get_subdir_regex(suj,'Diff');        ana=get_subdir_regex(dti,'anat');mdir = get_subdir_regex(dti,'new_mr');

    [pp,sujname] = get_parent_path(suj,2);    [ppp,poolnam] = fileparts(pp{1});    
    cout.pool = poolnam;    cout.suj = sujname;
    FA=get_subdir_regex_files(dti,'^r_T1.*FA.nii',1);
    FA=get_subdir_regex_files(dti,{'^r_T1.*L1',},1);
    %FA=get_subdir_regex_files(dti,{'^r_T1.*rad',},1);

    for k=1:length(roiname)
       %ff = get_subdir_regex_files(mdir,[roiname{k} '_prob_decuss'],1);
       %do_fsl_reslice(ff,FA);
       ff = get_subdir_regex_files(mdir,['rfsl_' roiname{k} '_prob_decuss'],1);
       fname = ['decuss_L1_' roiname{k}];
       vv =get_wheited_mean(FA,ff);
       cout = setfield(cout,fname,vv);
    end
cOK(nb_group) = cout;
end

%%%%%%%%%%%%%%%%%%%
%GET the stat on dentate to thalamus
do_fsl_reslice(ffa,fa,'rT1_'); % reslice FA in anat (fa)
clear all
group = {'/home/sabine/data_img/data_momic/Controles','/home/sabine/data_img/data_momic/Patients/MM_Patients'}
for nb_group = 1:length(group)
    if nb_group==1
        suj = get_subdir_regex(group{nb_group},'^[mCP]','^20');
        %suj([2 3  8 9  16 17 18 22 23])='';
    else
        suj = get_subdir_regex(group{nb_group},'^[mCP]','^20');
        %suj = get_subdir_regex(group{nb_group},{'^P[135789]$','^P10$'},'^20');
    end
    dti = get_subdir_regex(suj,'Diff');        ana=get_subdir_regex(dti,'anat');
    
    [pp,sujname] = get_parent_path(suj,2);    [ppp,poolnam] = fileparts(pp{1});    
    cout(nb_group).pool = poolnam;    cout(nb_group).suj = sujname;
    
    %prob=get_subdir_regex(dti,'dentele_droit_to_thalamus_gauche_exclusion_waypoint_full')
    prob=get_subdir_regex(dti,'dentate_droit_thalamus_gauche_probt2_exCCDentate_newuw');
    fdt=get_subdir_regex_files(prob,'^fdt_path',1);
    FA=get_subdir_regex_files(dti,'^r_T1.*FA',1);
    fwt=get_subdir_regex_files(prob,'waytot',1);
    
    for kk=1:length(fwt)
        l = load(fwt{kk});
        cout(nb_group).Rd2tal_wt(kk) = sum(l);
    end
    bm1 = get_subdir_regex_files(ana,'r_Left_thalamus.nii.gz',1);    v=do_fsl_getvol(bm1);
    cout(nb_group).Tha_L_vol = v(:,1)';
    bm1 = get_subdir_regex_files(ana,'r_Right_thalamus.nii.gz',1); v=do_fsl_getvol(bm1);
    cout(nb_group).Tha_R_vol = v(:,1)';
    bm1 = get_subdir_regex_files(ana,'wDentatewfu_Gauche.nii.gz',1); v=do_fsl_getvol(bm1);
    cout(nb_group).Dentate_L_vol = v(:,1)';
    bm1 = get_subdir_regex_files(ana,'wDentatewfu_Droit.nii.gz',1);  v=do_fsl_getvol(bm1);
    cout(nb_group).Dentate_R_vol = v(:,1)';
    
    cout(nb_group).Rd2tal_wFA = get_wheited_mean(FA,fdt);
    cout(nb_group).Rd2tal_totcon = do_fsl_getsumval(fdt);
    
    prob=get_subdir_regex(dti,'dentate_gauche_thalamus_droit_probt2_exCCDentate_newuw');
    fdt=get_subdir_regex_files(prob,'^fdt_path',1);
    fwt=get_subdir_regex_files(prob,'waytot',1);
    
    for kk=1:length(fwt)
        l = load(fwt{kk});
        cout(nb_group).Ld2tal_wt(kk) = sum(l);
    end
    
    cout(nb_group).Ld2tal_wFA = get_wheited_mean(FA,fdt);
    cout(nb_group).Ld2tal_totcon = do_fsl_getsumval(fdt);
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%ù
%%%%%%%%%%%%%%
same with mrtrix
dtimrtrix = get_subdir_regex(dti,'one','mrtri')
track_in = get_subdir_regex_files(dtimrtrix,'seed_wm_bin_p2_maskT1_curv2.trk',1)

%bm1 = get_subdir_regex_files(ana,'wDentatewfu_Gauche.nii.gz',1);bm2 = get_subdir_regex_files(ana,'r_Right_thalamus.nii.gz',1);  
bm1 = get_subdir_regex_files(ana{k},'wDentatewfu_Droit.nii.gz',1);bm2 = get_subdir_regex_files(ana{k},'r_Left_thalamus.nii.gz',1);
par.roi_include = concat_cell(bm1,bm2);
%par.roi_exclude = get_subdir_regex_files(ana,'mask_CC_cerebDroit_thalG.nii.gz',1);
par.roi_exclude = get_subdir_regex_files(ana(k),'mask_CC_cerebGauche_thalD.nii.gz',1);
%par.track_name = 'dentate_gauche_thalamus_droit_probt2_exCCDentate.trk';
par.track_name = 'dentate_droit_thalamus_gauche_probt2_exCCDentate.trk';
mrtrix_filter_trackt(track_in,par)
%%%%%%%%%%%%%%%% do the stats
group = {'/home/sabine/data_img/data_momic/Controles','/home/sabine/data_img/data_momic/Patients/MM_Patients'}
for nb_group = 1:length(group)
    if nb_group==1
        suj = get_subdir_regex(group{nb_group},'^[mCP]','^20');
        suj([2 3  8 9  16 17 18 22 23])='';
    else
        suj = get_subdir_regex(group{nb_group},{'^P[135789]$','^P10$'},'^20'); % ind_to_remove = [3 4 5 7 12]
    end
    dti = get_subdir_regex(suj,'Diff');    ana=get_subdir_regex(dti,'anat');
    [pp,sujname] = get_parent_path(suj,2);    [ppp,poolnam] = fileparts(pp{1});    
    cout(nb_group).pool = poolnam;    cout(nb_group).suj = sujname;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%ù

ff = get_subdir_regex_files(mdir,'CST_L_ipsi.trk');suj=get_parent_path(ff,3);
%que 26 suj finalement ...

%%%%%%%%%% DECUSS %%%%%%%%%
suj=get_subdir_regex({'/home/sabine/data_img/data_momic/Controles','/home/sabine/data_img/data_momic/Patients/MM_Patients'},'^[CP]','^20');
roid = get_subdir_regex(suj,'Diff_ok','roi_decuss_rT1'); suj = get_parent_path(roid,2);
dti = get_subdir_regex_one(suj,'Diff_ok$');mdir=get_subdir_regex(dti,'new_mrt');
track_in = get_subdir_regex_files(mdir,'seed_white_matter.trk',1);

flow_left_ipsi = get_subdir_regex_files(roid,'DecLowL_ipsi',1);
flow_left_contra = get_subdir_regex_files(roid,'DecLowL_contra',1);
flow_right_ipsi = get_subdir_regex_files(roid,'DecLowR_ipsi',1);
flow_right_contra = get_subdir_regex_files(roid,'DecLowR_contra',1);
fmidel_left = get_subdir_regex_files(roid,'DecMidL',1);
fmidel_right=get_subdir_regex_files(roid,'DecMidR',1);
fup_left = get_subdir_regex_files(roid,'DecUpL',1);
fup_right=get_subdir_regex_files(roid,'DecUpR',1);

par.cmd_file = 'filter_decus';
par.track_name='CST_L_contra';
par.roi_include=concat_cell(fmidel_left,fup_left,flow_left_contra);
par.roi_exclude = concat_cell(flow_left_ipsi,flow_right_ipsi,flow_right_contra);
mrtrix_filter_trackt(track_in,par)
par.track_name='CST_R_contra';
par.roi_include=concat_cell(fmidel_right,fup_right,flow_right_contra);
par.roi_exclude = concat_cell(flow_left_ipsi,flow_right_ipsi,flow_left_contra);
mrtrix_filter_trackt(track_in,par)
par.track_name='CST_L_ipsi';
par.roi_include=concat_cell(fmidel_left,fup_left,flow_left_ipsi);
par.roi_exclude = concat_cell(flow_left_contra,flow_right_ipsi,flow_right_contra);
mrtrix_filter_trackt(track_in,par)
par.track_name='CST_R_ipsi';
par.roi_include=concat_cell(fmidel_right,fup_right,flow_right_ipsi);
par.roi_exclude = concat_cell(flow_left_contra,flow_left_ipsi,flow_right_contra);
mrtrix_filter_trackt(track_in,par)
par.track_name='CST_L_BAD_ipsi';
par.roi_include=concat_cell(fmidel_left,fup_left,flow_right_contra);
par.roi_exclude = concat_cell(flow_left_contra,flow_right_ipsi,flow_left_ipsi);
mrtrix_filter_trackt(track_in,par)
par.track_name='CST_R_BAD_ipsi';
par.roi_include=concat_cell(fmidel_right,fup_right,flow_left_contra);
par.roi_exclude = concat_cell(flow_right_contra,flow_right_ipsi,flow_left_ipsi);
mrtrix_filter_trackt(track_in,par)

%%%%%  filter those with left hand
roia=get_subdir_regex(dti,'roi_resting_atlas')
par.roi_include = get_subdir_regex_files(roia,'hand_left_kars.nii.gz',1);
ti=get_subdir_regex_files(mdir,'CST_L_contra.trk',1);  par.track_name = 'CST_L_contra_lHdand';
ti = get_subdir_regex_files(mdir,'CST_L_BAD_ipsi.trk',1);  par.track_name = 'CST_L_BAD_ipsi_lHdand';

par.roi_include = get_subdir_regex_files(roia,'hand_right_kars.nii.gz',1);
ti=get_subdir_regex_files(mdir,'CST_R_contra.trk',1);  par.track_name = 'CST_R_contra_rHdand';
ti = get_subdir_regex_files(mdir,'CST_R_BAD_ipsi.trk',1);  par.track_name = 'CST_R_BAD_ipsi_rHdand';

mrtrix_filter_trackt(ti,par)


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Do the stat on mrtrix nr of fiber
group = {'/home/sabine/data_img/data_momic/Controles','/home/sabine/data_img/data_momic/Patients/MM_Patients'};
pool={'cont','pat'};

for k=1:2
  suj = get_subdir_regex(group{k},'^[mCP]','^20');dti = get_subdir_regex_one(suj,'Diff_ok$');mdir=get_subdir_regex(dti,'new_mrt');
  ff = get_subdir_regex_files(mdir,'CST_L_ipsi.trk');suj=get_parent_path(ff,3);
  dti = get_subdir_regex_one(suj,'Diff_ok$');mdir=get_subdir_regex(dti,'new_mrt');


  [p sujname] = get_parent_path(suj,2);  
  
  ft=get_subdir_regex_files(mdir,'^CST.*trk$',10)
    
  r(k).pool = pool{k};
  r(k).suj = sujname;
  if k==1
    r=count_mrtrix_track(ft,r(k));
  else
    r(k) =count_mrtrix_track(ft,r(k));
  end
  
end
rr=reduce_cell(r,{[3 4 11 12 14 18 19 21],[2 3 4 5 8 ]});%en trichant sur les controls

 r(1).CST_R_contra_rHdand_percent = r(1).CST_R_contra_rHdand_nb_fiber./r(1).CST_R_contra_nb_fiber;
 r(1).CST_L_contra_lHdand_percent = r(1).CST_L_contra_lHdand_nb_fiber./r(1).CST_L_contra_nb_fiber;
 r(1).CST_L_BAD_ipsi_lHdand_percent = r(1).CST_L_BAD_ipsi_lHdand_nb_fiber./r(1).CST_L_BAD_ipsi_nb_fiber;
 r(1).CST_R_BAD_ipsi_rHdand_percent = r(1).CST_R_BAD_ipsi_rHdand_nb_fiber./r(1).CST_R_BAD_ipsi_nb_fiber;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ff=get_subdir_regex_files(roi,'^Basse_DroiteDroite.nii',1);
o=write_vol_to_roi(ff,0)     
froi = get_subdir_regex_files(ana,'^s.*img$',1) ;
froi = get_subdir_regex_files(ana,'^s.*img$',1) ;

clear ymean ystd
for k=1:length(froi)
try
 [ymean(k) ystd(k)]=extract_roi_data2(froi(k),o(k));
catch
fprintf('no data for %s\n',froi{k});
end
end
figure; plot(ymean);hold on ;plot(ymean,'xr')
ind = find(ymean==0)
char(rsuj(ind))


 fa=get_subdir_regex_files(ana,{'^p2.*nii','^wb.*nii'})
 fout=addsufixtofilenames(ana,'/white_bsteam_mask.nii');
 do_fsl_mult(fa,fout)
 do_fsl_bin(fout,'',0.7); 


out sur mrtrix fa

/home/sabine/data_img/data_momic/Controles/C1/2010_02_19_MOMIC_FEDES_T02/Diff_ok/mrtrix/fa.nii           
/home/sabine/data_img/data_momic/Controles/C1b/2010_02_05_MOMIC_TROOR_T01/Diff_ok/mrtrix/fa.nii          
/home/sabine/data_img/data_momic/Patients/MM_Patients/P1/2010_02_26_MOMIC_FAILA_P03/Diff_ok/mrtrix/fa.nii
/home/sabine/data_img/data_momic/Patients/MM_Patients/P3/2010_03_12_MOMIC_PRIMI_04/Diff_ok/mrtrix/fa.nii 
/home/sabine/data_img/data_momic/Patients/MM_Patients/P8/2010_07_20_MOMIC_PRIST15/Diff_ok/mrtrix/fa.nii  

out su mrtrix meanB0

/home/sabine/data_img/data_momic/Controles/C1/2010_02_19_MOMIC_FEDES_T02           
/home/sabine/data_img/data_momic/Controles/C1b/2010_02_05_MOMIC_TROOR_T01          
/home/sabine/data_img/data_momic/Patients/MM_Patients/P1/2010_02_26_MOMIC_FAILA_P03
/home/sabine/data_img/data_momic/Patients/MM_Patients/P3/2010_03_12_MOMIC_PRIMI_04 
/home/sabine/data_img/data_momic/Patients/MM_Patients/P8/2010_07_20_MOMIC_PRIST15  


out sur  oneB0 mrtrix

/home/sabine/data_img/data_momic/Controles/C1/2010_02_19_MOMIC_FEDES_T02           
/home/sabine/data_img/data_momic/Controles/C1b/2010_02_05_MOMIC_TROOR_T01          
/home/sabine/data_img/data_momic/Patients/MM_Patients/P1/2010_02_26_MOMIC_FAILA_P03
/home/sabine/data_img/data_momic/Patients/MM_Patients/P3/2010_03_12_MOMIC_PRIMI_04 
/home/sabine/data_img/data_momic/Patients/MM_Patients/P8/2010_07_20_MOMIC_PRIST15  


%no roi Decuss for :

/home/sabine/data_img/data_momic/Controles/C10/2011_02_17_MOMIC_MED_AM_34/Diff_ok/           
/home/sabine/data_img/data_momic/Controles/C2/2010_03_19_MOMIC_CERET_05/Diff_ok/             
/home/sabine/data_img/data_momic/Controles/C2b/2010_06_04_MOMIC_ELOMO_11/Diff_ok/            
/home/sabine/data_img/data_momic/Controles/C4/2010_04_16_MOMIC_ANCDI_07/Diff_ok/             
/home/sabine/data_img/data_momic/Controles/C6b/2010_10_22_MOMIC_LIVDA_21/Diff_ok/            
/home/sabine/data_img/data_momic/Controles/Ce1_g/2010_10_27_gm100481/Diff_ok/                
/home/sabine/data_img/data_momic/Controles/Ce2/2010_10_28_jb100487/Diff_ok/                  
/home/sabine/data_img/data_momic/Controles/PasTMSC7b/2010_10_29_MOMIC_GANPA/Diff_ok/         
/home/sabine/data_img/data_momic/Patients/MM_Patients/P10/2011_02_17_MOMIC_MED_AM_34/Diff_ok/
/home/sabine/data_img/data_momic/Patients/MM_Patients/Pe1/2010_10_28_bp100488/Diff_ok/       

05/07/2012 refait le bedpostx de C10 c11 c12 c2b

mauvais placement sur dti tronc
2010_11_19_MOMIC_LIEPA_27                      C8 
2011_02_10_MOMIC_TIRAL_33     (limite)         C9    OK 1.5
2011_05_13_MOMIC_MALCL_37 ?? (limite)          C11    limite 1.5
2011_05_27_MOMIC_MANMA_39                      CnewC13   KO 1.5

2010_07_20_MOMIC_PRIST15                P8
2011_04_29_MOMIC_PRILA_36               P12     ok 1.5

Pe1 Ce1 ce2 //... limite (que le tronc) et pas la meme sequence
sujet dans nasdicom     2010_05_07_MOMIC_COLFR_09   pas pris en compte ???

Arg arg arg tous les unwarp d'avril etais faux (07/2012)
sabine@zig ~/data_momic/Controles > ls -ltr */2*/Dif*/*vox*.log
-rw-r--r-- 1 sabine users 3717 29 avril  2011 C1/2010_02_19_MOMIC_FEDES_T02/Diff_ok/voxel_shift_map.log
-rw-r--r-- 1 sabine users 3718 29 avril  2011 C1b/2010_02_05_MOMIC_TROOR_T01/Diff_ok/voxel_shift_map.log
-rw-r--r-- 1 sabine users 3666 29 avril  2011 Ce1_g/2010_10_27_gm100481/Diff_ok/voxel_shift_map.log
-rw-r--r-- 1 sabine users 3583 29 avril  2011 Ce2/2010_10_28_jb100487/Diff_ok/voxel_shift_map.log
-rw-r--r-- 1 sabine users 3672 29 avril  2011 C3b/2010_04_09_MOMIC_LUCCE_06/Diff_ok/voxel_shift_map.log
-rw-r--r-- 1 sabine users 3591 29 avril  2011 PasTMSC7b/2010_10_29_MOMIC_GANPA/Diff_ok/voxel_shift_map.log
-rw-r--r-- 1 sabine users 3670 29 avril  2011 C8b/2011_01_21_MOMIC_ZANJE_31/Diff_ok/voxel_shift_map.log
-rw-r--r-- 1 sabine users 3626 29 avril  2011 C5b/2010_09_03_MOMIC_CHUGU_19/Diff_ok/voxel_shift_map.log
-rw-r--r-- 1 sabine users 3616 29 avril  2011 C6b/2010_10_22_MOMIC_LIVDA_21/Diff_ok/voxel_shift_map.log
-rw-r--r-- 1 sabine users 3671 29 avril  2011 C5/2010_08_06_MOMIC_LESCH_T18/Diff_ok/voxel_shift_map.log
-rw-r--r-- 1 sabine users 3678 29 avril  2011 C8/2010_11_19_MOMIC_LIEPA_27/Diff_ok/voxel_shift_map.log
-rw-r--r-- 1 sabine users 3671 29 avril  2011 C6/2010_09_10_MOMIC_EDOGE_20/Diff_ok/voxel_shift_map.log
-rw-r--r-- 1 sabine users 3671 29 avril  2011 C5c/2010_11_26_MOMIC_LEJFR_29/Diff_ok/voxel_shift_map.log
-rw-r--r-- 1 sabine users 3685 29 avril  2011 C4c/2011_01_07_MOMIC_GENAL_30/Diff_ok/voxel_shift_map.log
-rw-r--r-- 1 sabine users 3651 29 avril  2011 C7c/2011_01_28_MOMIC_GRO_JE_32/Diff_ok/voxel_shift_map.log
-rw-r--r-- 1 sabine users 3662 29 avril  2011 C7/2010_11_05_MOMIC_MARMI_23/Diff_ok/voxel_shift_map.log
-rw-r--r-- 1 sabine users 3662 29 avril  2011 C9/2011_02_10_MOMIC_TIRAL_33/Diff_ok/voxel_shift_map.log
-rw-r--r-- 1 sabine users 3696 31 oct.   2011 C2/2010_03_19_MOMIC_CERET_05/Diff_ok/voxel_shift_map.log
-rw-r--r-- 1 sabine users 3628 31 oct.   2011 C3/2010_06_18_MOMIC_POPTR_12/Diff_ok/voxel_shift_map.log
-rw-r--r-- 1 sabine users 3673 31 oct.   2011 C4/2010_04_16_MOMIC_ANCDI_07/Diff_ok/voxel_shift_map.log
-rw-r--r-- 1 sabine users 3720 31 oct.   2011 C2b/2010_06_04_MOMIC_ELOMO_11/Diff_ok/voxel_shift_map.log
-rw-r--r-- 1 sabine users 3717 31 oct.   2011 C4b/2010_06_25_MOMIC_JACFR_13/Diff_ok/voxel_shift_map.log
-rw-r--r-- 1 sabine users 3802 31 oct.   2011 CnewC14/2011_07_01_MOMIC_ANCLA_40/Diff_ok/voxel_shift_map.log
-rw-r--r-- 1 sabine users 3766 31 oct.   2011 C11/2011_05_13_MOMIC_MALCL_37/Diff_ok/voxel_shift_map.log
-rw-r--r-- 1 sabine users 3786 31 oct.   2011 C12/2011_05_20_MOMIC_COUAD_38/Diff_ok/voxel_shift_map.log
-rw-r--r-- 1 sabine users 3800 31 oct.   2011 CnewC13/2011_05_27_MOMIC_MANMA_39/Diff_ok/voxel_shift_map.log
sabine@zig ~/data_momic/Controles > vi CnewC13/2011_05_27_MOMIC_MANMA_39/Diff_ok/voxel_shift_map.log
sabine@zig ~/data_momic/Controles > vi C4b/2010_06_25_MOMIC_JACFR_13/Diff_ok/voxel_shift_map.log
sabine@zig ~/data_momic/Controles > vi C12/2011_05_20_MOMIC_COUAD_38/Diff_ok/voxel_shift_map.log
sabine@zig ~/data_momic/Controles > cd ../Patients/MM_Patients/
sabine@zig ~/data_momic/Patients/MM_Patients > ls -ltr */2*/Dif*/*vox*.log
-rw-r--r-- 1 sabine users 3682 29 avril  2011 P3/2010_03_12_MOMIC_PRIMI_04/Diff_ok/voxel_shift_map.log
-rw-r--r-- 1 sabine users 3681 29 avril  2011 P8/2010_07_20_MOMIC_PRIST15/Diff_ok/voxel_shift_map.log
-rw-r--r-- 1 sabine users 3600 29 avril  2011 P1/2010_02_26_MOMIC_FAILA_P03/Diff_ok/voxel_shift_map.log
-rw-r--r-- 1 sabine users 3679 29 avril  2011 P7/2010_07_20_MOMIC_PRISE16/Diff_ok/voxel_shift_map.log
-rw-r--r-- 1 sabine users 3673 29 avril  2011 P5/2010_07_09_MOMIC_PRIGI_14/Diff_ok/voxel_shift_map.log
-rw-r--r-- 1 sabine users 3683 29 avril  2011 Pe1/2010_10_28_bp100488/Diff_ok/voxel_shift_map.log
-rw-r--r-- 1 sabine users 3659 29 avril  2011 P10/2011_02_17_MOMIC_MED_AM_34/Diff_ok/voxel_shift_map.log
-rw-r--r-- 1 sabine users 3681 29 avril  2011 P9/2010_07_23_MOMIC_PRIMA_17/Diff_ok/voxel_shift_map.log
-rw-r--r-- 1 sabine users 3659 29 avril  2011 P2/2010_04_23_MOMIC_PRIBE_08/Diff_ok/voxel_shift_map.log
-rw-r--r-- 1 sabine users 3775 31 oct.   2011 P11/2011_04_08_MOMIC_PRIMA_35/Diff_ok/voxel_shift_map.log
-rw-r--r-- 1 sabine users 3841 31 oct.   2011 P12/2011_04_29_MOMIC_PRILA_36/Diff_ok/voxel_shift_map.log



%process DTI tronc
suj=get_subdir_regex({'/home/sabine/data_img/data_momic/Controles','/home/sabine/data_img/data_momic/Patients/MM_Patients'},'^[CP]','^20');
dti = get_subdir_regex(suj,'DTI','AP'); 


p3 p8 sur le tronc


%shift une roi de 2 point (bad unwarp)
[p fn]=get_parent_path(ff)
for k=1:length(ff)    
    o=write_vol_to_roi(ff{k},0);    sp=mars_space(ff{k});
    pp=voxpts(o,sp);    pp(1,:)=pp(1,:)-2;
    p.XYZ=pp;    p.mat=sp.mat;    nroi = maroi_pointlist(p,'vox')
    no=maroi_matrix(nroi,sp);
    do_write_image(no,fn{k});
end
