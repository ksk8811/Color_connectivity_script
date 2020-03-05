function Proi = sn_mask_create(sn_roi,VY)

  
[p_img,f_img,e_img]=fileparts(VY.fname);    

[pr,fr,er] = fileparts(sn_roi);  

Proi = fullfile(p_img,[fr,'_wi2_',f_img,e_img]);
Proi_hdr = fullfile(p_img,[fr,'_wi2_',f_img,'.hdr']);

sn_roi_img=fullfile(pr,[fr,'.img']);

if ~exist(sn_roi_img)
  fprintf('%s%s\n','First time so compute the image associate with the roi :',sn_roi);
  sn_roi_o = maroi('load', sn_roi);
  ow = maroi_matrix(sn_roi_o);
  do_write_image(ow,sn_roi_img);
end


if ~exist(Proi)

  fprintf('%s%s\n','First time so compute the inverse normalisation ',Proi);

  %get a unique name to create a directory to work in
  s=sprintf('%f',datenum(clock));
  mkdir (s);
  s=fullfile(pwd,s);
  
  sn_roi_img = fullfile(pr,[fr,'.img']);
  sn_roi_hdr = fullfile(pr,[fr,'.hdr']);

  copyfile(sn_roi_img,s);  copyfile(sn_roi_hdr,s);
  
  sn_roi_img = fullfile(s,[fr,'.img']);

  sn_roi_img_inv = fullfile(s,['w',fr,'.img']);
  sn_roi_img_inv_hdr = fullfile(s,['w',fr,'.hdr']);


  inv_seg = fullfile(p_img,[f_img '_seg_inv_sn.mat']);
  
  if ~exist(inv_seg) %then do the segmentation
 
    fprintf('%s%s\n','But before need to segment : ',VY.fname);

    load('job_segment.mat')
    jobs{1}.spatial{1}.preproc.data = {VY.fname};
    spm_jobman('run',jobs);
 
  end

  %in the fonct path 
  load('write_norm.mat')

  jobs{1}.spatial{1}.normalise{1}.write(1).subj.matname{1} = inv_seg;
  jobs{1}.spatial{1}.normalise{1}.write(1).subj.resample{1} = sn_roi_img;

  spm_jobman('run',jobs);
  movefile(sn_roi_img_inv,Proi);  movefile(sn_roi_img_inv_hdr,Proi_hdr);
  rmdir(s,'s');
end

