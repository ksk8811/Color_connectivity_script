%function get_white_signla

data_path='/data1/rom/';

if ~exist('P')
  P = spm_select([1 Inf],'image','select images','',data_path);
end

roinoise = spm_select([1],'mat','Select noise ROI to view','',data_path);

VY = spm_vol(P);

Yg='';Yw='';Ygnobias='';Ywnobias='';

for k=1:length(VY)
  [p,f,e]=fileparts(VY(k).fname);
  Pgris = fullfile(p,['c1',f,e]);
  Pwhite= fullfile(p,['c2',f,e]);
  Pnobias = fullfile(p,['m',f,e]);
  Pgris_mask = fullfile(p,['gray',f,'_mask',e]);
  Pwhite_mask = fullfile(p,['white',f,'_mask',e]);  
  
  if ~exist(Pgris) | ~exist(Pwhite)
    fprintf('%s\n','You need to comput white and gray map (c1 and c2)');
  end
  
  % find the threshold for a given number of point
  vol=spm_vol(Pgris);dim=vol.dim;
  [Y,XYZ] = spm_read_vols(vol);
  yy=reshape(Y,[1 prod(dim)]);
  yy=sort(yy,2,'descend');
  seuil = num2str(yy(300000))
    
  
  func=['img>' seuil];
  %compute gray roi
  og = maroi_image(struct('vol', spm_vol(Pgris), 'binarize',1,...
			 'func', func'));
  og = maroi_matrix(og);
  
  d = ['c1',f]; l = d;  d = [d ' func: ' func];  l = [l '_f_' func];
  og = descrip(og,d);  og = label(og,l);
   
  do_write_image(og,Pgris_mask);
   
  %compute white roi

  % find the threshold for a given number of point
  vol=spm_vol(Pwhite);dim=vol.dim;
  [Y,XYZ] = spm_read_vols(vol);
  yy=reshape(Y,[1 prod(dim)]);
  yy=sort(yy,2,'descend');
  seuil = num2str(yy(300000))
  func=['img>' seuil];

  ow = maroi_image(struct('vol', spm_vol(Pwhite), 'binarize',1,...
			 'func', func'));
  ow = maroi_matrix(ow);
  
  d = ['c2',f]; l = d;  d = [d ' func: ' func];  l = [l '_f_' func];
  ow = descrip(ow,d);  ow = label(ow,l);

  do_write_image(ow,Pwhite_mask);
  
    
  %extract signal
  Yg = get_roi_data(og,VY(k),Yg,k);
  Yw = get_roi_data(ow,VY(k),Yw,k);
  Ygnobias = get_roi_data(og,spm_vol(Pnobias),Ygnobias,k);
  Ywnobias = get_roi_data(ow,spm_vol(Pnobias),Ywnobias,k);
  

end


for rk = 1:size(roinoise,1)
  roiN = maroi('load', deblank(roinoise(rk,:)));
  for vk=1:length(VY)
      %yn = y_struct(get_marsy(roiN, VY(vk), 'mean', 'v'));
      
      %Yn(rk).Y(vk,1) = yn.Y;   Yn(rk).Yvar(vk,1) = yn.Yvar;
      if vk==1; 
	Yn(rk) = get_roi_data(roiN,VY(vk),'',vk);
      else
	Yn(rk) = get_roi_data(roiN,VY(vk),Yn(rk),vk);
      end
      

  end
end



plot_white_gray_signal(Yw,Yg,Yn)
plot_white_gray_signal(Ywnobias,Ygnobias,Yn)

clear yg yw ygnobias ywnobias yn

