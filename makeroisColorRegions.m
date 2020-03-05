function makeroisColorRegions(subs, index_img, outputdir, rootdir, maskimg, mask_name, p_value)

% this is a modification of makeroisFunc_RDS aiming at locating the three color
% selective regions in the healthy. It looks for best 3 clusters (three separate 
% clusters containing voxels with strongest activations).  


% subs - name of subject folders
% mask - a file name (with a PATH if in other directory) of a mask within
% which the search is executed
% index_img - number of the t-image (refers to contrast number)


for s = 1:length(subs)
    for c = 1:length(index_img)
        
        %% read each subject's spmT for a given contrast
        
        anadir = fullfile(rootdir, subs{s}, 'stats_color');
        cd(anadir);
        Timg = sprintf('spmT_%04d.nii',index_img(c));
        spm_struct_for_t_image = spm_vol(Timg);
        spmT_matrix = spm_read_vols(spm_struct_for_t_image);
        
        template = zeros(spm_struct_for_t_image.dim);
        
        %Below a line that extract contrast name from spm struct file.
        %Might be useful if I want to make a summary table.
        
        VOIcontrast = spm_struct_for_t_image.descrip(strfind(spm_struct_for_t_image.descrip, ': ')+2: end);
        
        %% masking
        
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
        
        %% statistical thresholding of the masked image
              
        load('SPM.mat')
        criticalt = tinv(1-p_value,SPM.xX.erdf);
        statistical_thresholding = masked_spmT_matrix.*double(masked_spmT_matrix >= criticalt);
        statistical_thresholding_bin = double(statistical_thresholding>0);
        
        
        cd(outputdir)
         % image

            colRegions_file = spm_struct_for_t_image;
            colRegions_file.fname = ['colRegions_' 'con' num2str(index_img(c)) '_' VOIcontrast '_' mask_name '_p<' num2str(p_value) '_' subs{s} '_'  '.nii'];

            colRegions_file = spm_create_vol(colRegions_file);
            spm_write_vol(colRegions_file,statistical_thresholding);


            % ROI
            colRegions_bin_file = spm_struct_for_t_image;
            colRegions_bin_file.fname = ['bin_colRegions_' 'con' num2str(index_img(c)) '_' VOIcontrast '_' mask_name '_p<' num2str(p_value) '_' subs{s} '_'  '.nii'];

            colRegions_bin_file = spm_create_vol(colRegions_bin_file);
            spm_write_vol(colRegions_bin_file,statistical_thresholding_bin);
        
        
%         %% Clusterization 
%         
%         I_stat= find(statistical_thresholding>0);
%         [x,y,z]=ind2sub(spm_struct_for_t_image.dim, I_stat);
%         L  = [x y z ]'; %%% locations in voxels
%         clusterindex = spm_clusters(L); %finds indices of clusters
%         t_and_cluster_table = table(statistical_thresholding(I_stat),I_stat, clusterindex', 'VariableNames', {'tval', 'index','cluster'});
%         t_and_cluster_table = sortrows(t_and_cluster_table, 1, 'descend');
%         
%         
%         %% Create color-regions
%         
%         best_clusters = unique(t_and_cluster_table.cluster, 'stable');
%         
%         if max(best_clusters)<3
%             sprintf('Subject no %s has only %i clusters', subs{s}, max(best_clusters))
%             
%             % create images
%         
%             bestcluster_colRegions = template(:);
%             bestcluster_colRegions(t_and_cluster_table.index) = t_and_cluster_table.tval;
%             bestcluster_colRegions = reshape(bestcluster_colRegions, spm_struct_for_t_image.dim);
%             
%             % create  rois(binary)
%         
%             bestcluster_colRegions_bin = template(:);
%             bestcluster_colRegions_bin(t_and_cluster_table.index) = 1;
%             bestcluster_colRegions_bin = reshape(bestcluster_colRegions_bin, spm_struct_for_t_image.dim);
%         
%         elseif isempty(best_clusters)
%             sprintf('Subject no %s has no suprathreshold clusters', subs{s})
%             
%         else
%             
%             best_3clusters = best_clusters(1:3);
%             best_3clusters_indices = t_and_cluster_table.index(ismember(t_and_cluster_table.cluster, best_3clusters));
% 
%             template = zeros(spm_struct_for_t_image.dim);
% 
%             % create images
%             bestcluster_colRegions = template(:);
%             bestcluster_colRegions(best_3clusters_indices) = t_and_cluster_table.tval(ismember(t_and_cluster_table.cluster, best_3clusters));
%             bestcluster_colRegions = reshape(bestcluster_colRegions, spm_struct_for_t_image.dim);
% 
%             % create  rois(binary)
% 
%             bestcluster_colRegions_bin = template(:);
%             bestcluster_colRegions_bin(best_3clusters_indices) = 1;
%             bestcluster_colRegions_bin = reshape(bestcluster_colRegions_bin, spm_struct_for_t_image.dim);
%         end
%         
%         %% safe as nifti
%        if ~isempty(best_clusters)
%             cd(outputdir)
% 
%             % image
% 
%             bestcluster_colRegions_file = spm_struct_for_t_image;
%             bestcluster_colRegions_file.fname = ['bestclusters_colRegions_' 'con' num2str(index_img(c)) '_' VOIcontrast '_' mask_name '_p<' num2str(p_value) '_' subs{s} '_'  '.nii'];
% 
%             bestcluster_colRegions_file = spm_create_vol(colRegions_file);
%             spm_write_vol(bestcluster_colRegions_file,bestcluster_colRegions);
% 
% 
%             % ROI
%             bestcluster_colRegions_bin_file = spm_struct_for_t_image;
%             bestcluster_colRegions_bin_file.fname = ['bin_bestclusters_colRegions_' 'con' num2str(index_img(c)) '_' VOIcontrast '_' mask_name '_p<' num2str(p_value) '_' subs{s} '_'  '.nii'];
% 
%             bestcluster_colRegions_bin_file = spm_create_vol(colRegions_bin_file);
%             spm_write_vol(bestcluster_colRegions_bin_file,bestcluster_colRegions_bin);
%        end
%        
%        
%      
% %         
%         
% %         %% CREATE A SUMMARY for subject
% %         
% %         summary = {criticalt, numel(find(statistical_thresholding_nvox)),...
% %             length(best_cluster_I), length(biggest_cluster_I), numel(find(best_significant_cluster_matrix)),...
% %             length(biggest_significant_cluster_I)};
% %         summaryTable((s-1)*length(index_img)+c, :) = summary;
%         
        
    end
end

cd(outputdir)

% summaryTable = cell2table(summaryTable,'VariableNames',{'Contrast', 'Subject' 'maxTvalue', 'maxSignificantTvalue',...
%     't_threshold_nvox', 't_threshold_stats','stats_threshold_nvox', 'best_cluster_size', 'biggest_cluster_size',...
%     'best_significant_cluster_size','biggest_significant_cluster_size'});
% writetable(summaryTable, [ ana '_' mask_name '_p<' num2str(p_value) '_' num2str(nvox) 'voxels_summary.csv'])
% 


