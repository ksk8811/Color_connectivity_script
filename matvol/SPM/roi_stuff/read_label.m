function read_label(p)

v=smp_vol(p)

for nbs = 1:v.dim(3)
  A(:,:,nbs) =  spm_slice_vol(v,spm_matrix([0 0 nbs]),v.dim(1:2),0);
end