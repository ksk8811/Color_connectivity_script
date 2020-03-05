function makeroisFunc_RDS(subs, ana, index_img, nvox,outputdir, rootdir, mask, mask_name, p_value, cluster_threshold)

% this is creating rois of equal numbers of voxels for all subjects for NORMALISED data
% the t-image for a contrast is loaded and voxels with highest values are found
% and the cluster containing the strongest t value is identified

% subs - name of subject folders
% mask - a file name (with a PATH if in other directory) of a mask within
% which the search is executed
% ana - string indicating analysis folder from where to get the t-image
% index_img - number of the t-image (refers to contrast number)
% nvox - number of voxels for the ROI to the created
% VOIcontrast -  string that become the name of the output volumes

summaryTable = cell(length(subs)*length(index_img), 11); 
maskimg = mask;

for s = 1:length(subs)
    for c = 1:length(index_img)
        
        % read each subject's spmT for a given contrast
        
        anadir = fullfile(rootdir, subs{s}, ana);
        cd(anadir);
        Timg = sprintf('spmT_%04d.nii',index_img(c));
        spm_struct_for_t_image = spm_vol(Timg);
        spmT_matrix = spm_read_vols(spm_struct_for_t_image);
        VOIcontrast = spm_struct_for_t_image.descrip(strfind(spm_struct_for_t_image.descrip, ': ')+2: end);
        
        % below masking section
        
        spm_struct_for_mask = spm_vol(maskimg);
        mask_matrix = spm_read_vols(spm_struct_for_mask);
        
        masked_spmT_matrix = mask_matrix .* spmT_matrix;
        
        % sanity check: save the masked image in the subject folder
        
        masked_image_saved = dir( ['spmT_' mask_name '_masked.nii']);
        
        if isempty(masked_image_saved)
            masked_spmT_struct = spm_struct_for_t_image;
            masked_spmT_struct.fname = ['spmT_' mask_name '_masked.nii'];
            
            masked_spmT_struct = spm_create_vol(masked_spmT_struct);
            spm_write_vol(masked_spmT_struct,masked_spmT_matrix);
        end
        
        %% choose the best n voxels
        
        [k, I] = maxk(masked_spmT_matrix(:), nvox);
        
        %% choose the voxels that pass a statistical threshold
        
        load('SPM.mat')
        criticalt = tinv(1-p_value,SPM.xX.erdf);
        statistical_thresholding = masked_spmT_matrix.*double(masked_spmT_matrix >= criticalt);
        k_stat = maxk(statistical_thresholding(:), nvox);
        
        ix = find(k_stat);
        
        if ~isempty(ix)
            k_stat_thr = k(ix(end));
            statistical_thresholding_nvox = statistical_thresholding>=k_stat_thr;
            statistical_thresholding_nvox_nonBin = statistical_thresholding.*(statistical_thresholding>=k_stat_thr);
        else
            statistical_thresholding_nvox = zeros(size(statistical_thresholding));
        end
        
        stat_threshold_matrix = double(statistical_thresholding_nvox);
       
            
        
        %% save both as nifti
        
        % best n voxels
        
        % create an image matrix
        template = zeros(spm_struct_for_t_image.dim);
        lin_best_voxel_matrix = template(:);
        lin_best_voxel_matrix(I)=1;
        best_voxel_matrix = reshape(lin_best_voxel_matrix, spm_struct_for_t_image.dim);
        
        % save as nifti
        
        best_voxels_struct_file = spm_struct_for_t_image; %reproduce the vol struct file so that SPM knows what it saves
        best_voxels_struct_file.fname = [subs{s} '_' mask_name '_' VOIcontrast '_' num2str(nvox) 'best_voxels.nii']; %change struct name
        
        cd(outputdir);
        
        best_voxels_struct_file = spm_create_vol(best_voxels_struct_file);
        spm_write_vol(best_voxels_struct_file,best_voxel_matrix);
        
        % statistical threshold
        
        stat_threshold_struct_file = spm_struct_for_t_image;
        stat_threshold_struct_file.fname = [subs{s} '_' mask_name '_' VOIcontrast '_' num2str(nvox) 'vox_p<' num2str(p_value) '.nii'];
        
        stat_threshold_struct_file = spm_create_vol(stat_threshold_struct_file);
        spm_write_vol(stat_threshold_struct_file,stat_threshold_matrix);
        
        % statistical threshold non-binary
        
        stat_threshold_struct_file_noBin = spm_struct_for_t_image;
        stat_threshold_struct_file_noBin.fname = [subs{s} '_' mask_name '_' VOIcontrast '_' num2str(nvox) 'vox_p<' num2str(p_value) 'nonBin.nii'];
        
        stat_threshold_struct_file_noBin = spm_create_vol(stat_threshold_struct_file_noBin);
        spm_write_vol(stat_threshold_struct_file_noBin,statistical_thresholding_nvox_nonBin);
        
       %% Clusterization without statistical thresholding
        
       % find cluster indices
          
        [x,y,z]=ind2sub(spm_struct_for_t_image.dim,I);
        L  = [x y z ]'; %%% locations in voxels
        clusterindex = spm_clusters(L); %finds indices of clusters
       
        %% filter_out small clusters
        
        [cluster_size,cluster_number]=hist(clusterindex,unique(clusterindex));
        big_cluster_indices = cluster_number(cluster_size>cluster_threshold);
        
        without_small_clusters_I = I(ismember(clusterindex, big_cluster_indices));
        
        lin_no_small_cluster_matrix = template(:);
        lin_no_small_cluster_matrix(without_small_clusters_I)=1;
        no_small_cluster_matrix = reshape(lin_no_small_cluster_matrix, spm_struct_for_t_image.dim);
        
         % save as nifti
        
        no_small_cluster_struct_file = spm_struct_for_t_image;
        no_small_cluster_struct_file.fname = [subs{s} '_'  mask_name '_' VOIcontrast '_' num2str(nvox) 'vox_' num2str(cluster_threshold) '<k.nii'];
        
        no_small_cluster_struct_file = spm_create_vol(no_small_cluster_struct_file);
        spm_write_vol(no_small_cluster_struct_file,no_small_cluster_matrix);
        
        
        %% CREATE A FILE WITH BEST CLUSTER (without statistical thresholding)
        cluster_with_highest_t = clusterindex(1); % index I is already sorted by tvals, so the first one is the best t
        best_cluster_I = I(clusterindex==cluster_with_highest_t);
        
        lin_best_cluster_matrix = template(:);
        lin_best_cluster_matrix(best_cluster_I)=1;
        best_cluster_matrix = reshape(lin_best_cluster_matrix, spm_struct_for_t_image.dim);
        
        % save as nifti
        
        best_cluster_struct_file = spm_struct_for_t_image;
        best_cluster_struct_file.fname = [subs{s} '_'  mask_name '_' VOIcontrast '_' num2str(nvox) 'vox_best_cluster.nii'];
        
        best_cluster_struct_file = spm_create_vol(best_cluster_struct_file);
        spm_write_vol(best_cluster_struct_file,best_cluster_matrix);
        
        %% CREATE A FILE WITH BIGGEST CLUSTER (without statistical thresholding)
        
        biggest_cluster = mode(clusterindex);
        biggest_cluster_I = I(clusterindex==biggest_cluster);
        
        lin_biggest_cluster_matrix = template(:);
        lin_biggest_cluster_matrix(biggest_cluster_I)=1;
        biggest_cluster_matrix = reshape(lin_biggest_cluster_matrix, spm_struct_for_t_image.dim);
        
        % save as nifti
        
        biggest_cluster_struct_file = spm_struct_for_t_image;
        biggest_cluster_struct_file.fname = [subs{s} '_'  mask_name '_' VOIcontrast '_' num2str(nvox) 'vox_biggest_cluster.nii'];
        
        biggest_cluster_struct_file = spm_create_vol(biggest_cluster_struct_file);
        spm_write_vol(biggest_cluster_struct_file,biggest_cluster_matrix);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %% Clusterization with statistical thresholding
        
        I_stat= find(statistical_thresholding_nvox);
        [x,y,z]=ind2sub(spm_struct_for_t_image.dim, I_stat);
        L  = [x y z ]'; %%% locations in voxels
        clusterindex = spm_clusters(L); %finds indices of clusters
        
        %% filter_out small clusters
        
        [cluster_size,cluster_number]=hist(clusterindex,unique(clusterindex));
        big_cluster_indices = cluster_number(cluster_size>cluster_threshold);
        
        without_small_clusters_I = I_stat(ismember(clusterindex, big_cluster_indices));
        
        lin_no_small_cluster_matrix = template(:);
        lin_no_small_cluster_matrix(without_small_clusters_I)=1;
        no_small_cluster_matrix = reshape(lin_no_small_cluster_matrix, spm_struct_for_t_image.dim);
        
        %non-Binary
        
        lin_statistical_thresholding_nvox_nonBin = statistical_thresholding_nvox_nonBin(:);
        no_small_cluster_matrix_nonBin = reshape(lin_statistical_thresholding_nvox_nonBin.*lin_no_small_cluster_matrix, spm_struct_for_t_image.dim);
        
         % save as nifti
        
        no_small_cluster_struct_file_stat = spm_struct_for_t_image;
        no_small_cluster_struct_file_stat.fname = [subs{s} '_'  mask_name '_' VOIcontrast '_' num2str(nvox) 'vox_p<' num2str(p_value) '_' num2str(cluster_threshold) '<k.nii'];
        
        no_small_cluster_struct_file_stat_nonBin = spm_struct_for_t_image;
        no_small_cluster_struct_file_stat_nonBin.fname = [subs{s} '_'  mask_name '_' VOIcontrast '_' num2str(nvox) 'vox_p<' num2str(p_value) '_' num2str(cluster_threshold) '<k_nonBin.nii'];
        
        
        no_small_cluster_struct_file_stat = spm_create_vol(no_small_cluster_struct_file_stat);
        spm_write_vol(no_small_cluster_struct_file_stat,no_small_cluster_matrix);
        
        no_small_cluster_struct_file_stat_nonBin = spm_create_vol(no_small_cluster_struct_file_stat_nonBin);
        spm_write_vol(no_small_cluster_struct_file_stat_nonBin,no_small_cluster_matrix_nonBin);
        
         
        %% CREATE A FILE WITH BEST CLUSTER (with statistical thresholding)
        
        [highest_t, index] = max(masked_spmT_matrix(I_stat)); %looking for the highest statistically significant t and it;s index
        cluster_with_highest_t = clusterindex(index);
        best_significant_cluster_I = I_stat(clusterindex==cluster_with_highest_t);
        
        lin_best_significant_cluster_matrix = template(:);
        lin_best_significant_cluster_matrix(best_significant_cluster_I)=1;
        best_significant_cluster_matrix = reshape(lin_best_significant_cluster_matrix, spm_struct_for_t_image.dim);
        
        % save as nifti
        
        best_significant_cluster_struct_file = spm_struct_for_t_image;
        best_significant_cluster_struct_file.fname = [subs{s} '_'  mask_name '_' VOIcontrast '_' num2str(nvox) 'vox_p<' num2str(p_value) 'best_cluster.nii'];
        
        best_significant_cluster_struct_file = spm_create_vol(best_significant_cluster_struct_file);
        spm_write_vol(best_significant_cluster_struct_file,best_significant_cluster_matrix);
        
        %% CREATE A FILE WITH BIGGEST CLUSTER (with statistical thresholding)
        
        biggest_significant_cluster = mode(clusterindex);
        
        biggest_significant_cluster_I = I_stat(clusterindex==biggest_significant_cluster);
        
        lin_biggest_significant_cluster_matrix = template(:);
        lin_biggest_significant_cluster_matrix(biggest_significant_cluster_I)=1;
        biggest_significant_cluster_matrix = reshape(lin_biggest_significant_cluster_matrix, spm_struct_for_t_image.dim);
        
        %non-Binary
        
        biggest_significant_cluster_matrix_nonBin = reshape(lin_statistical_thresholding_nvox_nonBin.*lin_biggest_significant_cluster_matrix, spm_struct_for_t_image.dim);
        
        
        % save as nifti
        
        biggest_significant_cluster_struct_file = spm_struct_for_t_image;
        biggest_significant_cluster_struct_file.fname = [subs{s} '_'  mask_name '_' VOIcontrast '_' num2str(nvox) 'vox_p<' num2str(p_value) 'biggest_cluster.nii'];
        
        biggest_significant_cluster_struct_file = spm_create_vol(biggest_significant_cluster_struct_file);
        spm_write_vol(biggest_significant_cluster_struct_file,biggest_significant_cluster_matrix);
        
        biggest_significant_cluster_struct_file_nonBin = spm_struct_for_t_image;
        biggest_significant_cluster_struct_file_nonBin.fname = [subs{s} '_'  mask_name '_' VOIcontrast '_' num2str(nvox) 'vox_p<' num2str(p_value) 'biggest_cluster_nonBin.nii'];
        
        biggest_significant_cluster_struct_file_nonBin = spm_create_vol(biggest_significant_cluster_struct_file_nonBin);
        spm_write_vol(biggest_significant_cluster_struct_file_nonBin,biggest_significant_cluster_matrix_nonBin);
        
        
        %% CREATE A SUMMARY for subject
        
        summary = { VOIcontrast subs{s}, k(1),highest_t, k(end), criticalt, numel(find(statistical_thresholding_nvox)),...
            length(best_cluster_I), length(biggest_cluster_I), numel(find(best_significant_cluster_matrix)),...
            length(biggest_significant_cluster_I)};
        summaryTable((s-1)*length(index_img)+c, :) = summary;
        
        
    end
end
summaryTable = cell2table(summaryTable,'VariableNames',{'Contrast', 'Subject' 'maxTvalue', 'maxSignificantTvalue',...
    't_threshold_nvox', 't_threshold_stats','stats_threshold_nvox', 'best_cluster_size', 'biggest_cluster_size',...
    'best_significant_cluster_size','biggest_significant_cluster_size'});
writetable(summaryTable, [ ana '_' mask_name '_p<' num2str(p_value) '_' num2str(nvox) 'voxels_summary.csv'])



