%function get_white_signla

data_path='/home/romain/data/rom/';

if ~exist('P')
  P = spm_select([1 Inf],'image','select images','',data_path);
end

if ~exist('roinoise')
  roinoise = spm_select([1 Inf],'mat','Select noise ROI to view','',data_path);
end
if ~exist('roigris')
  roigris =  spm_select([Inf],'mat','Select gray vol','',data_path);
end
if ~exist('roiwhite')
  roiwhite =  spm_select([Inf],'mat','Select white vol','',data_path);
end

VY = spm_vol(P);

%Yg='';Yw='';Ygnobias='';Ywnobias='';
clear Yg Ygnobias Yw Ywnobias

for rk = 1:size(roigris,1)

  for vk=1:length(VY)
    [p,f,e]=fileparts(VY(vk).fname);
    Pnobias = fullfile(p,['m',f,e]);

    roi_gris = deblank(roigris(rk,:));
    roi_white = deblank(roiwhite(rk,:));
    og = transform_sn_roi(roi_gris,VY(vk));
    ow = transform_sn_roi(roi_white,VY(vk));  
    
    %extract signal
    if vk==1; 
      Yg(rk) = get_roi_data(og,VY(vk),'',vk);
      Yw(rk) = get_roi_data(ow,VY(vk),'',vk);
      Ygnobias(rk) = get_roi_data(og,spm_vol(Pnobias),'',vk);
      Ywnobias(rk) = get_roi_data(ow,spm_vol(Pnobias),'',vk);
    else
    
      Yg(rk) = get_roi_data(og,VY(vk),Yg(rk),vk);
      Yw(rk) = get_roi_data(ow,VY(vk),Yw(rk),vk);
      Ygnobias(rk) = get_roi_data(og,spm_vol(Pnobias),Ygnobias(rk),vk);
      Ywnobias(rk) = get_roi_data(ow,spm_vol(Pnobias),Ywnobias(rk),vk);
    end

  end
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
plot_white_gray_signal(Ywnobias,Ygnobias,Yn,P)


clear yg yw ygnobias ywnobias yn

