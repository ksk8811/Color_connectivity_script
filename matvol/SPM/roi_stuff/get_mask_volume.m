 

P = spm_select([1 Inf],'image','select images','',pwd);

v=spm_vol(P);

for nbf =1:size(P,1)

  func=['img>0' ];

  omask = maroi_image(struct('vol', v(nbf), 'binarize',1,'func', func'));

  omask = maroi_matrix(omask);
	     
  box_space = mars_space ( struct('dim',v(nbf).dim,'mat',v(nbf).mat) );

  [ppoint val] = voxpts(omask,box_space);

  vox    = sqrt(sum(v(nbf).mat(1:3,1:3)'.^2));
  
  volumee = prod(vox) * size(ppoint,2);
  
  Cluster = spm_clusters(ppoint);

  indc=unique(Cluster);

  for k=1:length(indc)
    clus_size(k) = length(find(Cluster==indc(k)));

  end
  
  
  fprintf('Sujet %s \n\t Volume = %f \t nb cluster = %d\n',v(nbf).fname,volumee,max(Cluster))
  fprintf('mais seulement %d cluster ayant plus de 1 voxel \n',max(Cluster)-sum(clus_size==1))
  fprintf('Volume sans les petit cluster %f \n',volumee-sum(clus_size==1)*prod(vox))

end
