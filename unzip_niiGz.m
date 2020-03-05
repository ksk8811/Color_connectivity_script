
clear
clc

subjects_dir = '/Users/k.siudakrzywicka/Desktop/RDS_fMRI/Controls/Processed_566_471_vol';
cd (subjects_dir);

group_dir = dir;
subs = {group_dir.name};
subs = subs(4:end);

for i = 15:length(subs)
    cd([subjects_dir '/' subs{i} '/structural/'])
    anat_file = file_names('*nii.gz');
    gunzip(anat_file)
    to_remove = file_names('*gz');
    delete(to_remove{:});
    cd ..
    
%     cd([subjects_dir '/' subs{i} '/func_1_blip/'])
%     anat_file = file_names('*_cut.nii.gz');
%     gunzip(anat_file)
% %     to_remove = file_names('*gz');
% %     delete(to_remove{:});
%     cd ..
%     
%     cd([subjects_dir '/' subs{i} '/func_2_blip/'])
%     anat_file = file_names('*_cut.nii.gz');
%     gunzip(anat_file)
% %     to_remove = file_names('*gz');
% %     delete(to_remove{:});
%     cd ..
    
    
    
%     func_dir = file_names('f*');
%     for j = 1:length(func_dir)
%         cd(func_dir{j})
%         if isempty(strfind(func_dir{j}, 'blip'))
%             func_file = file_names('*_cut_*.nii.gz');
%             gunzip(func_file)
%             to_remove = file_names('*_cut_*.nii.gz');
%             delete(to_remove{:});
%         else
%             func_file = file_names('*_cut.nii.gz');
%             gunzip(func_file)
%             to_remove = file_names('*_cut.nii.gz');
%             delete(to_remove{:});
%         end
%         cd ..
%     end
%     cd ..
end