filename = '/home/yulia/data/tourette/bad_slice_trie_yw.xls';

rootdirspm = '/nasDicom/spm_raw/PROTO_SL_TOURETTE';
rootdirdic = '/nasDicom/dicom_raw/PROTO_SL_TOURETTE';
rootout = '/home/yulia/data/tourette';

reg_gre_dir = 'GRE_FIELD';

dti_subdir = 'DTI_fsl';

par.skip_vol = '';

par.do_merge=0;  par.do_bet=0; par.do_eddcor=0; par.correct_bvec=0; 
par.do_unwrap=0; par.do_fit=0; par.do_bedpost = 1;  par.sge=0;

%par.do_merge=0;  par.do_bet=0; par.do_eddcor=0; par.do_fit=0;

par.queu = 'server_ondule';
par.data_to_fit = '4D_eddycor_unwarp';
%par.data_to_fit = '4D_eddycor';


[NUMERIC,TXT,RAW]=xlsread(filename);


nsuj=0;
for n=3:size(RAW,1)
  if ~isnan(RAW{n,2})
    nsuj = nsuj+1;
    suj(nsuj).name = [RAW{n,2} '_' RAW{n,3}] ;
    suj(nsuj).ser  = RAW{n,4};
    suj(nsuj).id = RAW{n,3};

    if ~isnan(RAW{n,9})
      vol = str2num(RAW{n,9}(2:3));
      kk=9;
      while ~isnan(RAW{n,kk})
        vol(end+1) = str2num(RAW{n,kk}(2:3));
        kk=kk+1;
        if kk>size(RAW,2)
          RAW{n,kk}=NaN;
        end
      end
      vol = unique(vol);
      suj(nsuj).vol = vol;

    end
  end

end

for k=1:length(suj) 
  dti_dir=get_subdir_regex(rootdirspm,suj(k).name,[suj(k).ser,'$']);
  dti_files = get_subdir_regex_files(dti_dir,'.*img$');

  suj_dir = get_subdir_regex(rootdirspm,suj(k).name);
  dicdir = get_subdir_regex(rootdirdic,suj(k).name);
  bval_f = get_subdir_regex_files(dicdir,'bvals$');
  bvec_f = get_subdir_regex_files(dicdir,'bvecs$');

  if isempty(bval_f)
    bval_f = get_subdir_regex_files(suj_dir,'bvals$');
    bvec_f = get_subdir_regex_files(suj_dir,'bvecs$');
  end    
  
  new_dti_dir = fullfile(rootout,suj(k).name,dti_subdir);

  par.skip_vol = suj(k).vol;
  sujname = [suj(k).id];
  
  if par.do_unwrap==1;
    ser_FM=get_subdir_regex(suj_dir,reg_gre_dir)
    mag =  get_subdir_regex_files(ser_FM{1},'^s.*01\.img');
    phase = get_subdir_regex_files(ser_FM{2},'^s.*img');
    par.inmag = char(mag);      par.inphase = char(phase);     
    par.tediff = 2.46;      par.esp = 0.35;      par.unwarp_outvol = '4D_eddycor_unwarp';
    par.unwarpdir = 'y-'; %Use x, y, z, x-, y- or z- only.
  end

  process_dti(dti_files,bval_f,bvec_f,new_dti_dir,sujname,par);
  
end
