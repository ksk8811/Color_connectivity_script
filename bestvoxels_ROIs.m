function [anal]=bestvoxels;
%%%% This program identifies the coordinates of the 'best' voxel or voxels
%%%% in a given "localizer" for each subject, and probes the average pattern of responses
%%%% of these voxels in other independent conditions.
%%%%
%%%% Parameter 1: volume_option
%%%% The searched area can be defined in many different ways (inspired by
%%%% Golarai's paper):
%%%% 1 - within a certain radius of the peak coordinates passed to the
%%%% program
%%%% 2 - within successive "shells" around this peak
%%%% 3 - within a mask image identical for all subjects (eg an anatomical region)
%%%% 4 - within a set of ROIs (e.g. Christophe Pallier's)
%%%%
%%%% Parameter 2: voxel_option
%%%% Within this search volume, we can
%%%% 1 - keep all voxels
%%%% 2 - (fixed threshold) keep all voxels where the localizer t-test passes a certain statistical
%%%% threshold, without clustering
%%%% 3 - (clusterization) keep all voxels where the localizer t-test passes a certain statistical
%%%% threshold, and which belong to the cluster with the max t value
%%%% 4 - (fixed number) keep the best n voxels for each subject (after ranking by the t-test of
%%%% the localizer)

%%%%%% USER DEFINED PARAMETERS ***********************************

%%% for simplicity, we adopted virtually the same format as the Fedorenko
%%% package

% experiments=struct(...
%     'select_path1','/neurospin/unicog/protocols/IRMf/math_formula_masaki_dehaene_2009/func_localizer',...  % path to individual localizers
%     'select_path2','',...  % subpath to the localizer SPM.mat inside each subject
%     'test_path1','/neurospin/unicog/protocols/IRMf/math_formula_masaki_dehaene_2009/Subjects',...  % path to individual test data
%     'test_path2','fMRI/acquisition1/analysis/LevelBranchMatch',...  % subpath to the test data SPM.mat inside each subject
%     'data',{{'sub04',  'sub09' , 'sub12' , 'sub14' , 'sub16',  'sub18'  ,'sub20' , 'sub22'  ,'sub24',...  %%% list of subject directories
%     'sub07' , 'sub10',  'sub13' , 'sub15'  ,'sub17',  'sub19'  ,'sub21' , 'sub23'}});
% 
core = '/Users/k.siudakrzywicka/Desktop/RDS_fMRI/Controls/Processed_566_471_vol';
statPart = 'stats_words';
experiments=struct(...
    'select_path1',core,...  % path to individual localizers
    'select_path2',statPart,...  % subpath to the localizer SPM.mat inside each subject
    'data',{fileNames(core)});

%%%% note that to locate the best voxels, the spmT maps are used so that we can associate a p value
%%%% and select the most significant voxel (not necessarily the most
%%%% active!). In practise this gives very similar results to optimizing
%%%% the con image itself
% flipsign = 1 or -1 ; %%% +1 or -1, provides an optional change of sign of the contrast
flipsign = 1; %% default is to keep the contrast "as is" with its sign

%%%% select_con = number of the contrast used to select the voxels (in
%%%% SPM.mat of the select_path)

%16 - faces, 17 - houses, 18 - tools
select_con = 16; %%%

% %%%% test_con = number of the contrast(s) analyzed at the selected voxels (in
% %%%% SPM.mat of the test_path)
% test_con = [ 10,11,12,22,23,24 ] ; %%% VBvsC_1, LAvsC_1, TBvsC_1, VBvsC_2, LAvsC_2, TBvsC_2

%%%%%%%%%% different manners of selecting the voxels:

nrois=1;

ROIfile = fullfile('/Users/k.siudakrzywicka/Desktop/RDS_fMRI/RDS_localizers/Mask/anat_all_gyri_chopped.nii');


%%%% Parameter 2: voxel_option
%%%% Within this search volume, we can
%%%% 1 - keep all voxels
%%%% 2 - (fixed threshold) keep all voxels where the localizer t-test passes a certain statistical
%%%% threshold, without clustering
%%%% 3 - (clusterization) keep all voxels where the localizer t-test passes a certain statistical
%%%% threshold, and which belong to the cluster with the max t value
%%%% 4 - (fixed number) keep the best n voxels for each subject (after ranking by the t-test of
%%%% the localizer) withing a signle cluster of a max t value

nvox = 300;%%% threshold for option 4

%%% end of user parameter definition


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%  DO NOT CHANGE AFTER THIS POINT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% start of computation of the results

%% define the selection and test files
totsub =length(experiments.data);
spmfiles={};
spmfiles_select={};
spmfiles_test={};

for nsub=1:totsub
    spmfiles_select{nsub}=fullfile(experiments.select_path1,experiments.data{nsub},experiments.select_path2,'SPM.mat');
end

%% define the search volume

    ROIheader = spm_vol(ROIfile);
    ROIvol=spm_read_vols(ROIheader);

    ROInames{1} = 'ROI from saved file';


%%
%%%%%% do the search for best voxels and output results

fprintf( '\n FIND BEST VOXELS\n' ) ;
h = waitbar( 0, 'Finding best voxels...' ) ;

for i_subj = 1:totsub  %%%% loop across subjects
    
    %%% extract localizer t-test to optimize for this subject:
    clear select_tvol
    select_tfile = fullfile(experiments.select_path1,experiments.data{i_subj},experiments.select_path2,sprintf('spmT_%04d.nii',select_con));
    select_theader = spm_vol(select_tfile);
    select_tvol=spm_read_vols(select_theader);

    for i_roi = 1:nrois
        
        waitbar( (i_roi+(i_subj-1)*nrois)/(totsub*nrois), h ) ;
        
            anal{i_roi}.volume_str = sprintf('ROI file %s',ROIfile);
            searchvol = ROIvol;

            anal{i_roi}.voxel_str = sprintf('The %d best voxels for localizer contrast %d',nvox,select_con);

        
            tvol2 = flipsign * select_tvol(:) .* (searchvol(:)>0) ;
        
            
            
        
        %%%% this is the masked spmT image, from which we search for one of
        %%%% more functional voxels
        
        %%% identify this subject's voxels:
   
            [tvalues,xyz] = sort(tvol2,'descend');
            xyz = xyz(1:nvox);
             if length(xyz)>0
                [x,y,z]=ind2sub(size(select_tvol),xyz);
                L  = [x y z ]'; %%% locations in voxels
                clusterindex = spm_clusters(L);  % clustering of the voxels
                sub2ind(size(select_tvol),L);
                [maxt xyzmax] =  max( tvol2(:) );
                clusternumber = clusterindex(xyzmax==xyz); %%% find the conventional index of the cluster containing the peak voxel
                xyz = xyz(clusterindex == clusternumber);
             end
        xyz = xyz(~isnan(test_convol{1}(xyz))); %%% eliminate voxels outside the brain of this subject
        
    end %%% subject loop
end  %%% roi loop
close(h) ;
%%
%save lastanal.mat anal

% %%%%%%%% Now report statistics on each of the measured parameters for each
% %%%%%%%% of the definitions of functional regions
% disp(anal{1}.voxel_str);
% for i_roi = 1:nrois
%     disp(sprintf('\n********************************************************************'));
%     disp(anal{i_roi}.volume_str);
%     
%     disp('Statistics on the number of observed voxels:');
%     s=sprintf('Mean nb of voxels: %6.1f   ( STD %6.1f )', mean(anal{i_roi}.nbvoxels),std(anal{i_roi}.nbvoxels));
%     disp(s)
%     
%     sel_subj = (anal{i_roi}.nbvoxels>0);
%     
%     disp('Statistics on the mean coordinates of the observed voxels:');
%     s=sprintf('Mean coordinates %4.1f %4.1f %4.1f',mean(anal{i_roi}.coordsmm(sel_subj,:)));
%     disp(s);
%     s=sprintf('STD coordinates %4.1f %4.1f %4.1f',std(anal{i_roi}.coordsmm(sel_subj,:)));
%     disp(s);
%     %%% the following loop could be used to compute further stats on the
%     %%% coordinates
%     %     spacedims = {'x', 'y', 'z'};
%     %     for i=1:3
%     %         a=anal{i_roi}.coordsmm(:,i);
%     %         disp(sprintf('\nCoordinates of the peak voxel along the %s axis',spacedims{i}));
%     %     end
%     
%     disp('Statistics on the activation level:');
%     for i_t = 1:length(test_con)
%         activ_vector = anal{i_roi}.activation(sel_subj,i_t);
%         nsubj = sum(sel_subj);
%         mean_act(i_t) = mean(activ_vector);
%         sd_act(i_t) = std(activ_vector);
%         se_act(i_t) = std(activ_vector)/sqrt(nsubj);
%         t_value(i_t) = mean_act(i_t)/se_act(i_t);
%         p_value(i_t) = 1-tcdf(t_value(i_t),nsubj-1);
%         
%         s=sprintf('Contrast %3d: Mean activation: %6.3f (STD %6.3f), t(%d df)=%6.3f, p=%7.5f', ...
%             test_con(i_t),mean(activ_vector),std(activ_vector),nsubj-1,t_value(i_t),p_value(i_t));
%         disp(s);
%     end
%     %%%% make a plot of the entire range of contrasts:
%     figure(10+i_roi);
%     clf;
%     hold on;
%     title(anal{i_roi}.volume_str);
%     bar(1:length(test_con),mean_act);
%     errorbar(1:length(test_con),mean_act,se_act,-se_act,'.');
%     
% end
% indiv_coords
% 
% if volume_option == 1
%     volPart = strcat('con_', num2str(select_con),'volOpt_1peak', mat2str(xyzmm), 'radius_', num2str(sphereradius));
% elseif volume_option == 2
%     volPart = strcat('con_', num2str(select_con), 'volOpt_2peak', mat2str(xyzmm), 'radius_', num2str(sphereradius), 'shells_', mat2str(radii));
% elseif volume_option == 3
%     volPart = strcat('con_', num2str(select_con),'volOpt_3');
% end
% 
% if  voxel_option == 1
%     voxPart = strcat('_allVoxels','.mat'); 
% elseif  voxel_option == 2 || voxel_option == 3
%     voxPart = strcat('_voxOpt_', num2str(voxel_option), 'p_', num2str(pvalue),'.mat');
% elseif voxel_option == 4
%     voxPart = strcat('_voxOpt_', num2str(voxel_option), 'nVox_', num2str(nvox),'.mat');
% end
% 
% fileName = strcat (volPart, voxPart);
% 
% curDir = pwd;
% cd('D:\Kasia\BRASIG\BRASIG_fMRI\fMRI_results\BestVoxel\coordinatesMATfiles')
% save (fileName, 'indiv_coords');
% save (strcat('anal_', fileName), 'anal');
% 
% cd(curDir)
% %save 'indiv_coords_M_inzesphere_1_1' 'indiv_coords';
% 
