
addpath('/Users/k.siudakrzywicka/Dropbox (PICNIC Lab)/Kasia/Colors/Color categorisation/Case_study/tools/errorbar_groups');
addpath('/Users/k.siudakrzywicka/Desktop/tools/MATLAB_repository');

rootdir = '/Users/k.siudakrzywicka/Desktop/RDS_fMRI/Controls/functional_rois/patient';
cd(rootdir)


color = dir(fullfile(rootdir, '/*color*k_nonBin.nii'));
color = {color.name};

domains = dir(fullfile(rootdir, '*360vox_p<0.005biggest_cluster_nonBin.nii'));
domains = {domains.name};
domains = reshape(domains, 3, 2);

names = {'colors', 'faces', 'houses', 'tools'}; 
images_to_add = [color;domains];

activity_levels = zeros(4,2);
errors = zeros(4,2);

for i = 1:length(images_to_add)
    im1 = spm_read_vols(spm_vol(images_to_add{i, 1}));
    im2 = spm_read_vols(spm_vol(images_to_add{i, 2}));
    
    im1_lin = im1(:);
    im2_lin = im2(:);
    
    im1_lin_non0 = im1_lin(im1_lin>0);
    im2_lin_non0 = im2_lin(im2_lin>0);
    
    
    mean1 = mean(im1_lin_non0);
    sem1 = std(im1_lin_non0)/sqrt(length(im1_lin_non0));
    
    mean2 = mean(im2_lin_non0);
    sem2 = std(im2_lin_non0)/sqrt(length(im2_lin_non0));

%     im1(isnan(im1)) = 0;
%     im2(isnan(im2)) = 0;
% 
%     result = im1+im2;
% 
%     new_nifti_file = spm_vol(images_to_add{i, 1});     % using the functional image parameters to save a new NIFTI image of the mask
%     new_nifti_file.fname = [names{i} '_bilateral_nonBin.nii']; 
%     new_nifti_file.private.dat.fname =  [names{i} '_bilateral_nonBin.nii'];
%     spm_write_vol(new_nifti_file,result); 
%     
    activity_levels(i,:) = [mean1, mean2];
    errors(i,:) = [sem1, sem2];
    
end% THE OUTPUT DIRECTORY MUST ALREADY EXIST FOR THIS TO WORK





figure
errorbar_groups(activity_levels([1,3], :)', errors([1,3],:)', 'errorbar_width', 0.2, ...
    'bar_colors', [0 0 0; 0.9 0.9 0.9],...
    'bar_names', {'Colors','Houses'},...
    'optional_bar_arguments', {'LineWidth', 1.5}, ...
    'optional_errorbar_arguments',{'LineStyle','none','Marker','none','LineWidth',1.5});
ylabel ('t')
legend({'left' 'right'}, 'Location', 'northwest')
set(gca,'fontsize', 30)
set(gca,'ylim', [1 5])
plot2pdf('activity_levels_unilat.pdf')


errorbar_groups(activity_levels([2,4], :)', errors([2,4],:)', 'errorbar_width', 0.2, ...
    'bar_colors', [0 0 0; 0.9 0.9 0.9],...
    'bar_names', {'Faces', 'Tools'},...
    'optional_bar_arguments', {'LineWidth', 1.5}, ...
    'optional_errorbar_arguments',{'LineStyle','none','Marker','none','LineWidth',1.5});
ylabel ('t')
legend({'left' 'right'}, 'Location', 'northwest')
set(gca,'fontsize', 30)
set(gca,'ylim', [1 5])
plot2pdf('activity_levels_bilat.pdf')