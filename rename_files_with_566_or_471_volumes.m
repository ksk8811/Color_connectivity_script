
clear
clc

subjects_dir = '/Users/k.siudakrzywicka/Desktop/RDS_fMRI/Controls/Processed_566_471_vol';
cd (subjects_dir);

group_dir = dir;
subs = {group_dir.name};
subs = subs(3:end);

for i = 2:length(subs)
    cd([subjects_dir '/' subs{i}])
    
    func_dir = file_names('f*');
    for j = 1:length(func_dir)
        cd(func_dir{j})
        if isempty(strfind(func_dir{j}, 'blip'))
            func_file = file_names('*iso_cut.nii');
            delete(func_file{:})
%             movefile(func_file{:}, [func_file{:}(1:end-12) func_file{:}(end-7:end-4) func_file{:}(end-11:end-8) '.nii'])
        end
        cd ..
    end
    cd ..
end