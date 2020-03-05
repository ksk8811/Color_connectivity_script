%%%%%first import
dti = r_mkdir(suj,'DTI_mb');

dti3D=get_subdir_regex(suj,'TR14$');

bvf = get_subdir_regex_files(dti3D,'bvecs',1);bvo = addsufixtofilenames(dti,'/bvecs');r_movefile(bvf,bvo,'copy')
bvf = get_subdir_regex_files(dti3D,'bvals',1);bvo = addsufixtofilenames(dti,'/bvals');r_movefile(bvf,bvo,'copy')

fdti3D = get_subdir_regex_files(dti3D,'f.*img')

fdti=addsufixtofilenames(dti,'/4D');

par.sge=-1; % do not write job
j = do_fsl_merge(fdti3D,fdti,par);
[j fmask] = do_fsl_bet(fdti,par,j);

[j fdti] = do_fsl_dtieddycor(fdti,par,j);

par.tediff = 2.46;par.esp=0.39;par.te=92;par.unwarpdir = 'y';
[j fdti] = do_fsl_dtiunwarp(fdti,fmdir,par,j);

par.sge=1;par.sge_queu='medium';par.walltime = '03:00:00'; %par.sge=1 so write job on the current directori   mkdir job;cd job
par.sge=0
par.mask = fmask;
j = do_fsl_dtifit(fdti,par,j);


%%%% go on with trackvis
fdti=get_subdir_regex_files
transform_4D_to_oneB04D(fdti)
fdti=get_subdir_regex_files
 process_trackvis(fdti)


%%%%%%import if multiple serie
% dtir3D = dti dirs of one sub
bvecf = get_subdir_regex_files(dti3D,'bvecs')
bvalf = get_subdir_regex_files(dti3D,'bvals')
dti_files = get_subdir_regex_files(dti3D,'.*img')
dti=r_mkdir(pwd,'DTI') 

%dti_import2(dti_files,bvalf,bvecf,dti)
dti_import_multiple(char(dti_files),char(bvalf),char(bvecf),char(dti))


