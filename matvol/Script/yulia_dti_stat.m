function cOUT = yulia_dti_stat()

for nbgrp= 1:2
  if nbgrp==2
    suj = get_subdir_regex('/servernas/images/yulia/DTI_fsl','oure.*p$');suj(3)='';
    OUT.pool='patient';
  else
    OUT.pool='control';
    suj = get_subdir_regex('/servernas/images/yulia/DTI_fsl','oure.*t$');
  end

  dti = get_subdir_regex(suj,'DTI_fsl');
  sn  = get_subdir_regex(suj,'roi_yeb');
  [p,sujname]=get_parent_path(suj);
  %  fFA = get_subdir_regex_files(dti,'^S.*FA.nii$',1);
%  fFA = get_subdir_regex_files(dti,'^S.*_MD.nii$',1);
%  fFA = get_subdir_regex_files(dti,'^S.*_L1.nii.gz$',1);
  fFA = get_subdir_regex_files(dti,'^Lradial.nii.gz$',1);
  FAstr = 'Lr'; %'L1';% 'MD';
  ff=get_subdir_regex_files(sn,'img$',68);

  unzip_volume(fFA);
  fFA = get_subdir_regex_files(dti,'^Lradial.nii$',1);

  for nbsuj = 1:length(fFA)

    OUT.suj{nbsuj} = sujname{nbsuj}
    Y={};namefield={}; 
     for nbroi = 1:size(ff{nbsuj},1)
        [pp nameroi] = fileparts(ff{nbsuj}(nbroi,:));
        
	o = maroi_image(struct('vol', spm_vol(deblank(ff{nbsuj}(nbroi,:))), 'binarize',1,'func', 'img>0'));
        roivals = getdata(o,fFA{nbsuj}); 
	Y{end+1} = mean(roivals);	
        namefield{end+1} = [FAstr '_' nameroi];
        Y{end+1} = std(roivals)/mean(roivals);              
        namefield{end+1} = [FAstr 'std_' nameroi];

	Y{end+1} = volume(o);
        namefield{end+1} = ['Vol_' nameroi];
      end
    OUT = add_res_to_struct(OUT,namefield,Y)
  
  end
  
  cOUT(nbgrp) = OUT;
  clear OUT;
end

function c = add_res_to_struct(c,name,Y)

for k=1:length(name)
	if isfield(c,name{k})
		yy = getfield(c,name{k});
		yy(end+1) = Y{k};
		c = setfield(c,name{k},yy);
	else
		c = setfield(c,name{k},Y{k});
	end

end

