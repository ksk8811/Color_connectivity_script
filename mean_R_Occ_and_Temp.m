clear
clc
addpath(genpath('/Users/k.siudakrzywicka/Desktop/tools/spm12'))
cd('/Users/k.siudakrzywicka/Desktop/RDS_fMRI/Controls/resting_indirect_IBM/results/firstlevel/semipartial');

x = dir('corr_Subject0*_Condition001_Source001.nii');
subs = {x.name}';

Occ_Mask = '/Users/k.siudakrzywicka/Desktop/RDS_fMRI/Review/Occipital&Temporal_Variance/Occipital_L.nii';
Temp_Mask = '/Users/k.siudakrzywicka/Desktop/RDS_fMRI/Review/Occipital&Temporal_Variance/Temporal_L_chopped.nii';

result = cell(length(subs), 3);

for i = 1:length(subs)
%% create masks (with imcalc cause by hand didn't work/weird stuff happened)    
    matlabbatch{1}.spm.util.imcalc.input = {
                                            [subs{i} ',1']
                                            [Occ_Mask ',1']
                                            };
    matlabbatch{1}.spm.util.imcalc.output = ['Occ_Masked_' subs{i}];
    matlabbatch{1}.spm.util.imcalc.outdir = {''};
    matlabbatch{1}.spm.util.imcalc.expression = 'i1.*i2';
    matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
    matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
    matlabbatch{1}.spm.util.imcalc.options.mask = 0;
    matlabbatch{1}.spm.util.imcalc.options.interp = 1;
    matlabbatch{1}.spm.util.imcalc.options.dtype = 4;
    
    matlabbatch{2}.spm.util.imcalc.input = {
                                            [subs{i} ',1']
                                            [Temp_Mask ',1']
                                            };
    matlabbatch{2}.spm.util.imcalc.output = ['Temp_Masked_' subs{i}];
    matlabbatch{2}.spm.util.imcalc.outdir = {''};
    matlabbatch{2}.spm.util.imcalc.expression = 'i1.*i2';
    matlabbatch{2}.spm.util.imcalc.var = struct('name', {}, 'value', {});
    matlabbatch{2}.spm.util.imcalc.options.dmtx = 0;
    matlabbatch{2}.spm.util.imcalc.options.mask = 0;
    matlabbatch{2}.spm.util.imcalc.options.interp = 1;
    matlabbatch{2}.spm.util.imcalc.options.dtype = 4;

    spm_jobman('run',matlabbatch)
    %% calculate mean Z
    masked_image_occ = spm_read_vols(spm_vol(['Occ_Masked_' subs{i}]));
    masked_image_temp = spm_read_vols(spm_vol(['Temp_Masked_' subs{i}]));
    
    masked_image_occ_lin = masked_image_occ(:);
    masked_image_temp_lin = masked_image_temp(:);
    
    
    occ_mean_z = mean(masked_image_occ_lin(masked_image_occ_lin~=0));
    temp_mean_z = mean(masked_image_temp_lin(masked_image_temp_lin~=0));
    
    result{i, 1} = subs{i}(13:15);
    result{i, 2} = occ_mean_z;
    result{i, 3} = temp_mean_z;
    
end

addpath('/Users/k.siudakrzywicka/Dropbox (PICNIC Lab)/Kasia/Colors/Color categorisation/Case_study/tools/Single Case t-test rsdt');
addpath('/Users/k.siudakrzywicka/Dropbox (PICNIC Lab)/Kasia/Colors/Color categorisation/Case_study/tools/BayesFactors')


RDST_and_ttests(cell2mat(result(2:end, 2)),cell2mat(result(1, 2)), cell2mat(result(2:end, 3)),cell2mat(result(1, 3)), 0.05./2)
%%
addpath('/Users/k.siudakrzywicka/Dropbox (PICNIC Lab)/Kasia/Colors/Color categorisation/Case_study/tools/UnivarScatter_v1.0');

figure ('units', 'inches')
UnivarScatter(cell2mat(result(2:end, 2:3)), 'PointSize', 50 )
hold on
plot(cell2mat(result(1, 2:3)),...
    'linestyle','none',...
    'Color', 'k', ...%[0.1216    0.4706    0.7059], ...
    'Marker', 'p', ...
    'MarkerEdgeColor', 'black',....
    'MarkerFaceColor','k', 'MarkerSize', 10)
hold off
set(gca, 'xticklabel', {'Occipital', 'Temporal'})
set(gca, 'fontsize', 18)
set(gcf,'Units','inches','Position',[0 0 5 7])

addpath('/Users/k.siudakrzywicka/Dropbox (PICNIC Lab)/Kasia/Colors/Color categorisation/Case_study');

plot2pdf('occ_and_temp_activity.pdf')




