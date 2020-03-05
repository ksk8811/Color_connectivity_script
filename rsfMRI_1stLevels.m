%% Create first level functional connectivity maps

%directory = '/Users/k.siudakrzywicka/Desktop/RDS_fMRI/Controls/resting_indirect/resting_controls_RDS2017/results/firstlevel/ANALYSIS_03';

subjects = 1; % choose the first subject, RDS
sources = 1:4; %this is the VWFA sourse (check the sources lists)
p_value = 0.001; %voxel wise threshold
correction = 'FDR'; %uncorrected (yes or no)
%small_clusters = 50; 

for s = 1:length(subjects)
    for i = 1:length(sources)
        
        pattern = sprintf('*Subject%0.3d*Source%03d.nii', subjects(s), sources(i));
        
        files = dir(pattern);
        files = {files.name};
        files = strcat(files, ',1')';
        
        
        
        matlabbatch{1}.spm.util.imcalc.input = files([1 3]);
        matlabbatch{1}.spm.util.imcalc.output = sprintf('FirstLevel_Subject%0.3d_Source%03d_p_%0.3f_%s.nii',subjects(s), sources(i), p_value, correction) ;
        matlabbatch{1}.spm.util.imcalc.outdir = {''};
        matlabbatch{1}.spm.util.imcalc.expression = ['i1.*(i2<' num2str(p_value) ')'];
        matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
        matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
        matlabbatch{1}.spm.util.imcalc.options.mask = 0;
        matlabbatch{1}.spm.util.imcalc.options.interp = 1;
        matlabbatch{1}.spm.util.imcalc.options.dtype = 4;
        
        spm_jobman('run', matlabbatch)
        %% filter out small clusters

        %cluster_size_threshold( matlabbatch{1}.spm.util.imcalc.output, small_clusters);
    end
end

% %% calculate mean first-level image for all controls
% pattern2 = 'corr_Subject*_Condition001_Source001.nii';
% files = dir(pattern2);
% files = {files.name};
% files = strcat(files, ',1')';
% 
% 
% matlabbatch{1}.spm.util.imcalc.input = files(2:end);
% matlabbatch{1}.spm.util.imcalc.output = sprintf('MeanControls_Source1_unthresholded.nii') ;
% matlabbatch{1}.spm.util.imcalc.outdir = {''};
% matlabbatch{1}.spm.util.imcalc.expression = '(i1+i2+i3+i4+i5+i6+i7+i8+i9+i10+i11+i12+i13+i14)/14';
% matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
% matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
% matlabbatch{1}.spm.util.imcalc.options.mask = 0;
% matlabbatch{1}.spm.util.imcalc.options.interp = 1;
% matlabbatch{1}.spm.util.imcalc.options.dtype = 4;
% 
% spm_jobman('run', matlabbatch)



