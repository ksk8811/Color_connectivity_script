
%rootdirspm = '/nasDicom/spm_raw/PROTO_MOMIC';
%rootdirdic = '/nasDicom/dicom_raw/PROTO_MOMIC';
rootout = '/home/romain/images5/MOMIC';
dti_subdir = 'DTI';
reg_dti_dir = 'b1500_o.._1_7.*iso$';
reg_bvals = 'b1500_o';
reg_gre_dir = 'S2.*GRE';

reg_dti_dir = '^S21';
reg_bvals =  '^S21';
reg_gre_dir = 'S5.*GRE';
dti_subdir = 'DTI_S21_1.5_1.5_3';

reg_dti_dir = '^S03';
reg_bvals =  '^S03';
reg_gre_dir = 'S2.*GRE';
dti_subdir = 'DTI_S03_RL';


rootout = '/home/romain/images5/MOMIC';
reg_dti_dir = '^S30'; %reg_dti_dir = 'b1500_o.._1_7.*iso$';
reg_bvals = '^S30';
reg_gre_dir = 'GRE';
dti_subdir = 'DTI_1.2';

reg_dti_dir = 'b1500_o.._1_7.*iso$';
reg_bvals = 'b1500_o';
reg_gre_dir = 'GRE';
dti_subdir = 'DTI_all_brain_1.7';

suj_dir=char(get_subdir_regex(rootout,'LUCCE'))

if ~exist('suj_dir')
  suj_dir = spm_select([1 Inf],'dir','Select subject directories ','',pwd);
end


for nbsuj=1:size(suj_dir,1)

  sujdir = deblank(suj_dir(nbsuj,:));
  [p f] = fileparts(sujdir);[p sujname] = fileparts(p);
  
  dti_dirs = get_subdir_regex(sujdir,reg_dti_dir);
  
  dti_files = get_subdir_regex_files(dti_dirs,'.*img$')
  
  bval_f = get_subdir_regex_files(sujdir,[reg_bvals '.*bvals$']);
  bvec_f = get_subdir_regex_files(sujdir,[reg_bvals '.*bvecs$']);
  
  new_dti_dir = fullfile(sujdir,dti_subdir);
  
  par.do_merge=1;  par.do_bet=1; par.do_eddcor=1; par.do_fit=1;
  par.do_merge=0;  par.do_bet=0; par.do_eddcor=0; par.do_fit=1;
  par.do_bedpost = 0;
  par.queu = 'server_ondule';
  par.data_to_fit = '4D_eddycor_unwrap';
  
  par.do_unwrap=0;
  ser_FM=get_subdir_regex(suj_dir,reg_gre_dir)
  mag =  get_subdir_regex_files(ser_FM{1},'^s.*01\.img');
  phase = get_subdir_regex_files(ser_FM{2},'^s.*img');

 
  par.inmag = char(mag);      par.inphase = char(phase);     
  par.tediff = 2.46;      par.esp = 0.27;      par.unwarp_outvol = '4D_eddycor_unwarp_plus';
  par.unwarpdir = 'y'; %Use x, y, z, x-, y- or z- only.

  
  keyboard
  
  process_dti(dti_files,bval_f,bvec_f,new_dti_dir,sujname,par);
  
end

if 0 %trackvis
fslroi ../4D_eddycor.nii bo1 0 1 
fslroi ../4D_eddycor.nii bo2 21 1 
fslroi ../4D_eddycor.nii bo3 43 1 

fslroi ../4D_eddycor.nii bd1 1 20
fslroi ../4D_eddycor.nii bd2 22 21
fslroi ../4D_eddycor.nii bd3 44 19

fslroi ../4D_eddycor.nii bo1 0 1 
fslroi ../4D_eddycor.nii bo2 20 1 
fslroi ../4D_eddycor.nii bo3 41 1 

fslroi ../4D_eddycor.nii bd1 1 19
fslroi ../4D_eddycor.nii bd2 21 20
fslroi ../4D_eddycor.nii bd3 42 21

fslmerge -t BOK   bo1 bo2 bo3 bd1 bd2 bd3 
rm  bo1* bo2* bo3* bd1* bd2* bd3* 

end
if 0
%same for HDtrack dti
  for nbsuj=1:size(suj_dir,1)

    dti_subdir = 'DTI_HDTRACK';

    sujdir = deblank(suj_dir(nbsuj,:));
    [p f] = fileparts(sujdir);[p sujname] = fileparts(p);
    
    dti_dirs = get_subdir_regex(sujdir,'PtkSms_TR11$');
    
    dti_files = get_subdir_regex_files(dti_dirs,'.*img$')
    
    bval_f = get_subdir_regex_files(sujdir,'PtkSms_TR11.*bvals$');
    bvec_f = get_subdir_regex_files(sujdir,'PtkSms_TR11.*bvecs$');
    
    new_dti_dir = fullfile(sujdir,dti_subdir);
    
    par.do_merge=1;  par.do_bet=1; par.do_eddcor=1; par.do_fit=1;
    par.do_bedpost = 1;
    par.queu = 'sta_irm';
    %    par.data_to_fit = '4D_eddycor';

    process_dti(dti_files,bval_f,bvec_f,new_dti_dir,sujname,par)
    
  end

end

  
