
roi_sub_dir = 'roi_ex';
anat_subdir = {'anat','seg_spm8'};

roimni = spm_select([1 Inf],'image','Select image in MNI space ','',pwd);
roimni = cellstr(roimni);

suj_dir = spm_select([1 Inf],'dir','Select subject directories ','',pwd);

pp.wanted_number_of_file = 1;

for nbsuj = 1:size(suj_dir,1)
  anadir =  get_subdir_regex(suj_dir(nbsuj,:),anat_subdir{1})
  for kk=2:length(anat_subdir)
    anadir = get_subdir_regex(anadir,anat_subdir{kk});
  end

  mat_f = get_subdir_regex_files(anadir,'.*seg_inv_sn.mat',pp);
  
  job=job_write_norm(mat_f,roimni,[1 1 1],0,'inv_w');
  
  spm_jobman('run',job);  

  wmf = addprefixtofilenames(roimni,'inv_w');

  roi_suj_dir = fullfile(suj_dir(nbsuj,:),roi_sub_dir)
  if ~exist(roi_suj_dir)
    mkdir(s_dir{k},roi_sub_dir);
  end
  
  for kk = 1:length(wmf)
    [p f] = fileparts(wmf{kk});
    movefile(fullfile(p,[f,'.*']),roi_suj_dir);
  end

end
