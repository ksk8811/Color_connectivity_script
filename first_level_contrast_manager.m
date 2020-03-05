%-----------------------------------------------------------------------
% Job saved on 15-Oct-2019 09:46:57 by cfg_util (rev $Rev: 6942 $)
% spm SPM - SPM12 (7219)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------

%      1      'object_wrong_color'                 
%      2      'object_grey_scale'                  
%      3      'mondirans_grey_scale'               
%      4      'mondrian_color'                     
%      5      'object_good_color' 
subjs = fileNames('/Users/k.siudakrzywicka/Desktop/RDS_fMRI/Controls/Processed_566_471_vol');
model = color; %words

for s = 1:length(subjs)
    
    matlabbatch{1}.spm.stats.con.spmmat = {fullfile('/Users/k.siudakrzywicka/Desktop/RDS_fMRI/Controls/Processed_566_471_vol/', subjs{s}, ['stats_' model], SPM.mat')};
    matlabbatch{1}.spm.stats.con.consess{1}.tcon.name = '<UNDEFINED>';
    matlabbatch{1}.spm.stats.con.consess{1}.tcon.weights = '<UNDEFINED>';
    matlabbatch{1}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    matlabbatch{1}.spm.stats.con.consess{2}.tcon.name = '<UNDEFINED>';
    matlabbatch{1}.spm.stats.con.consess{2}.tcon.weights = '<UNDEFINED>';
    matlabbatch{1}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
    matlabbatch{1}.spm.stats.con.delete = 0;
end