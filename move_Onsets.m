subjects_dir = '/Users/k.siudakrzywicka/Desktop/RDS_fMRI/Controls/Processed';
cd (subjects_dir);

group_dir = dir;
subs = {group_dir.name};
subs = subs(4:end);

for i = 2:length(subs)
    cd(subs{i})
    
    copyfile ( 'Onsets',...
        sprintf('/Users/k.siudakrzywicka/Desktop/RDS_fMRI/Controls/Processed_566_471_vol/%s/Onsets', subs{i}));
    cd ..
end