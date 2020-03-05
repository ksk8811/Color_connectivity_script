function complete_roi_free

suj_dir = spm_select([1 Inf],'dir','Select subject directories ','',pwd);

  roi_to_intercept_left  = {'r_ctx-lh-G_frontal_middle\.nii','r_ctx-lh-G_frontal_superior\.nii','r_ctx-lh-S_central\.nii'};
  roi_to_intercept_right = {'r_ctx-rh-G_frontal_middle\.nii','r_ctx-rh-G_frontal_superior\.nii','r_ctx-rh-S_central\.nii'};

  
for nbsuj=1:size(suj_dir,1)
  d_left = get_subdir_regex(suj_dir(nbsuj,:),'cortex_dti','left');
  d_right = get_subdir_regex(suj_dir(nbsuj,:),'cortex_dti','right');

  if ( isempty(d_left)) |  (isempty(d_right) )
    error('je ne trouve pas de repertoire cotex_dit left ou cortex_dti right');
  end

  f_left = get_subdir_regex_files(d_left,{'.*nii$','.*img$'});
  f_right = get_subdir_regex_files(d_right,{'.*nii$','.*img$'});


  fo_l = combine_mask(cellstr(char(f_left)),'|',0,'All_roi_Left.nii');
  fo_r = combine_mask(cellstr(char(f_right)),'|',0,'All_roi_Right.nii');

  p.wanted_number_of_file=1;


  for kk=1:2
    for kkk=1:length(roi_to_intercept_left)
      if kk==1
	f_inter = get_subdir_regex_files(get_subdir_regex(suj_dir,'cortex_dti'),roi_to_intercept_left{kkk},p);
	f_inter = {f_inter{1},fo_l}    
      else
	f_inter = get_subdir_regex_files(get_subdir_regex(suj_dir,'cortex_dti'),roi_to_intercept_right{kkk},p);      
	f_inter = {f_inter{1},fo_r}    
      end

      fff = combine_mask(f_inter,'|~',0);

      fffe=addprefixtofilenames(fff,'erod_');

      cmd = sprintf('fslmaths %s -ero %s -odt short', fff,fffe); unix(cmd);      
      cmd = sprintf('fslmaths -dt input %s -dilM %s', fffe,fffe); unix(cmd);
      cmd = sprintf('gunzip %s.gz',fffe); unix(cmd);
    
    end
  end
  
end

