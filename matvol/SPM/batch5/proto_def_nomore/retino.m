parameters.rootdir = '/servernas/images3/romain/images/ppn/';


parameters.sujet_dir_wc = {'meg_retino'};

parameters.fonc_dir_wc='run';
parameters.anat_dir_wc='t1mpr';

parameters.anatwc  = '^s.*\.img$'; 
parameters.funcwc  = '^f.*\.img$'; 

parameters.funcwc_analyse  = '^swaf.*\.img$'; 

parameters.TR =  1.93;

parameters.logfile = 'batch_up.log';

parameters.modelname = 'retino';

%the name of the directory used to store stats result
%parameters.preproc_subdir = 'preproc_normalize'; 


%- Parameters for preprocessing a group of subjects
%----------------------------------------------------------------------

parameters.slicetiming.reference_slice='first'; %|'first'|middel| for realign to the first or middel (in time) slice of the volume 
parameters.slicetiming.slice_order = 'interleaved_ascending'; % 'sequential_ascending' | 'sequential_descending' | 'interleaved_ascending' | 'interleaved_descending'

%if the 2 next are defined it will overight the 2 preceding
%parameters.slicetiming.user_reference_slice = [4]; %refer to spatial slice number
%parameters.slicetiming.user_slice_order = [2:2:32,1:2:31];

%parameters.norm.template = ''; %precise the full path if not define will
                               %take spm default : T1 if seg or normalize  ant and EPI if normalize_mean_epi

			       
parameters.realign.to_first = 0; 	% 1: if realign to first (IRM), 0: if realign to mean (PET)		       
parameters.realign.estim_interp = 4; % 1 trilinear 2,3,..,7 is B-spline
parameters.realign.estim_quality = 1; % H_ighest quality (1) 

parameters.norm.outputGM = [1 1 1 ]; %Gray Matter output : modulated norm, unmodulated norm, native
parameters.norm.outputWM = [1 1 1 ]; %White Matter output : modulated norm, unmodulated norm, native
parameters.norm.outputCSF = [1 1 1 ]; %White Matter output : modulated norm, unmodulated norm, native

parameters.apply_norm.voxelsize = [1 1 1]; %voxel size used to normalize functional data
parameters.apply_norm.voxelsize = [1.5 1.5 1.5]; 
parameters.apply_norm.BoundingBox = [-78 -112 -60; 78 76 85]; 

parameters.smoothing = [2 2 2];

parameters.do_coreg_on_mean=1; %if defined do the coregistration of the mean fonctionel if not define use the first fonctinal on which all are aligned


%- Parameters for first level analyses of several subjects
%----------------------------------------------------------------------
%reference to a matfile containing 3 variables names durations onsets
%parameters.onset_matfile = {'onset/*irm1*.mat','onset/*irm2*.mat'};
%parameters.onset_matfile = {'onset/*1_croi*.mat','onset/*2_croi*.mat'};
%parameters.onset_matfile = {'onset/*irm2*.mat'};

 
%matfile containing a R matrix that define user regressor (not convolved)
%parameters.user_regressor.matfile = {'onsets/saccade_regressors_run1','onsets/saccade_regressors_run2','onsets/saccade_regressors_run3','onsets/saccade_regressors_run4'};


%Only used to skip functional volume for the stat (not for the preprocessing)
%parameters.skip ={[255:300],[]}; % 1:4; or [1:4,301,550:555] would not select the volume number given by this skip parameter but will not change the onset

  %regresseur de 242 volumes
  regress(1).name = 'ring_sin';
  %  regress(1).val = [sin(2*pi/32 * (0:2:7*32)),[0:2:28]*0,sin(2*pi/32 * (0:2:7*32))*0];
   regress(1).val =  [0,sin(2*pi/32 *( (0:2:(7*32-2))+(2-1.645))),zeros(1,129)];

  regress(2).name = 'ring_cos';
  regress(2).val = [0,cos(2*pi/32 *( (0:2:(7*32-2))+(2-1.645))),zeros(1,129)];
  regress(3).name = 'ring_sin_ccw';
  regress(3).val = [zeros(1,128),sin(2*pi/32 * ((0+0.3059):2:7*32)),zeros(1,2)];
  regress(4).name = 'ring_cos_ccw';
  regress(4).val = [zeros(1,128),cos(2*pi/32 * ((0+0.3059):2:7*32)),zeros(1,2)];
  reg{1} = regress;

  regress(1).name = 'wedge_sin';
  regress(1).val =  [0,sin(2*pi/32 *( (0:2:(7*32-2))+(2-1.645))),zeros(1,129)];
  regress(2).name = 'wedge_cos';
  regress(2).val = [0,cos(2*pi/32 *( (0:2:(7*32-2))+(2-1.645))),zeros(1,129)];
  regress(3).name = 'wedge_sin_ccw';
  regress(3).val = [zeros(1,128),sin(2*pi/32 * ((0+0.3059):2:7*32)),zeros(1,2)];
  regress(4).name = 'wedge_cos_ccw';
  regress(4).val = [zeros(1,128),cos(2*pi/32 * ((0+0.3059):2:7*32)),zeros(1,2)];
  reg{2} = regress;
  parameters.user_regressor.regress = reg;



parameters.HF_cut = 128;  % High-pass filter cutoff
parameters.bases.type = 'hrf+deriv'; % Canonical: 'hrf' | 'hrf+deriv' | 'hrf+2derivs'
parameters.bases.type = 'hrf'; % Canonical: 'hrf' | 'hrf+deriv' | 'hrf+2derivs'
% FIR => struct('type','fir','length',XXX,'order',XXX);
% Fourier =>   struct('type','fourier','length',XXX,'order',XXX);

%parameters.global_scaling = 'Scaling'; %if not define take the default none.

parameters.rp = 1;        % do not include realignment parameters as regressors if equal to 0
parameters.rpwc   = '^rp.*\.txt$';

%parameters.first_level_explicit_mask ='/home/romain/images/ppn/SecondLevel/rrr_tronc2iso.nii'; 

%parameters.global_scaling = 'Scaling';

parameters.microtime = 'default'; %'default'|'slicetimed' default use default from spm (onset 1 resolution 16) | slicetimed use onset = ref_slice resolution=nb of sliece

%parameters.microtime_resolution = 
%parameters.microtime_onset = 



parameters.contrast.values = {eye(8),[1 1 1 1 0 0 0 0 0 0 1 1 1 1 0 0],[1 1 1 1 0 0 0 0 0 0 1 1 1 1 0 0]};
parameters.contrast.names = {'effect of interest','onelineF','onelineT'};
parameters.contrast.types = {'F','F','T'};


parameters.contrast.delete_previous = 1;

parameters.report = struct('type','none', 'thresh',0.001,'extent',0);

parameters.email = 'firstname.lastname@toto.fr';
parameters.redo = 1;


parameters.rfxfolder = 'SecondLevel';

%parameters.modelname = 'Categorielle';

parameters.anova = 0;
%anova = 0 will do a one sample T test anova=1 will do a full factorial desing

parameters.factors(1) = struct('name','facteur1','levels',1,'dept',1,'variance',1,'gmsca',0,'ancova',0);
%parameters.factors(2) = struct('name','facteur2','levels',1,'dept',1,'variance',1,'gmsca',0,'ancova',0);
%parameters.factors(3) = struct('name','facteur3','levels',1,'dept',1,'variance',1,'gmsca',0,'ancova',0);

parameters.icon  = 'all'; %[1 2 3 4 5 6 7 8 9 10 11 12];'all'; %[1 2 3];
parameters.icon_factors_level  = {[1,1,1],[1,1,2],[1,1,1]};

%'dept' = 0|1 Independence = yes | no
%'variance' = 0|1  Equal | Unequal;
%'gmsca' = 0|1   grand mean scaling = no | yes
%'ancova' = 0|1   no | yes


%steps to use for the preprocessing

%parameters.do_preproc = {'slicetiming','realign','realign_and_reslice','normalize_mean_epi','normalize_anat','normalize_anat_affine','seg_and_norm_anat','coregister_fonc_on_anat','apply_anat_norm_on_fonc', 'smooth','display'};

%parameters.namecon = {'fff'};  %'face1','face2','face3'};
parameters.smooth_con = 4;
%parameters.logfile = 'rfx.log';
parameters.explicit_mask = 'group_mask_mean';%'group_mask_mean';%'graytemplate'
%parameters.explicit_mask = '/home/romain/data/images/ppn/SecondLevel/rfxmodel200/ima_swa_mvt_preproc_slice_timing/groupmask.img';
parameters.group_mask_threshold = 0.5;




parameters.do_preproc = {'realign_and_reslice','coregister_mean_fonc_on_raw_anat','smooth','run'};
parameters.do_preproc = {'slicetiming','realign_and_reslice','coregister_mean_fonc_on_raw_anat','smooth','display'};
parameters.do_preproc = {'realign','coregister_mean_fonc_on_raw_anat','seg_and_norm_anat','apply_anat_norm_on_fonc','smooth','display'};
parameters.do_preproc = {'slicetiming','realign','coregister_mean_fonc_on_raw_anat','seg_and_norm_anat','apply_anat_norm_on_fonc','smooth','run'};
parameters.do_preproc = {'slicetiming','realign','coregister_mean_fonc_on_raw_anat','seg_and_norm_anat','apply_anat_norm_on_fonc','smooth','display'};


%steps to use for first level analysis
%parameters.do_firstlevel = {'deletefiles','specify','estimate','deletecontrasts','contrasts','results','sendmail','display'};

parameters.do_secondlevel = {'smooth_contrast','mean_mask','specify','estimate','contrasts','run'};
parameters.do_secondlevel = {'mean_anat','display'};

parameters.do_firstlevel ={'specify','estimate','contrasts','run'};

