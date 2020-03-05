
rootdirspm = '/nasDicom/spm_raw/PROTO_MOMIC';
rootdirdic = '/nasDicom/dicom_raw/PROTO_MOMIC';

rootout = '/home/romain/images5/MOMIC/TEST';

suj_reg = {'romain'};

reg_dti_dir = 'b1500.*1_7x2iso$';
reg_dti_dir = 'b1500.*1_7iso$';

reg_gre_dir = 'GRE';
reg_gre_dir = 'b0_mapping_3';

dti_subdir = 'DTI';

suj_dir = get_subdir_regex(rootdirspm,suj_reg)

par.skip_vol = '';

par.do_merge=1;  par.do_bet=1; par.do_eddcor=1; par.correct_bvec=1; 
par.do_unwrap=1; par.do_fit=1; par.do_bedpost = 0;

%par.do_merge=0;  par.do_bet=0; par.do_eddcor=0; par.do_fit=0;

par.queu = 'server_ondule';
par.data_to_fit = '4D_eddycor_unwarp';

for nbsuj=1:length(suj_dir)

  sujdir = suj_dir{nbsuj};
  [p f] = fileparts(sujdir);[p sujname] = fileparts(p);
  
  dti_dirs = get_subdir_regex(rootdirspm,sujname,reg_dti_dir);
  suj_dic_dir = get_subdir_regex(rootdirdic,sujname);
  
  dti_files = get_subdir_regex_files(dti_dirs,'.*img$')
  
  bval_f = get_subdir_regex_files(suj_dic_dir,[reg_dti_dir(1:end-1) '.*bvals$']);
  bvec_f = get_subdir_regex_files(suj_dic_dir,[reg_dti_dir(1:end-1) '.*bvecs$']);
  
  new_dti_dir = fullfile(rootout,sujname,dti_subdir);
  
  
  if par.do_unwrap==1;
    ser_FM=get_subdir_regex(sujdir,reg_gre_dir)
    mag =  get_subdir_regex_files(ser_FM{1},'^s.*01\.img');
    phase = get_subdir_regex_files(ser_FM{2},'^s.*img');
    par.inmag = char(mag);      par.inphase = char(phase);     
    par.tediff = 2.46;      par.esp = 0.36;      par.unwarp_outvol = '4D_eddycor_unwarp';
    par.unwarpdir = 'y-'; %Use x, y, z, x-, y- or z- only.
  end
  
  process_dti(dti_files,bval_f,bvec_f,new_dti_dir,sujname,par);
  
end
