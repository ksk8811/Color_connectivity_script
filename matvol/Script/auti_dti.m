suj = get_subdir_regex('/export/home/romain.valabregue/datas/authi/suj','AUTI');
%suj = get_subdir_regex('/export/home/romain.valabregue/datas/authi/suj',{'P3','T1[234567]'});
dti = get_subdir_regex(suj,'DTI')
anat = get_subdir_regex(suj,'anat');anat2 = get_subdir_regex(anat,'vbm');
dwi = get_subdir_regex(suj,'Dwi')
anatf = get_subdir_regex(suj,'freesurfer')
roi = get_subdir_regex(suj,'roifree$');
probdir = get_subdir_regex(dti,'probtrac')

%anat coregister
fa1 = get_subdir_regex_files(anat,'^M',1);
fa2 = get_subdir_regex_files(anat,'^t2',1);
fb0 = get_subdir_regex_files(dti,'^meanth',1);

j = job_coregister(fa1,fa2)
spm_jobman('run',j)
j=job_coregister(fa2,fb0,fa1)
spm_jobman('run',j)

%get freesurfer
[pp sujn] = get_parent_path(suj);
sujf = get_subdir_regex_one('/export/home/romain.valabregue/datas/authi/freesurf',sujn)
anaf = get_subdir_regex(sujf,'mri');
volfree = get_subdir_regex_files(anaf,{'aparc.a2009s.aseg.mgz','brainmask.mgz','T1.mgz','orig.mgz','wmparc.mgz','ribbon.mgz'});

%redoo freesuj that do not have the a2009 volme
[volfree no ] = get_subdir_regex_files(anaf,{'aparc.a2009s.aseg.mgz'});
[pp sujagain] = get_parent_path(no,2)     
anatagain = get_subdir_regex('/export/home/romain.valabregue/datas/authi/suj',sujagain,'anat');
fa=get_subdir_regex_files(anatagain,'M')

sujf = get_subdir_regex_one('/export/home/romain.valabregue/datas/authi/freesurf',sujagain)
r_movefile(sujf,'/export/home/romain.valabregue/datas/authi/freesurf/TRASH','move')

par.free_sujdir = '/export/home/romain.valabregue/datas/authi/freesurf';par.sge_queu = 'workq';
par.version_path='source $HOME/bin/freesurfer5';
do_freesurfer(fa,par)

%en attendant ne faire que sur les sujet qui ont le a2009
volfree = get_subdir_regex_files(anaf,{'aparc.a2009s.aseg.mgz'}); %il ne reste que ceux qui existent
sujf=get_parent_path(volfree,2)
anaf = get_subdir_regex(sujf,'mri');
volfree = get_subdir_regex_files(anaf,{'aparc.a2009s.aseg.mgz','brainmask.mgz','T1.mgz','orig.mgz','wmparc.mgz','ribbon.mgz'},8);
[pp sujn] = get_parent_path(sujf);
suj = get_subdir_regex('/export/home/romain.valabregue/datas/authi/suj',sujn);anat=get_subdir_regex(suj,'anat')
anatf = r_mkdir(suj,'freesurfer')
r_movefile(volfree,anatf,'link')
volfree = get_subdir_regex_files(anatf,{'aparc.a2009s.aseg.mgz','brainmask.mgz','T1.mgz','orig.mgz','wmparc.mgz','ribbon.mgz'},8);
convert_mgz2nii(volfree)
volfree = get_subdir_regex_files(anatf,{'aparc.a2009s.aseg.nii','brainmask.nii','T1.nii','orig.nii','wmparc.nii','ribbon.nii'},8);

%coregister on original T1 (should not appen if freesurfer handel nifti corectly but to chech
other = get_subdir_regex_files(anatf,{'aparc.a2009s.aseg.nii','brainmask.nii','T1.nii','wmparc.nii','ribbon.nii'},7);
forig = get_subdir_regex_files(anatf,{'orig.nii'},1);
fa = get_subdir_regex_files(anat,'^M',1);
j = job_coregister(forig,fa,other)
spm_jobman('run',j)


%freesurfer label to roi
label_todo= {[11103],[ 11108], [11128,11168], [11129],[11146],[11169],[11170]};
roiname = {'Left_mot_03','Left_mot_08','Left_mot_28_68','Left_mot_29','Left_mot_46','Left_mot_69','Left_mot_70',}
label_todo= [label_todo {[12103],[ 12108], [12128,12168], [12129],[12146],[12169],[12170]}];
roiname = [roiname {'Right_mot_03','Right_mot_08','Right_mot_28_68','Right_mot_29','Right_mot_46','Right_mot_69','Right_mot_70',}];
%label_todo= [label_todo {[50,58],[11,26],18,54}];
%roiname = [roiname {'Right_Caudate_Accumbens', 'Left_Caudate_Accumbens','Left_Amygdala','Right_Amygdala'}];
label_todo= [label_todo {[50],[11],18,54}];
roiname = [roiname {'Right_Caudate', 'Left_Caudate','Left_Amygdala','Right_Amygdala'}];

roiname =  [roiname {'Left_mot_28','Left_mot_68','Right_mot_28','Right_mot_68'} ];
label_todo= [label_todo {11128,11168,12128,12168}  ];
label_todo = [label_todo  {[11106, 11124, 11131, 11132,11163,11164,11165,11171],[12106, 12124, 12131, 12132,12163,12164,12165,12171],...
    [11112, 11113, 11114, 11140,11153],[12112, 12113, 12114, 12140,12153],[11174],[12174],[11121],[12121]} ];
roiname =  [roiname {'Left_OFC_cingAnt','Right_OFC_cingAnt','Left_LatIFG','Right_LatIFG','Left_STS','Right_STS'...
    ,'Left_Fusi','Right_Fusi'}]

%A ajouter : %11107 Left_mot_07 %29 + 69 + 70 une seule region
%11116 Left_mot_16 a intercepter mask SMA PM

roiname = [roiname {'Left_mot_07','Right_mot_07','Left_mot_29_69_70','Right_mot_29_69_70','Left_mot_16','Right_mot_16'}];
label_todo = [label_todo {11107,12107,[11129,11169,11170],[12129,12169,12170],11116,12116}];

volfree=get_subdir_regex_files(anatf,'2009.*nii',1);
roi = r_mkdir(suj,'roifree');
write_multiple_mask(volfree,label_todo,roiname,roi,'3dcalc')

%denormalise SMA aal and intercept with mot_16
faal=get_subdir_regex_files('/export/home/romain.valabregue/datas/authi/atlas','SMA');
faal=get_subdir_regex_files('/export/home/romain.valabregue/datas/authi/atlas/amy_prob','Amy.*_100.nii');
anat = get_subdir_regex(suj,'anat','vbm8')
r_movefile(repmat(faal,size(anat)),anat,'link')                                      

iy = get_subdir_regex_files(anat,'^iy',1); faal = get_subdir_regex_files(anat,{'Amy','SMA'},5);j=job_vbm8_create_wraped(iy,faal);  spm_jobman('run',j)      
faal = get_subdir_regex_files(anat,{'^w.*Amy','^w.*SMA'},5);    froi = get_subdir_regex_files(roi,'Left_mot_16',1);
do_fsl_reslice(faal,froi,struct('prefix','rfree','interp_fsl','nearestneighbour'))

faal=get_subdir_regex_files(anat,'rfreewSMAL',1);froi = get_subdir_regex_files(roi,'Left_mot_16',1);
fo = addsufixtofilenames(roi,'/Left_mot_16_aal');do_fsl_mult(concat_cell(froi,faal),fo)
faal=get_subdir_regex_files(anat,'rfreewSMAR',1);froi = get_subdir_regex_files(roi,'Right_mot_16',1);
fo = addsufixtofilenames(roi,'/Right_mot_16_aal');do_fsl_mult(concat_cell(froi,faal),fo)
ff=get_subdir_regex_files(roi,'aal',2); unzip_volume(ff)
dd=r_mkdir(roi,'notused');ff=get_subdir_regex_files(roi,'mot_16.nii'); r_movefile(ff,dd,'move');

ff=get_subdir_regex_files(roi,'nii$'); gzip_volume(ff)     ; 

%%% ROI motor, sum of all
fml = get_subdir_regex_files(roi,'Left_mot_',12);fmr = get_subdir_regex_files(roi,'Right_mot_',12);
ffol=addsufixtofilenames(roi,'/Left_motor');ffor=addsufixtofilenames(roi,'/Right_motor');
do_fsl_add([fml fmr],[ffol ffor])
do_fsl_bin([ffol ffor])


%norm T2 vbm8
anat2=r_mkdir(anat,'vbm8_T1');
r_movefile(fa,anat2,'link')
fa2 = get_subdir_regex_files(anat2,'^M'); %fa2 = get_subdir_regex_files(anat2,'t2')
j=job_vbm8(fa2)
%arg ca ne marche pas sur les T2, jeffface et je fais sur les T1
%>> do_delete(anat2)

%Run probtrack
ref=get_subdir_regex_files(dti,'meanth',1);src = get_subdir_regex_files(roi,'Left_Amy',1);
tmout = addsufixtofilenames(roi,'/T1_2_DTI_transfo.txt');
do_fsl_transformation_matrix(src,ref,tmout)
 
par.sge =1;par.type = 'classification';par.sge_queu='long';
par.xfm = get_subdir_regex_files(roi,'T1_2_DTI',1);

trackdir = get_subdir_regex(dti,'bedpostdir\.bedpostX'); 
probdir = r_mkdir(dti,'probtrac')

Rtargets = get_subdir_regex_files(roi,{['Right_[FLmOS]']},17);Rseed = get_subdir_regex_files(roi,{['^Right_Amyg']},1);
Ltargets = get_subdir_regex_files(roi,{['^Left_[FLmOS]']},17);Lseed = get_subdir_regex_files(roi,{['^Left_Amyg']},1);
Routdir = r_mkdir(probdir,'clss_rh_Amyg_all');Loutdir = r_mkdir(probdir,'clss_lh_Amyg_all');

par.target = Ltargets;
process_probtrack(Lseed,Loutdir,trackdir,par);
par.target = Rtargets;
process_probtrack(Rseed,Routdir,trackdir,par)

%STAT probtrack
clear par
%faut reslicer les FA sur la T1 
%par.wm = get_subdir_regex_files(dti,'FA',1); par.wm_name = {'FA'}; %par.thebiggest = 'the_biggest';
[pp sujname] = get_parent_path(suj);

faal=get_subdir_regex_files(anat2,{'^rfreew.*Amy'},3);
%par.thebiggest = 'the_biggest';
par.wm = faal;par.wm_name = {'CM_prob','LB_prob','SF_prob'};

pdir = {'clss_lh_Amyg_all','clss_rh_Amyg_all'}; p = 1:32;c=33:54; 
    for k=1:length(pdir)
        outdir = get_subdir_regex(probdir,pdir(k));
        cout = get_val_from_probtrack(outdir,par);
        cout.suj = sujname; cout.pool = pdir{k};
        cpat = reduce_cell(cout,c);ccont = reduce_cell(cout,p);
        cpat.pool = ['patient_' cpat.pool];ccont.pool = ['control_' ccont.pool];       
        CC = [cpat ccont];
        write_res_to_csv(CC,'Amyg.csv')
    end


%dti preproc
%r_movefile(repmat(bvec,size(dti)),dti,'copy')

f=get_subdir_regex_files(dti,'^4D')
par.sge=-1; 
j = do_fsl_bet(f,par);
j = do_fsl_dtieddycor(f,par,j);
f=addsufixtofilenames(f,'_eddycor')
par.sge=1;par.sge_queu='medium';
par.mask = addsufixtofilenames(dti,'/nodif_brain_mask');
%par.software_path = '#source $HOME/bin/fsl_path';
j = do_fsl_dtifit(f,par,j);

fdti = get_subdir_regex_files(dti,'4D_eddycor.nii.gz',1)
whos

%make the meanB0
fd=get_subdir_regex_files(dti,'^4D_eddycor.ni',1);
par.do4D=0;
transform_4D_to_oneB04D(fd,par)


%initial_ import
f=get_subdir_regex_files(pwd,'.*nii');
[pp fn] = get_parent_path(f); fn =cellstr(char(fn))

for k=1:length(fn)
    ind=findstr(fn{k},'_');
    fo{k} = fn{k}(1:ind(2)-1);
end

[b i j ]= unique(char(fo),'rows')
suj=cellstr(b)
outdir ='/mnt/home/romain.valabregue/datas/authi/';
sujo = '/mnt/home/romain.valabregue/datas/authi/suj'; % outdir = '/servernas/images5/romain/julie/data'; sujo = r_mkdir(outdir,suj)

for k=1:length(suj)
    %ss = addprefixtofilenames(suj(k),sprintf('P%.2d_',k+29));
    ss = addprefixtofilenames(suj(k),sprintf('T%.2d_',k+11));
    sso = r_mkdir(outdir,ss);
    ff=get_subdir_regex_files(pwd,[suj{k} '.*nii']);
    r_movefile(ff,sso,'link')
end


%suj = get_subdir_regex('/servernas/images5/romain/authi/suj','AUTI');
suj = get_subdir_regex('/mnt/home/romain.valabregue/datas/authi/','AUTI');
dti = r_mkdir(suj,'DTI');
fdti = get_subdir_regex_files(suj,'diff_1.7_rolled_',6)
fo=addsufixtofilenames(dti,'/4D')
do_fsl_merge(fdti,fo)

dtib3 = r_mkdir(suj,'Dwi_B3000');
fdti = get_subdir_regex_files(suj,'b3000_rolled_j0',6)
fo=addsufixtofilenames(dtib3,'/4D')

dd = r_mkdir(suj,'anat');
fdti = get_subdir_regex_files(suj,'t2_spc_ns_sag',1)
fo=addsufixtofilenames(dd,'/t2_spc_ns_sag')
fdti = get_subdir_regex_files(suj,'MDEFT3D',1)
fo=addsufixtofilenames(dd,'/MDEFT3D')

ff=get_subdir_regex_files(suj,'^t*')
do_delete(ff);

%initial import B3000
bv=get_subdir_regex_files(dti,'bv',2);r_movefile(bv,dwi,'copy');  %cpoy the bvec bval from dti
fb0 = get_subdir_regex_files(dti,'meantheB',1);
fdwi = get_subdir_regex_files(dwi,'^4D.nii',1)
do_fsl_reslice(fdwi,fb0,'rB1000','nearestneighbour')
fdwi = get_subdir_regex_files(dwi,'^rB10004D.nii',1)
ff=concat_cell(fb0,fdwi); fout = addsufixtofilenames(dwi,'/mB0_1000_4D');  do_fsl_merge(ff,fout);

bval = get_subdir_regex_files(dwi,'bval');bvec = get_subdir_regex_files(dwi,'bvec');
for k=1:length(bval)
 l=load(bval{k});l=[0 ;l]*3; save(bval{k},'l','-ascii');
 l=load(bvec{k});l=[[0 0 0] ;l]; save(bvec{k},'l','-ascii');
 endq


f  =get_subdir_regex_files(dwi,'^mB0_1000_4D.nii.gz',1)

