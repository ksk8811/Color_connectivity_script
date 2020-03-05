
clear all
suj = get_subdir_regex({'/home/vera/data/IRMf_wada/CONTRL','/home/vera/data/IRMf_wada/SAH_D','/home/vera/data/IRMf_wada/SAH_G'},'WADA')

dti = get_subdir_regex(suj,'DTI$');
suj=get_parent_path(dti);

%get suj who do not heve roi_fonc2
[dti suj] = get_subdir_regex(suj,'fonc_roi2');

dti = get_subdir_regex(suj,'DTI$');
ana = get_subdir_regex(suj,'t1mpr');
fana = get_subdir_regex_files(ana,'^s.*img$',1);


%run freesurfer on the anat

par.free_sujdir = '/home/vera/data/IRMf_wada/freesurfer_dir';
par.free_cmd = 'freesurfer';
par.distrib.subdir = 'distrib';

do_freesurfer(fana,par)


%denormalize
%fb = get_subdir_regex_files('/home/vera/data/IRMf_wada/Anaprotowada/ROI_fonc_rename','^r.*')
fb = get_subdir_regex_files('/home/vera/data/IRMf_wada/Anaprotowada/ROI_fonc/second_test','^rr.*nii$')

sn = r_mkdir(suj,'fonc_roi2');
snn= r_movefile(fb{1},sn,'link');


aainv =  get_subdir_regex_files(ana,'.*_seg_inv_sn.mat',1);
%bmask =  get_subdir_regex_files(sn,'^rf.*img$',4);
bmask =  get_subdir_regex_files(sn,'^rr.*nii$',11);

par.interp = 0;par.prefix = 'iw_';

job = job_write_norm(aainv,bmask,par); 
%spm_jobman('interactive',job)
spm_jobman('run',job)

%copy T1 coregister to B0 
dti4D = get_subdir_regex_files(dti,{'4D_eddycor.nii'}) 
fB0 = do_fsl_roi(dti4D,'Bo_unwrap')

fB0 =  get_subdir_regex_files(dti,'Bo_unwrap',1);
fB0 = unzip_volume(fB0);
fB0 =  get_subdir_regex_files(dti,'Bo_unwrap.nii$',1);


anac = r_mkdir(suj,'anat_coreg_dti');
faa = get_subdir_regex_files(ana,'^s.*img$');r_movefile(faa,anac,'link')
faa = get_subdir_regex_files(ana,'^s.*hdr$');r_movefile(faa,anac,'copy')

fanac = get_subdir_regex_files(anac,'^s.*img$',1);
bmask =  get_subdir_regex_files(sn,'^iw.*nii$',11);

par.interp=0; par.type = 'estimate_and_write';par.prefix = 'rDTI_';

job = job_coregister(fanac,fB0,bmask,par); spm_jobman('run',job)


%get freesurfer T1 convert coregister to T1 (already in DTI space)
anac =get_subdir_regex(suj,'anat_coreg_dti');
%fanac = get_subdir_regex_files(anac,'^s.*img$',1);


%for denormalized roi after the anat coreg
bmask =  get_subdir_regex_files(sn,'^iw.*',11);
hdr_copy_nifti_header(bmask,fanac)

par.interp=0; par.type = 'write';par.prefix = 'rDTI_';

job = job_coregister(bmask,fB0,'',par); spm_jobman('run',job)

%do fsl dill 
bm2 = get_subdir_regex_files(sn2,'rDTI_iw_r.*nii',11); 
do_fsl_dill(bm2)



[p sujname] = get_parent_path(suj);

freesuj =get_subdir_regex_one('/home/vera/data/IRMf_wada/freesurfer_dir',sujname,'mri');
volfree = get_subdir_regex_files(freesuj,{'T1.mgz','aparc.aseg.mgz','aparc.a2005s.aseg.mgz'},3);

volfreen= r_movefile(volfree,anac,'link');
ff=convert_mgz2nii(volfreen);
%coreg free T1 to T1
fT1 = get_subdir_regex_files(anac,'^T1.nii',1);
fseg = get_subdir_regex_files(anac,'aseg.*nii',2);

par.type = 'estimate';
job = job_coregister(fT1,fanac,fseg,par); 
spm_jobman('run',job)

%extract label
volfree = get_subdir_regex_files(anac,'aparc.a2005s.aseg.nii');
label=  {[9,10],[48 49],17,53}; 
roiname = {'Left_thalamus','Right_Thalamus','Left-Hippocampus','Right-Hippocampus'};
% {17,53} hipo %,2006,1006,2007,1007}; {[9,10],[48 49]}
roiname = find_free_label_name(label);

sn = get_subdir_regex(suj,'fonc_roi$');
sn2 = get_subdir_regex(suj,'fonc_roi2');

write_multiple_mask(volfree,label,roiname,sn,'image_calc',fB0)

%DO PROBTRACK
par.delete_if_exist=1
for k=1:length(sn)

  trackdir = get_subdir_regex(dti{k},{'bedpostdir\.bedpostX'})

  par.type = 'classification';
  bm2 = get_subdir_regex_files(sn2{k},'^dill_rDTI_iw_r.*nii',11);
  bm1 = get_subdir_regex_files(sn{k},'^r_Left-Hippo.*nii',1);

  outdir1 = fullfile(dti{k},'Seed_Left_Hippo_roifonc2_dill_cla'); 
  process_probtrack(bm1,bm2,outdir1,trackdir,par)

  bm1 = get_subdir_regex_files(sn{k},'^r_Right-Hippo.*nii',1);

  outdir1 = fullfile(dti{k},'Seed_Rigth_Hippo_roifonc2_dill_cla'); 
  process_probtrack(bm1,bm2,outdir1,trackdir,par)

end









%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% EXTRACT THE STATS %%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
group = {'/home/vera/data/IRMf_wada/CONTRL','/home/vera/data/IRMf_wada/SAH_D','/home/vera/data/IRMf_wada/SAH_G'};

for nbgroup = 1:length(group)
  suj = get_subdir_regex(group{nbgroup},'WADA');
  dti = get_subdir_regex(suj,'DTI$');
  suj=get_parent_path(dti);

  [pp,sujname] = get_parent_path(suj);
  [ppp,poolnam] = fileparts(pp{1});
  
  cc.pool = poolnam;
  cc.suj = sujname;  

  ana = get_subdir_regex(suj,'');
  dti = get_subdir_regex(suj,'DTI$');
  dtiHR = get_subdir_regex(dti,'Seed_Rigth_Hippo_roifonc2_dill_cla');
  dtiHL = get_subdir_regex(dti,'Seed_Left_Hippo_roifonc2_dill_cla');
  
  sn  = get_subdir_regex(suj,'fonc_roi$');
  f_seed = get_subdir_regex_files(sn,'r_Right-Hippocampus',1);
  f_mask = get_subdir_regex_files(dti,'nodif_brain_mask',1);
  
  vol=do_fsl_getvol(f_mask);
  cc.mask_vol = vol(:,1);
  cc.mask_vol_mm = vol(:,2);
  
  vol=do_fsl_getvol(f_seed,0.5);
  cc.Rhipo_vol    = vol(:,1)';
  cc.Rhipo_vol_mm = vol(:,2)';

  par.name_prefix = 'RH_';
  cc =  get_val_from_probtrack(dtiHR,par,cc);

  f_seed = get_subdir_regex_files(sn,'r_Left-Hippocampus',1);
  vol=do_fsl_getvol(f_seed,0.5);
  cc.Lhipo_vol    = vol(:,1)';
  cc.Lhipo_vol_mm = vol(:,2)';

  par.name_prefix = 'LH_';
  cc =  get_val_from_probtrack(dtiHL,par,cc);
 
  c(nbgroup) = cc;
  clear cc;
end

write_conc_res_to_csv(c,'toto.csv')

k=1
cdd = [c(k), c(k+1), c(k+1), c(k+2), c(k), c(k+2)];
write_conc_res_summary_stat(cdd,'totoS.csv')


%freesurfer stats
for nbgroup = 1:length(group)
  suj = get_subdir_regex(group{nbgroup},'WADA');
  dti = get_subdir_regex(suj,'DTI$');

  [pp,sujname] = get_parent_path(suj);
  [ppp,poolnam] = fileparts(pp{1});

  cmd = sprintf('asegstats2table --meas volume --tablefile  %s  --subjects',poolnam);

  for kk=1:length(sujname)
    cmd = sprintf('%s %s',cmd,sujname{kk});
  end
  unix(cmd)
end

%le brainsegvol est different avec 
 mri_segstats --seg WADA_MORAL/mri/aparc+aseg.mgz --sum ~/ft --id 17 --id 53
 --brain-vol-from-seg --etiv --subject WADA_MORAL
 # SUBJECTS_DIR /home/vera/data/IRMf_wada/freesurfer_dir
# subjectname WADA_MORAL
# Measure BrainSegNotVent, BrainSegVolNotVent, Brain Segmentation Volume Without Ventricles, 8657.000000, mm^3
# Measure BrainSeg, BrainSegNVox, Number of Brain Segmentation Voxels,  654402, unitless
# Measure BrainSeg, BrainSegVol, Brain Segmentation Volume, 654402.000000, mm^3
# Measure IntraCranialVol, ICV, Intracranial Volume, 1112702.866058, mm^3
# ColHeaders  Index SegId NVoxels Volume_mm3 
  1  17      4310     4310.0                              par la methode asegstats2talbe    4170
  2  53      4347     4347.                               hmmm a verifier      4149
