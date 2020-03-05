
T1_dir = spm_select([1 Inf],'dir','Select anat directories ','',pwd);

roimni = spm_select([1 Inf],'image','Select Rois to put on anat ','',pwd);

T1_file_reg = {'^s.*img$'};
seg_inv_mat_reg = {'.*inv_sn\.mat$'};

for k=1:size(T1_dir,1)
  
  t1f = get_subdir_regex_files(deblank(T1_dir(k,:)),T1_file_reg)
  t1f=char(t1f);
  
  if size(t1f,1)~=1
    error('do not find one T1 images in dir %s ',deblank(T1_dir(k,:)));
  end
  
  segf =  get_subdir_regex_files(deblank(T1_dir(k,:)),seg_inv_mat_reg);

  if (isempty(segf)) %do the segmentation
    
    p.norm.type = 'seg_and_norm';
    p.logfile='';
    
    job = do_normalize(t1f,p)
    spm_jobman('run',job)

    segf =  get_subdir_regex_files(deblank(T1_dir(k,:)),seg_inv_mat_reg);

  end
  
  segf=char(segf);
  
  %copy roi in T1 dir
  o_name='';
  for nr=1:size(roimni,1)
    [p,f,e]=fileparts(roimni(nr,:));
    copyfile(fullfile(p,[f,'.*']),deblank(T1_dir(k,:)));

    roi_o{nr} = fullfile(deblank(T1_dir(k,:)),[f,e]);
    
    o_name = [o_name,'_',f];
  end
  o_name = ['T1',o_name,'.nii'];
  
  %apply inv norm to roi
  pn.logfile='';
  pn.apply_norm.voxelsize = [NaN NaN NaN];
  pn.apply_norm.BoundingBox = [NaN NaN NaN;NaN NaN NaN];
  
  job = do_apply_normalize(char(segf),roi_o,pn,'')  ;
  spm_jobman('run',job)

  roi_o = addprefixtofilenames(roi_o,'w')
  
  in_f{1} =  t1f;
  in_f = [in_f roi_o];
  
  exp = 'i1';
  
  for nr=1:size(roimni,1)
    exp = sprintf('%s + i%d*1000',exp,nr+1);
  end
  
  job = job_image_calc(in_f,o_name,exp,1,4,deblank(T1_dir(k,:)))
  spm_jobman('run',job)

  
end
