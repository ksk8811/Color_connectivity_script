%function get_white_signla

data_path='/home/romain/data/rom/';

if ~exist('P')
  P = spm_select([1 Inf],'image','select images','',data_path);
end

if ~exist('roinoise')
  roinoise = spm_select([1 Inf],'mat','Select noise ROI to view','',data_path);
end
if ~exist('roigris')
  roigris =  spm_select([1],'mat','Select gray vol','',data_path);
end
if ~exist('roiwhite')
  roiwhite =  spm_select([1],'mat','Select white vol','',data_path);
end

VY = spm_vol(P);

Yg='';Yw='';Ygnobias='';Ywnobias='';


for k=1:length(VY)
  [p,f,e]=fileparts(VY(k).fname);

  Pnobias = fullfile(p,['m',f,e]);

  og =  maroi('load',roigris);
  og = spm_hold(og,0);

  ow =  maroi('load',roiwhite);
  ow = spm_hold(ow,0);

  %extract signal
  Yg = get_roi_data(og,VY(k),Yg,k);
  Yw = get_roi_data(ow,VY(k),Yw,k);
%  Ygnobias = get_roi_data(og,spm_vol(Pnobias),Ygnobias,k);
%  Ywnobias = get_roi_data(ow,spm_vol(Pnobias),Ywnobias,k);

end

for rk = 1:size(roinoise,1)
  roiname = deblank(roinoise(rk,:));
  if findstr(roiname,'normalize')
    invNorm = 1;volNoise=0;
  elseif findstr(roiname,'volume_specific_noise')
    invNorm = 0;volNoise=1;
  else
    invNorm = 0;volNoise=0;
    roiN = maroi('load',roiname);
  end
  
  for vk=1:length(VY)
    if invNorm
      roiN =  transform_sn_roi(roiname,VY(vk));
    end
    if volNoise
      roiname = [VY(vk).fname(1:(end-4)),'_noise_roi.mat'];
      if ~exist(roiname)
	error('You must defined the nois roi %s',roiname)
      end
      roiN = maroi('load',roiname);
    end
    
    %      yn(rk,vk) = y_struct(get_marsy(roiN, VY(vk), 'mean', 'v'));
    if vk==1; 
      Yn(rk) = get_roi_data(roiN,VY(vk),'',vk);
    else
      Yn(rk) = get_roi_data(roiN,VY(vk),Yn(rk),vk);
    end
  end
end

plot_white_gray_signal(Yw,Yg,Yn,P)
%plot_white_gray_signal(Ywnobias,Ygnobias,Yn,P)


clear yg yw ygnobias ywnobias yn

