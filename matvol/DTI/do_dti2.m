
rootdirspm = '/nasDicom/spm_raw/PROTO_MOMIC';
rootdirdic = '/nasDicom/dicom_raw/PROTO_MOMIC';

rootout = '/home/romain/images5/MOMIC/TEST';

suj_reg = {'romain'};

reg_dti_dir = 'b1500.*1_7x2iso$';

reg_gre_dir = 'GRE';

dti_subdir = 'DTI2';

par.skip_vol = '';

par.do_bet=1; par.do_eddcor=1; par.correct_bvec=1; 
par.do_unwrap=1; par.do_fit=1; par.do_bedpost = 0;

par.queu = 'server_ondule';
par.data_to_fit = '4D_eddycor_unwarp';

suj_dir = get_subdir_regex(rootdirspm,suj_reg)
[pp sujname] = get_parent_path(suj_dir);

for nbsuj=1:length(suj_dir)
  
  dti_dirs = get_subdir_regex(rootdirspm,sujname{nbsuj},reg_dti_dir);
  suj_dic_dir = get_subdir_regex(rootdirdic,sujname{nbsuj});
  
  dti_files = get_subdir_regex_files(dti_dirs,'.*img$')
  
  bval_f = get_subdir_regex_files(suj_dic_dir,[reg_dti_dir(1:end-1) '.*bvals$']);
  bvec_f = get_subdir_regex_files(suj_dic_dir,[reg_dti_dir(1:end-1) '.*bvecs$']);
  
  new_dti_dir = fullfile(rootout,sujname{nbsuj},dti_subdir);
  
  
  if par.do_unwrap==1;
    ser_FM=get_subdir_regex(suj_dir,reg_gre_dir)
    mag =  get_subdir_regex_files(ser_FM{1},'^s.*01\.img');
    phase = get_subdir_regex_files(ser_FM{2},'^s.*img');
    par.inmag = char(mag);      par.inphase = char(phase);     
    par.tediff = 2.46;      par.esp = 0.36;      par.unwarp_outvol = '4D_eddycor_unwarp';
    par.unwarpdir = 'y-'; %Use x, y, z, x-, y- or z- only.
  end
  
  dti_import(dti_files,bval_f,bvec_f,new_dti_dir,par);
  dti_preproc(new_dti_dir,sujname{nbsuj},par);
  
end
