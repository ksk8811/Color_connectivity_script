function compute_T2(P,T2filename,TE,maskfile)

if ~exist('T2filename')
  T2filename = 'T2MAP.img';
end

if ~exist('TE')
  TE=[26 39 53 105 132 158 ];
end


withmask=0;

if ~exist('P')
  P = spm_select([1 Inf],'image','select images','',pwd);
end

VY = spm_vol(P);
NbFiles = length(VY);
dim = VY(1).dim(1:3);

if ~exist('maskfile')
  %mask=ones(dim(1:2));
  mask=ones(dim);  
else
  vm=spm_vol(maskfile);
  if any(dim-vm.dim(1:3))
      error('wrong maks dimention %d %d %d',vm.dim(1:3))
  end
  for nb_slice = 1:dim(3)
      mask(:,:,nb_slice) = spm_slice_vol(vm,spm_matrix([0 0 nb_slice]),dim(1:2),0);
  end
end  
  
x=TE;


T2img=VY(1);
T2img.fname = fullfile(pwd,T2filename);

T2img = spm_create_vol(T2img);


for nb_vol = 1:NbFiles
  for nb_slice = 1:dim(3)
    Mi      = spm_matrix([0 0 nb_slice]);
    X(:,:,nb_slice) = spm_slice_vol(VY(nb_vol),Mi,VY(nb_vol).dim(1:2),0); 
  end
  mask(X==0)=0;
end


for nb_slice = 1:dim(3)

  X2 = zeros(dim(1:2));
  Mi      = spm_matrix([0 0 nb_slice]);
  clear Xm;
  
  for nb_vol = 1:NbFiles
  
    X       = spm_slice_vol(VY(nb_vol),Mi,VY(nb_vol).dim(1:2),0);
    Xm(:,nb_vol) = X( (mask(:,:,nb_slice)>0) );
  end    
  
   y=log(Xm);
   
   %figure; plot(x,y)

   var_x = repmat ( sum((x-mean(x)).^2)/size(y,2), size(y,1),1);
   cv=sum( repmat(x-mean(x),size(y,1),1) .* (y-repmat(mean(y,2),1,size(y,2)) ),2 )/size(y,2);

   a=cv./var_x;
   
   at2 = -1./a;
   at2(at2<0) = 0;
   at2(at2>1500) = 0;
   
   X2(mask(:,:,nb_slice)>0) = at2;

   spm_write_plane(T2img,X2,nb_slice);

   %   b=mean(y,2) - repmat(mean(x),size(y,1),1).*a;
   %   yest=a*x + repmat(b,1,size(y,2))
   
end

 

if (0)
mask = zeros(VY(1).dim(1:3));
mask2=mask;

  for nb_vol=1:NbFiles 
    for j = 1:VY(nb_vol).dim(3)
      Mi      = spm_matrix([0 0 j]);
      X       = spm_slice_vol(VY(nb_vol),Mi,VY(nb_vol).dim(1:2),0);
      slice_mean(j,nb_vol) = mean(X(:));
    end 
    vol_mean(nb_vol) = mean(slice_mean(:,nb_vol));

    seuil(nb_vol) = vol_mean(nb_vol)/4;      

    nbpts=0;
    
    for j = 1:VY(nb_vol).dim(3)
      Mi      = spm_matrix([0 0 j]);
      X       = spm_slice_vol(VY(nb_vol),Mi,VY(nb_vol).dim(1:2),0);
      nbpts(j) = sum(sum(X>=seuil(nb_vol)));
      slice_mean_spm(j,nb_vol) = sum(sum(X(X>=seuil(nb_vol))));
      mask2(:,:,j) = mask2(:,:,j) + (X>=seuil(nb_vol));
    end
    
    nb_pts(nb_vol) = sum(nbpts);
    vol_mean_spm(nb_vol) = sum(slice_mean_spm(:,nb_vol))./nb_pts(nb_vol);
    nb_pts(nb_vol) = nb_pts(nb_vol) / prod(VY(nb_vol).dim(1:3)) *100 ;
    
    for j = 1:VY(nb_vol).dim(3)
      Mi      = spm_matrix([0 0 j]);
      X       = spm_slice_vol(VY(nb_vol),Mi,VY(nb_vol).dim(1:2),0);
      
      mask(:,:,j) = mask(:,:,j) + (X>=vol_mean_spm(nb_vol)) + (X==0)*(-999);
    end
  end

  figure
  for k=1:size(mask,3)  
    imagesc(mask(:,:,k)>1)
    pause(0.05)
  end
end