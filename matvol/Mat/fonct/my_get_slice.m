function slice = my_get_slice(Vi,Vr,coupe)

dim = Vr.dim * Vr.M_rot(1:3,1:3);

slice = spm_slice_vol(Vi, ...
	       inv(Vi.mat) * Vr.mat * Vr.M_rot * spm_matrix([0 0 coupe]),...
	       dim(1:2), Vr.hold)';
