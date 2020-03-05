function write_roi_to_nii(P,fref)

if ~exist('P')
  P = spm_select([1 Inf],'mat','Select ROI to convert in ','',pwd);
end

if iscell(P)
   P = char(P);
end

for nr=1:size(P,1)
  roi = maroi('load',deblank(P(nr,:)));
  
  sp = mars_space(fref{nr})

  roi = maroi_matrix(roi,sp);
  roi_img = deblank(P(nr,:));
  roi_img(end-2:end) = 'img';
  
  do_write_image(roi,roi_img);
end
