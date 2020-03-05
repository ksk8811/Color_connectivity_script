function compute_mask(VY)


dim = VY(1).dim(1:3);

mask = zeros(dim(1:3));

NbFiles = length(VY);

for nb_vol=1:NbFiles 
  for j = 1:dim(3)
    Mi      = spm_matrix([0 0 j]);
    X       = spm_slice_vol(VY(nb_vol),Mi,VY(nb_vol).dim(1:2),0);
    
    %slice_mean(j,nb_vol) = mean(X(:));

    mask(:,:,j) = mask(:,:,j) + (X>0);

  end 
end

mask = mask./NbFiles .* (mask==NbFiles);

VM1    = struct(	'fname',	['mask_all_pos_seuill100.img'],...
    'dim',		[VY(1).dim ],...
    'mat',		VY(1).mat,...
    'pinfo',	[1 0 0]',...
    'descrip',	'rrr spm_like:resultant analysis mask');

%    'dim',		[VY(1).dim , spm_type('uint8')],...

VM1    = spm_write_vol(VM1, mask);
