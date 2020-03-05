function FA_img_ok = extract_chri_NGC(ds)


T2_dir = '/images2/christine/HD_Track_2008/cartes_T2_FA_MD';
T2_roi_extract = '/images2/christine/HD_Track_2008/cartes_T2_FA_MD/roi_extract';


if ~exist('ds')
  ds = spm_select([1 Inf],'dir','Select subject s directories containing Intersect_NGC','',pwd); 
  %ds=get_subdir_regex('/images2/christine/HD_Track_2008/sympto','.*','Intersect_NGC');
end
 
if ~iscell(ds)
  ds = cellstr(ds);
end

ds = get_subdir_regex(ds,'Intersect_NGC');
 
dm = get_subdir_regex_files(ds,'.*\.img$');

fprintf('\n Found %d subjects that have mask \n\n',length(dm))

nbok=0;

for ks=1:length(dm)
  all_mask = dm{ks};
  [p f] = fileparts(all_mask(1,:));
  [p f] = fileparts(p);
  [p suj] = fileparts(p);
  
  suj_init = [suj(end-8:end-6),'_',suj(end-5:end-3),'_',suj(end-2:end)];

  FA_img = get_subdir_regex_files(T2_dir,{[suj_init,'.*img$'],[suj_init,'.*nii$']});
  
  if isempty(FA_img)
    fprintf('\n');
    warning('do not find images %s for suj %s',suj_init,suj)
    fprintf('\n');
  else
    if size(FA_img{1},1) ==0 %~= 3
      fprintf('\n');
      warning('ONLY %d images %s for suj %s',size(FA_img{1},1),suj_init,suj)
      char(FA_img)
      fprintf('\n');
    else
      nbok=nbok+1;
      FA_img_ok(nbok).mask = all_mask ; 
      FA_img_ok(nbok).FA_img = FA_img;
    end
  end
  
  
end

%get_the data
for ks = 1:length(FA_img_ok)

  mask = FA_img_ok(ks).mask;

  [p,f] = fileparts(mask(1,:));
  [p,f] = fileparts(p);   [p,suj] = fileparts(p); 
  FA_img_ok(ks).suj = suj;
  
  for nbr=1:size(mask,1)
    roi_o = write_vol_to_roi(mask(nbr,:));

    [p,roiname{nbr}] = fileparts(label(roi_o));
    oimg = FA_img_ok(ks).FA_img{1};
    if nbr==1
      for nbimg = 1:size(oimg,1)
	[p,oimgname{nbimg}] = fileparts(oimg(nbimg,:));
      end
    end
    
    roivol(nbr) =  volume(roi_o) ; 
    
    if volume(roi_o)==0
      fprintf('\n WARNING NO VOXEL in  roi %s\n',label(roi_o))
      ymean(nbr,nbimg) = 0;      yvar(nbr,nbimg) = 0;
    else

      for nbimg = 1:size(oimg,1)
	try
	  y = get_marsy(roi_o,spm_vol(oimg(nbimg,:)),'mean');
	catch
	  fprintf('\n WARNING NO interseption between %s and %s\n',oimg(nbimg,:),label(roi_o));
	  ymean(nbr,nbimg) = 0;      yvar(nbr,nbimg) = 0;
        end
      
	sy=struct(y)  ;
	YY=sy.y_struct.regions{1}.Y;
	ymean(nbr,nbimg) = mean(YY);
	yvar(nbr,nbimg) = std(YY);
    
      end
    end
  end
    
  FA_img_ok(ks).oimgname = oimgname ;
  FA_img_ok(ks).roiname = roiname ;
  FA_img_ok(ks).ymean = ymean ;
  FA_img_ok(ks).yvar = yvar ;
  FA_img_ok(ks).roivol = roivol ;
  %  FA_img_ok(ks). = ;
  
  %write the xls files
  fp = fopen(fullfile(T2_roi_extract,[FA_img_ok(ks).suj,'.csv']),'w');

  fprintf(fp,'\nRegion,Volume');
  
  for nbimg=1:length(oimgname)
    fprintf(fp,',%s_mean,%s_std',oimgname{nbimg},oimgname{nbimg});
  end
  
  for  nbr=1:length(roiname)
    fprintf(fp,'\n%s,%f',roiname{nbr},roivol(nbr));
    
    for nbimg=1:length(oimgname)
      fprintf(fp,',%f,%f',ymean(nbr,nbimg),yvar(nbr,nbimg));
    end
    
  end

  fclose(fp);

  clear oimgname roiname ymean yvar

end


%write the xls files

for ks = 1:length(FA_img_ok)
  
  fp = fopen(fullfile(T2_roi_extract,[FA_img_ok(ks).suj,'.csv']),'w');
  oimgname =  FA_img_ok(ks).oimgname;

  fprintf(fp,'\nRegion,Volume');
  
  for nbimg=1:length(oimgname)
    fprintf(fp,',%s_mean,%s_std',oimgname{nbimg},oimgname{nbimg});
  end
  
  roiname =  FA_img_ok(ks).roiname;
  for  nbr=1:length(roiname)
    fprintf(fp,'\n%s,%f',roiname{nbr},FA_img_ok(ks).roivol(nbr));
    
    for nbimg=1:length(oimgname)
      fprintf(fp,',%f,%f',FA_img_ok(ks).ymean(nbr,nbimg),FA_img_ok(ks).yvar(nbr,nbimg));
    end
    
  end

  fclose(fp);

  
end
