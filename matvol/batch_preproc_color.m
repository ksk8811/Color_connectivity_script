%%%%%%%%%%%%%%%%%%%%%%%%%
% Parameter definitions %
%%%%%%%%%%%%%%%%%%%%%%%%%

%- General definitions of directories etc.
% %----------------------------------------------------------------------
% % Set the correct paths for FSL to work properly
% PATH = getenv('PATH');
% if isempty(strfind(PATH,'fsl'))
% %setenv('PATH',[PATH ':/usr/share/fsl/5.0/bin']);
% setenv('PATH',[PATH ':/usr/lib/fsl/5.0']);
% end
% LD_LIBRARY_PATH = getenv('LD_LIBRARY_PATH');
% if isempty(strfind(LD_LIBRARY_PATH,'fsl'))
% setenv('LD_LIBRARY_PATH',[LD_LIBRARY_PATH ':/usr/lib/fsl/5.0'])
% end


%*************DATA SELECTION**************
%parameters.rootdir = '/DATA/COGDISS_fMRI_DATA';
parameters.rootdir = '/Users/k.siudakrzywicka/Desktop/COLORKNOWLEDGE_IRM/nifti/';

parameters.sujet_dir_wc={ '2016_06_22_NEUROPSY_DS_P01_V3'};

parameters.fonc_dir_wc='^func.*[123]$';
parameters.fonc_dir_oposit_phase = '_blip';
parameters.anat_dir_wc='structural';

%for the preprocessing : Volume selection
parameters.anatwc  = '^s.*\.nii$'; %le nom generique du volume pour l'anat
parameters.funcwc  = '^f.*\.nii$'; %le nom generique du volume pour les fonctionel

%for the first level
%%parameters.funcwc_analyse  = '^swutrf.*\.img$'; %les nom generique des volume pour l'analyse de premier niveau

%the 7 parameters above are set with a cell list of regular expresion. It will find the
%directory (or files) that macht the regular expression :
%'^f.*\.img$' : '^f' = begin with f   '.*' = anything    '\.'=.  'img$'=end with img
%'Sujet[123]' will find string that contain Sujet1 or Suejet2 or Sujet3

parameters.topupdir='topup';

parameters.TR = 1.260;

parameters.logfile = 'batch_up.log';

%the name of the directory used to store stats result

parameters.modelname = 'Rating';

%parameters.preproc_subdir = 'preproc_seg_norm'; % if not define all analisys are done
                                     %in the same dir as raw data. if define a subdirectory is created in each
                                     %series and the preprocessing is done in this subdir
%parameters.link_for_copy =1; % if define do a ln -s instead of a copy


%- Parameters for preprocessing a group of subjects
%----------------------------------------------------------------------

parameters.slicetiming.reference_slice='first'; %|'first'|middel| for realign to the first or middel (in time) slice of the volume 
parameters.slicetiming.slice_order = 'interleaved_ascending'; % 'sequential_ascending' | 'sequential_descending' | 'interleaved_ascending' | 'interleaved_descending'

%if the 2 next are defined it will overight the 2 preceding
%parameters.slicetiming.user_reference_slice = [4]; %refer to spatial slice number
%parameters.slicetiming.user_slice_order = [2:2:32,1:2:31];

%parameters.norm.template = ''; %precise the full path if not define will
                               %take spm default : T1 if seg or normalize  ant and EPI if normalize_mean_epi

parameters.realign.to_first = 1; 	% 1: if realign to first (IRM), 0: if realign to mean (PET)		       
parameters.realign.estim_interp = 4; % 1 trilinear 2,3,..,7 is B-spline
parameters.realign.estim_quality = 1; % H_ighest quality (1) 
%parameters.realign.single_series = 1; %if define and if not zero it will realign to the first image of each series
parameters.realign.reslice = 1;       %if define and if not zero it will it will write the reslice images

parameters.norm.outputGM = [1 0 0 ]; %Gray Matter output : modulated norm, unmodulated norm, native
parameters.norm.outputWM = [1 0 0 ]; %White Matter output : modulated norm, unmodulated norm, native
parameters.norm.outputCSF = [1 0 0 ]; %CSF output : modulated norm, unmodulated norm, native

parameters.apply_norm.voxelsize = [3 3 3]; %voxel size used to normalize functional data
parameters.apply_norm.interp = 4; %interpolation (0 nearest 1 trilinear n spline) used to normalize functional data
parameters.apply_norm.BoundingBox = [-78 -112 -60; 78 76 85]; 

parameters.smoothing = [3 3 3];

parameters.do_coreg_on_mean=1; %if true do the coregistration of the mean fonctionel if zero use the first fonctinal (on which all are aligned)


%- Parameters for first level analyses of several subjects
%----------------------------------------------------------------------
%reference to a matfile containing 3 variables names durations onsets. One per Series
%parameters.onset_matfile = {'onsets/*modelC_1.mat','onsets/*modelC_2.mat','onsets/*modelC_3.mat','onsets/*modelC_4.mat','onsets/*modelC_5.mat','onsets/*modelC_6.mat'};
%parameters.onset_matfile = {'onsets/modulation01*1.mat','onsets/modulation01*2.mat','onsets/modulation01*3.mat','onsets/modulation01*4.mat','onsets/modulation01*5.mat','onsets/modulation01*6.mat'};
%parameters.onset_matfile = {'onsets/modulationSemiCat*1.mat','onsets/modulationSemiCat*2.mat','onsets/modulationSemiCat*3.mat','onsets/modulationSemiCat*4.mat','onsets/modulationSemiCat*5.mat','onsets/modulationSemiCat*6.mat'};

parameters.onset_matfile = {['onsets',filesep,'onsets_rating1_ratings1']};

%params.reg_skip= {[1],[4 5], [2]}; %this will skip regressor 1 for session 1 regressor 4 and 5 for session 2 and reg 2 for session 3
%this is usful to test submodel without changing the .mat file. 

%matfile containing a R matrix that define user regressor (not convolved)
%parameters.user_regressor.matfile = {'onsets/saccade_regressors_run1','onsets/saccade_regressors_run2','onsets/saccade_regressors_run3','onsets/saccade_regressors_run4'};

%a third alternative is to directly specify the onset one cell per session
%       parameters.onset{1}(1).name = 'session1 reg1';
%       parameters.onset{1}(1).onset = (7:21:147)*3;
%       parameters.onset{1}(1).duration = ones(1,7)*21;
% 
%       parameters.onset{1}(2).name = 'session1 reg2';
%       parameters.onset{1}(2).onset = (14:21:147)*3;
%       parameters.onset{1}(2).duration = ones(1,7)*21;
% 
%       parameters.onset{2}(1).name = 'session2 reg1';
%       parameters.onset{2}(1).onset = (7:21:147)*3;
%       parameters.onset{2}(1).duration = ones(1,7)*21;
% 


%Only used to skip functional volume for the stat (not for the preprocessing)
%parameters.skip ={[255:300],[]}; % 1:4; or [1:4,301,550:555] would not select the volume number given by this skip parameter but will not change the onset

parameters.HF_cut = 128;  % High-pass filter cutoff
parameters.bases.type = 'hrf'; % Canonical: 'hrf' | 'hrf+deriv' | 'hrf+2derivs'
% FIR => parameters.bases = struct('type','fir','length',XXX,'order',XXX);
% Fourier =>   struct('type','fourier','length',XXX,'order',XXX);

%specify if you want a factorial desing at the first level
%parameters.first_level_factors(1) = struct('name','facteur1','levels',2);


%parameters.first_level_explicit_mask ='/home/irene/data/imamemus/masks/mwc1-mask-imamemus_01.img'; %absolute path to the .img mask file

parameters.rp = 1;        % do not include realignment parameters as regressors if equal to 0
parameters.rpwc   = '^rp.*\.txt$';

parameters.microtime = 'default'; %'default'|'slicetimed' default use default from spm (onset 1 resolution 16) | slicetimed use onset = ref_slice resolution=nb of sliece
%parameters.microtime.t = 44 ; %nombre de coupe
%parameters.microtime.t0 = 22; %coupe de reference

%parameters.microtime_resolution = 
%parameters.microtime_onset = 


%parameters.contrast.mfile='imamemus_contrasts_C17()';
%parameters.contrast.mfile='imamemus_contrasts_SemiCat_C21()';

% ModulationR1=[0 1 0 0 0 0 0 0];
% 
% %Or you can specify it directly
% parameters.contrast.values = {ModulationR1};
% parameters.contrast.names = {'modulationR1'};
% parameters.contrast.types = {'T'};


%a third way to define contrast by name of the condition
%parameters.contrast.string_def = {{1,'MIn',-1,'VIn'},{1,'MI',-2,'VI'},{1,'CAuE'},{1,'CIma'},{1,'AGAuE'},{1,'AGIma'},{1,'ABAuE'},{1,'ABIma'},{1,'PGAuE'},{1,'PGIma'},{1,'PBAuE'},{1,'PBIma'},{1,'Rec'},{'CAuE','CIma','AGAuE','AGIma','ABAuE','ABIma','PGAuE','PGIma','PBAuE','PBIma','Rec'}};
%parameters.contrast.name={}
%parameters.contrast.type={'T'};

% %parameters.contrast.mfile='split_contrasts';
% words=[1 0 0 0 1 0 0 0];
% faces=[0 1 0 0 0 1 0 0];
% houses=[0 0 1 0 0 0 1 0];
% tools=[0 0 0 1 0 0 0 1];
% 
% parameters.contrast.values = {words,...
% houses,...
% faces,...
% tools,...
% words.*3-(houses+faces+tools),...
% houses.*3-(words+faces+tools),...
% faces.*3-(words+houses+tools),...
% tools.*3-(words+houses+faces),...
% };
% 
% % % expand contrasts for a model with derivatives:
% % [a,b]=size(parameters.contrast.values);
% % for u=1:length(parameters.contrast.values)
% % parameters.contrast.values{u}=reshape([parameters.contrast.values{u};zeros(1,b)],1,2*b);
% % end
% 
% parameters.contrast.names = {'words','houses','faces','tools','words-others','houses-others','faces-others','tools-others'};
% parameters.contrast.types = {'T','T','T','T','T','T','T','T'};
% 
% %if you want to delete previously defined contrast
% parameters.contrast.delete_previous = 1;
% 
% %for the results
% parameters.report = struct('type','none', 'thresh',0.001,'extent',0);
% %type can be 'FWE' | 'FDR' | 'none'
% 
% %parameters.email = 'firstname.lastname@toto.fr';
% parameters.redo = 1;
% 
% 
% %- Parameters for second level analyses
% %----------------------------------------------------------------------
% parameters.rfxfolder = 'rfxmodel';
% 
% %parameters.modelname = ; 
% parameters.modelname = 'ModulationR1'; %'ModelC'all'Modul01'   %'ModelC_GP'Good performers {'C0[23789]$','C1[12345678]$','C2[02]$'} %ModelC_partial only 'C0[12357]$','C1[2689]$'
% 
% parameters.anova = 0;
% %anova = 0 will do a one sample T test 
% %anova = -1 will do a two sample T test you must then define sujet_group1_dir_wc sujet_group1_dir_wcand sujet_dir_wc
% %anova=1 will do a full factorial desing
% %anova=2 will do a flexible factorial desing
% 
% %if anova=1 the factor should have the following fields
% %parameters.factors(1) = struct('name','facteur1','levels',2,'dept',0,'variance',1,'gmsca',0,'ancova',0);
% %parameters.factors(2) = struct('name','facteur2','levels',2,'dept',1,'variance',1,'gmsca',0,'ancova',0);
% %parameters.factors(3) = struct('name','facteur3','levels',2,'dept',1,'variance',1,'gmsca',0,'ancova',0);
% 
% %if anova=2 the factor should have the following fields
% %parameters.factors(1) = struct('name','repl','dept',1,'variance',1,'gmsca',0,'ancova',0);
% %parameters.factors(2) = struct('name','subject','dept',0,'variance',1,'gmsca',0,'ancova',0);
% %to define main effect or interaction ex: 2 main effect 1 inter
% %parameters.maininters{1}.fmain.fnum = 1;
% %parameters.maininters{2}.fmain.fnum = 2;
% %parameters.maininters{3}.inter.fnums = [1 ;2];
% 
% 
% %for 2nd level covariate (anova 1 or 2)
% %parameters.covariate(1).cname = 'AUCA';
% %parameters.covariate(1).c = [0.589163237311385 0.657750342935528 0.796296296296296 0.502572016460905 0.547496570644719 0.550754458161866 0.83659122085048 0.788065843621399 0.733196159122085 0.579046639231824 0.706447187928669 0.63923182441701 0.722908093278464 0.717592592592592 0.863340192043896 0.68724279835391 0.627572016460905 0.763374485596708 0.560013717421125 0.756172839506173 0.504115226337449 0.682956104252401]; %cvariate vector value
% %parameters.covariate(1).iCC = 1 ; %centering (index num in the spm interface) 1 is mean
% %parameters.covariate(1).iCFI = 1 ; %Interaction (index num in the spm interface) 1 is none
% %replicate the same with parameters.2ndleve_covariate(2) for a second covariate
% %parameters.covariate(2).cname = 'AUCP';
% %parameters.covariate(2).c = [0.655349794238683 0.821502057613169 0.888717421124829 0.713648834019204 0.835733882030178 0.735253772290809 0.785322359396433 0.849279835390946 0.810871056241427 0.664437585733882 0.843449931412894 0.685356652949246 0.71656378600823 0.867455418381344 0.864540466392318 0.700788751714678 0.64437585733882 0.799897119341564 0.645061728395062 0.780178326474623 0.713305898491084 0.800925925925926]; %cvariate vector value
% %parameters.covariate(2).iCC = 1 ; %centering (index num in the spm interface) 1 is mean
% %parameters.covariate(2).iCFI = 1 ; %Interaction (index num in the spm interface) 1 is none
% 
% 
% parameters.icon  = 'all'; %[1 2 3];
% %parameters.icon_factors_level  = {[1,1,1],[1,1,2],[1,1,1],[1,1,2]};
% %'dept' = 0|1 %Independence = yes | no
% %'variance' = 0|1 % Equal | Unequal;
% %'gmsca' = 0|1   %grand mean scaling = no | yes
% %'ancova' = 0|1  % no | yes
% %parameters.contrast.mfile='imamemus_contrasts()';
% 
% 
% parameters.namecon = {'toto'};  %'face1','face2','face3'};
% parameters.smooth_con = 0;
% %parameters.logfile = 'rfx.log';
% %parameters.explicit_mask = 'group_mask_mean';%'group_mask_mean';%'graytemplate'
% parameters.group_mask_threshold = 0.999;
% 
% %parameters.distrib.subdir='distrib';   % optionel default value
% %parameters.sge_queu = 'server_matlab'; % optionel default value
% 
% %parameters.free_sujdir = '/home/romain/data/spectro/PROTO_SPECTRO_DYST/anat/FreeSeg2';
% 
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% run the following steps for preprocessing %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%parameters.do_preproc = {'freesurfer','run_dist_free'};

%parameters.do_preproc = {'slicetiming','realign','realign_and_reslice','normalize_mean_epi','normalize_mean_epi_affine','normalize_anat','normalize_anat_affine','seg_and_norm_anat','seg_and_norm_vbm','coregister_fonc_on_anat','coregister_mean_fonc_on_anat','coregister_anat_on_mean_fonc','coregister_mean_fonc_on_Template_apply_on_raw_anat','apply_anat_norm_on_fonc','apply_mean_epi_norm_on_fonc','apply_mean_epi_norm_on_fonc_and_anat', 'smooth','display','run'};

parameters.do_preproc = {'slicetiming','realign','coregister_anat_on_mean_fonc','coregister_mean_fonc_on_Template_apply_on_raw_anat','seg_and_norm_anat','apply_anat_norm_on_fonc','smooth','run'};

%parameters.do_preproc = {'realign','topup_unwarp','coregister_anat_on_mean_fonc','coregister_mean_fonc_on_Template_apply_on_raw_anat','seg_and_norm_anat','apply_anat_norm_on_fonc','smooth','run'};

%parameters.do_preproc = {'remove_last','realign','topup_unwarp','coregister_anat_on_mean_fonc','seg_and_norm_anat','apply_anat_norm_on_fonc','smooth','run'};
%parameters.do_preproc = {'remove_last','realign','topup_unwarp','coregister_anat_on_mean_fonc','seg_and_norm_anat','apply_anat_norm_on_fonc','smooth','run'};
%parameters.do_preproc = {'realign','topup_unwarp','coregister_anat_on_mean_fonc','coregister_mean_fonc_on_Template_apply_on_raw_anat','seg_and_norm_anat','apply_anat_norm_on_fonc','smooth','display'};

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % run the following steps for 1st level.%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% %parameters.do_firstlevel = {'deletefiles','specify','estimate','deletecontrasts','contrasts','results','sendmail','display'};
% 
% %parameters.do_firstlevel = {'specify','estimate','contrasts','display'};
% %parameters.do_firstlevel = {'specify','estimate','display'}; %,
% %parameters.do_firstlevel = {'contrasts','run'};
% parameters.do_firstlevel = {'specify','estimate','contrasts','run'};
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % run the following steps for 2nd level ana.%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% % parameters.do_secondlevel = {'smooth_contrast','run'};
% % parameters.do_secondlevel = {'smooth_contrast','mean_mask','specify','display','run'};
% %parameters.do_secondlevel = {'smooth_contrast','mean_mask','specify','estimate','contrasts','results','run'};'contrasts',
% %parameters.do_secondlevel = {'mean_mask','specify','estimate','contrasts','display'};
% parameters.do_secondlevel = {'mean_mask','specify','estimate','contrasts','run'};
