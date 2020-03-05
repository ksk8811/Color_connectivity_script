
clear
clc

subjects_dir = '/Users/k.siudakrzywicka/Desktop/RDS_fMRI/Controls/Processed_566_471_vol';
cd (subjects_dir);

group_dir = dir;
subs = {group_dir.name};
subs = subs(3:end);

for i = [2 3 4 5 7 8]
    cd([subjects_dir '/' subs{i}])
    subject_dir = dir('func*');
    subject_dir = {subject_dir.name};
    for j = 1%:length(subject_dir)
        image_dir = subject_dir{j};
        cd(image_dir)
        file = dir('f*');
        file = file.name;
        system([ 'fslroi  ' pwd '/' file ' ' pwd ['/' file(1:end-7) '_cut.nii 0 -1 0 -1 1 44']])
        
        if ~isempty(strfind(subject_dir{j}, '1')) & isempty(strfind(subject_dir{j}, 'blip'))
           file = dir('f*cut.nii.gz');
           file = file.name;
           system([ 'fslroi  ' pwd '/' file ' ' pwd ['/' file(1:end-7) '_566.nii 0 566']])
        elseif ~isempty(strfind(subject_dir{j}, '2')) & isempty(strfind(subject_dir{j}, 'blip'))
            file = dir('f*cut.nii.gz');
            file = file.name;
            system([ 'fslroi  ' pwd '/' file ' ' pwd ['/' file(1:end-7) '_471.nii 0 471']])
        end
        
        cd ..
    end
    cd ..
end