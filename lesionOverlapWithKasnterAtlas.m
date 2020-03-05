clear
clc

addpath(genpath('/Users/k.siudakrzywicka/Desktop/tools/MATLAB_repository/NIfTI_20140122'))
addpath(genpath('/Users/k.siudakrzywicka/Desktop/tools/MATLAB_repository/spm12'))

cd '/Users/k.siudakrzywicka/Dropbox (PICNIC Lab)/Kasia/Colors/RdS/neuroimaging/ProbAtlas_v4/subj_vol_all/';
rois = dir('per*lh*.nii');
rois = {rois.name}';

lesion_RDS = load_nii('/Users/k.siudakrzywicka/Desktop/RDS_AC/Lesions/clusterize_lesion_final.nii');
lesion_AC = load_nii('/Users/k.siudakrzywicka/Desktop/RDS_AC/Lesions/OTHAC_bin.nii');

lesions = {lesion_RDS; lesion_AC};

labels = readtable('/Users/k.siudakrzywicka/Dropbox (PICNIC Lab)/kasia/colors/rds/neuroimaging/ProbAtlas_v4/ROIfiles_Labeling.txt');
labels = labels(:, [2 4]);
labels.Properties.VariableNames = {'Number', 'Name'};

ProbAtlasOverlap = cell2table(cell(50,6), 'VariableNames',{'Patient', 'ROI', 'Full', 'Perc90th', 'nVoxFull', 'nVoxPerc75th'});
%for i = 1:length(rois)
for p = 1:length(lesions)
    
    for i = 1:length(rois)

    roi = load_nii(rois{i});
    linroi = roi.img(:);
    Perc90th = prctile(linroi(find(linroi)), 90);
    %create an overlapping image, mask ROI by the lesion
    lesion = im2uint8(lesions{p}.img);

    overlap_fullProbability = lesion.*roi.img;

    upper90Probability = roi.img.*(uint8(roi.img>Perc90th));

    overlap_upper90Probablity = lesion.*upper90Probability;

    percent_of_ROI_full = nnz(overlap_fullProbability(:))/nnz(roi.img(:))*100;
    percent_of_ROI_90Prob = nnz(overlap_upper90Probablity(:))/nnz(upper90Probability(:))*100;

    ROInum = str2double(rois{i}(18:19));
    if ~isnan(ROInum)
        ROIname = labels.Name(labels.Number==ROInum);
    else
        ROIname = labels.Name(labels.Number==str2double(rois{i}(18)));
    end

    result = {p, ROIname, percent_of_ROI_full, percent_of_ROI_90Prob, nnz(roi.img(:)), nnz(upper90Probability(:))};
    ProbAtlasOverlap{(p-1)*length(rois)+i, :} = result;
    end
end

% to_plot = [ProbAtlasOverlap.Perc90th{:}];
% ventral_sort = [11, 19, 21, 23, 24, 25, 1, 2];
% to_plot = to_plot(ventral_sort);
% colors = [83 41 15; 138 0 86; 40 22 83; 11 82 139; 36 88 35; 134 140 33; 195 85 23; 138 10 22]./255;
% 
% figure
% hold on
% for i = 1:length(to_plot)
%         h = bar(i, to_plot(i));
%         set(h, 'FaceColor', colors(i,:)) 
% end
% hold off
% 
% labels = ProbAtlasOverlap.ROI(ventral_sort);
% ylabel('% affected by the lesion','fontsize', 16, 'fontname', 'Arial')
% xlabel('Region', 'fontsize', 16)
% set(gca,'xticklabel', [' ',labels{:}], 'fontsize', 16, 'fontname', 'Arial')
% 
% 

