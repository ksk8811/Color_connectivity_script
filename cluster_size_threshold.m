function [no_small_cluster_matrix] = cluster_size_threshold(img,cluster_threshold)
%given an .nii activation/connectivity map, this function provides a
%cluster extend threshold at a given number of voxels

spm_struct = spm_vol(img);
matrix = spm_read_vols(spm_struct);


I = find(matrix); %find non-zero voxels
[x,y,z]=ind2sub(spm_struct.dim, I);
L  = [x y z ]'; %%% locations in voxels
clusterindex = spm_clusters(L); %finds indices of clusters

[cluster_size,cluster_number]=hist(clusterindex,unique(clusterindex));
big_cluster_indices = cluster_number(cluster_size>cluster_threshold);

without_small_clusters_I = I(ismember(clusterindex, big_cluster_indices));

template = zeros(spm_struct.dim);
lin_no_small_cluster_matrix = template(:);
lin_no_small_cluster_matrix(without_small_clusters_I)=1;
no_small_cluster_binary_matrix = reshape(lin_no_small_cluster_matrix, spm_struct.dim);

no_small_cluster_matrix = no_small_cluster_binary_matrix.*matrix;

no_small_cluster_struct_file = spm_struct;
no_small_cluster_struct_file.fname = [spm_struct.fname '_' num2str(cluster_threshold) '<k.nii'];

no_small_cluster_struct_file = spm_create_vol(no_small_cluster_struct_file);
spm_write_vol(no_small_cluster_struct_file,no_small_cluster_matrix);
end

