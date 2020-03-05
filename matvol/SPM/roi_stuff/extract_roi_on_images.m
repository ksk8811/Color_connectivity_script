function OUT = extract_roi_on_images(roi,img,sujname,roiname,imagename,poolname,scalefactor)


if length(roi)~=length(img)
  error('inputs should have the same length\n');
end

if ~exist('scalefactor')
  scalefactor =  ones(length(imagename),1)
end

check_name=1;

Y={};namefield={}; 



OUT.pool=poolname;

for nsuj = 1:length(sujname)
  
  roip = roi{nsuj};
  imgp = img{nsuj};
 
  OUT.suj{nsuj} = sujname{nsuj};

  Y={};namefield={}; 

  for nbroi=1:size(roip,1)
    o = maroi_image(struct('vol', spm_vol(deblank(roip(nbroi,:))), 'binarize',1,'func', 'img>0'));
    if check_name
      if ~findstr(roip(nbroi,:), roiname{nbroi})
	error('Roi name problem')
      end
    end     
    
    thevolume = volume(o); % do_fsl_getvol(deblank(roip(nbroi,:)));
    Y{end+1} = thevolume;
    namefield{end+1} = [ roiname{nbroi} 'Vol_mm' ];
    %Y{end+1} = volume(1);
    %namefield{end+1} = [ roiname{nbroi} 'Vol_pts' ];

    for nbimg=1:size(imgp,1)
      
      if check_name
	if ~findstr(imgp(nbimg,:), imagename{nbimg} )
	  error('Image name problem')
	end
      end
     
      roivals = getdata(o,spm_vol(deblank(imgp(nbimg,:)))); 
      Y{end+1} = mean(roivals).* scalefactor(nbimg);
      
      namefield{end+1} = [imagename{nbimg} '_roi_' roiname{nbroi} ];
 
      Y{end+1} = std(roivals).* mean(roivals);
      
      namefield{end+1} = [imagename{nbimg} '_roiSTD_' roiname{nbroi} ];

    end
  end
  
  OUT = add_res_to_struct(OUT,namefield,Y)
  
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

