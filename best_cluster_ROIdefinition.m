
clear
clc

core = '/Users/k.siudakrzywicka/Desktop/RDS_fMRI/Controls/Processed_566_471_vol';
statPart = 'stats_words';
experiments=struct(...
    'select_path1',core,...  % path to individual localizers
    'select_path2',statPart,...  % subpath to the localizer SPM.mat inside each subject
    'data',{fileNames(core)});

select_con = 14; %%%

ROIfile = fullfile('/Users/k.siudakrzywicka/Desktop/RDS_fMRI/RDS_localizers/Mask/ranat_all_gyri_chopped.nii');
pvalue = 0.05;
nvox = 500;

%% define the selection and test files
totsub =length(experiments.data);
spmfiles={};
spmfiles_select={};
spmfiles_test={};

for nsub=1:totsub
    spmfiles_select{nsub}=fullfile(experiments.select_path1,experiments.data{nsub},experiments.select_path2,'SPM.mat');
end

ROIheader = spm_vol(ROIfile);
ROIvol=spm_read_vols(ROIheader);

ROInames{1} = 'ROI from saved file';
%% Look for voxels
for i_subj = 1:totsub  %%%% loop across subjects
    
    %%% extract localizer t-test to optimize for this subject:
    clear select_tvol
    select_tfile = fullfile(experiments.select_path1,experiments.data{i_subj},experiments.select_path2,sprintf('spmT_%04d.nii',select_con));
    select_theader = spm_vol(select_tfile);
    [select_tvol]=spm_read_vols(select_theader);
    
    searchvol = ROIvol;
    
    tvol2 = select_tvol(:) .* (searchvol(:)>0) ;
%     
%     xyz = find(tvol2); %find idices of voxels with non-zero t values
%     [x,y,z]=ind2sub(size(select_tvol),xyz); %translate it to 3D space
%     L  = [x y z ]'; %%% locations in voxels
%     clusterindex = spm_clusters(L);  % clustering of the voxels
%     sub2ind(size(select_tvol),L);
%     [maxt xyzmax] =  max( tvol2(:) );
%     clusternumber = clusterindex(xyzmax==xyz);    
%     
%     xyz = xyz(clusterindex == clusternumber);
    
    [tvalues,xyz] = sort(tvol2,'descend');
    xyz = xyz(1:nvox);
    [x,y,z]=ind2sub(size(select_tvol),xyz);
%     L  = [x y z ]'; %%% locations in voxels
%     clusterindex = spm_clusters(L);  % clustering of the voxels
%     sub2ind(size(select_tvol),L);
%     [maxt xyzmax] =  max( tvol2(:) );
%     clusternumber = clusterindex(xyzmax==xyz); %%% find the conventional index of the cluster containing the peak voxel
%     xyz = xyz(clusterindex == clusternumber);

    
    [x,y,z]=ind2sub(size(select_tvol),xyz);
    
    
    V = select_theader;
    V.fname = 'proba.nii';
    V.pinfo = [];
    
    
    Yn = zeros(V.dim);
    Yn([x,y,z])=1;
    
    V = rmfield(V,'pinfo')
    
    
    V = spm_create_vol(V);
   
    
    V = spm_write_vol(V,Yn);
    
    
%     
% %     load(spmfiles_select{i_subj}); %%% load  SPM.mat
% %     criticalt = tinv(1-pvalue,SPM.xX.erdf);  % t value threshold for the corresponding p value
% %     xyz = find(tvol2>=criticalt);
% %     
% % 
% %         [x,y,z]=ind2sub(size(select_tvol),xyz);
% %         L  = [x y z]'; %%% locations in voxels
% %         clusterindex = spm_clusters(L);  % clustering of the voxels
% %         sub2ind(size(select_tvol),L);
% %         [maxt, xyzmax] =  max( tvol2(:) );
% %         clusternumber = clusterindex(xyzmax==xyz); %%% find the conventional index of the cluster containing the peak voxel
%         
%         
%         nbvox = length(xyz);
%         [x,y,z]=ind2sub(size(select_tvol),xyz);
end
