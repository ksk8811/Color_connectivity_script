
data_path='/data1/rom/';

if ~exist('P')
  P = spm_select([1 Inf],'image','select images','',data_path);
end
VY = spm_vol(P);

roilist = spm_select([1 3],'mat','Select Noise White Gray noise ROI to view','',data_path);

if size(roilist,1)==1

  roiN = maroi('load', deblank(roilist(1,:)));
  
  roilist = spm_select([2],'image','Select Gray White mask for roi','',data_path);
  Pg = deblank(roilist(1,:));
  Pw = deblank(roilist(2,:));

  roiW = maroi_image(struct('vol', spm_vol(Pw), 'binarize',1,'func', 'img>0.1'));
  roiW = maroi_matrix(roiW);
  roiG = maroi_image(struct('vol', spm_vol(Pg), 'binarize',1,'func', 'img>0.1')); 
  roiG = maroi_matrix(roiG);
else
  
  roiN = maroi('load', deblank(roilist(1,:)));
  roiW = maroi('load',deblank(roilist(2,:)));
  roiG = maroi('load',deblank(roilist(3,:)));
end


for k=1:length(VY)

yw(k) = y_struct(get_marsy(roiW, VY(k), 'mean', 'v'));
yg(k) = y_struct(get_marsy(roiG, VY(k), 'mean', 'v'));
yn(k) = y_struct(get_marsy(roiN, VY(k), 'mean', 'v'));

end

plot_white_gray_signal(yw,yg,yn)
