function rout=write_vol_to_roi(f,do_save)

if ~exist('do_save')
  do_save=1;
end

if ~exist('f')
  f= spm_select([1 Inf],'image','select images','',pwd);
end

if iscell(f)
f=char(f);
end

vol=spm_vol(f);

for nbvol=1:length(vol)
  roi_fname=[vol(nbvol).fname(1:end-4),'_roi.mat']

  o = maroi_image(struct('vol', vol(nbvol), 'binarize',1,...
			 'func', 'img>0'));
  o = label(o,vol(nbvol).fname(1:end-4));

  o = spm_hold(o,0);
 
if do_save  
  saveroi(o, roi_fname);
end

  rout(nbvol) = o;

end
  
  
