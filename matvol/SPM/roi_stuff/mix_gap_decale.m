

T2filename = 'mixt.img';


P1 = spm_select([1 Inf],'image','select images','',pwd);
P2 = spm_select([1 Inf],'image','select images','',pwd);

VY1 = spm_vol(P1);
VY2 = spm_vol(P2);

NbFiles = length(VY1);
dim = VY1(1).dim(1:3);

for nb_vol=1:NbFiles
  
  T2img=VY1(nb_vol);
  [p,f]=fileparts(T2img.fname)

  T2img.fname = fullfile(pwd,T2filename);

  T2img.mat(9)=1;
  T2img.private.mat(9)=1;
  T2img.private.mat0(9)=1;
  T2img.dim(3) = T2img.dim(3)*2;
  
  T2img = spm_create_vol(T2img);
  

  for nb_slice = 1:dim(3)
    
    X2 = zeros(dim(1:2));
    Mi      = spm_matrix([0 0 nb_slice]);
    
    
    X1       = spm_slice_vol(VY1(nb_vol),Mi,VY1(nb_vol).dim(1:2),0);
    X2       = spm_slice_vol(VY2(nb_vol),Mi,VY2(nb_vol).dim(1:2),0);
    
    
    spm_write_plane(T2img,X1,2*nb_slice-1);
    spm_write_plane(T2img,X2,2*nb_slice);
    
    %   b=mean(y,2) - repmat(mean(x),size(y,1),1).*a;
    %   yest=a*x + repmat(b,1,size(y,2))
    
  end
end