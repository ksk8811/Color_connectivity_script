%% copy subjects from the Raws folder 
cd ('/Users/k.siudakrzywicka/Desktop/Fabien_patient')
tmp = dir;
files = {tmp.name};
files = files(3:end);

for i = 1:length(files)
    newDir = ['/Users/k.siudakrzywicka/Desktop/Fabien_patient/' files{i}(end-3:end)];
    mkdir (newDir)
    to_copy = {'S03*', 'S08*', 'S09*'};
    for j = 1:length(to_copy)
        copyfile([files{i} '/' to_copy{j}], newDir)
    end
end
%% rename subfolders
cd ('/Users/k.siudakrzywicka/Desktop/Fabien_patient')

tmp = dir;
files = {tmp.name};
files = files(4);

for i = 1:length(files)
    cd(files{i})
    anat = dir('S03*');
    func_1_blip = dir('S08*');
    func_1 = dir('S09*');
%     func_2_blip = dir('S10*');
%     func_2 = dir('S11*');
    

    movefile(anat.name, 'structural')

    movefile(func_1_blip.name, 'func_1_blip')

    movefile(func_1.name, 'func_1')

%     movefile(func_2_blip.name, 'func_2_blip')
% 
%     movefile(func_2.name, 'func_2')
    cd ..
   
end

%% cut the last scans, and the uneven volumes
subjects_dir = '/Users/k.siudakrzywicka/Desktop/Fabien_patient';


for i = 1
    cd([subjects_dir '/' files{i}])
    subject_dir = dir('func*');
    subject_dir = {subject_dir.name};
    for j = 1:length(subject_dir)
        image_dir = subject_dir{j};
        cd(image_dir)
        file = dir('f*');
        file = file.name;
        
        if ~isempty(strfind(subject_dir{j}, '1')) & isempty(strfind(subject_dir{j}, 'blip'))
           file = dir('f*.nii.gz');
           file = file.name;
           system([ 'fslroi  ' pwd '/' file ' ' pwd ['/' file(1:end-7) '_566.nii 0 566']])
           system([ 'fslroi  ' pwd ['/' file(1:end-7) '_566.nii'] ' ' pwd ['/' file(1:end-7) '_566_cut.nii 0 -1 0 -1 1 44']])
           gunzip([file(1:end-7) '_566_cut.nii.gz'])
           
%         elseif ~isempty(strfind(subject_dir{j}, '2')) & isempty(strfind(subject_dir{j}, 'blip'))
%             file = dir('f*.nii.gz');
%             file = file.name;
%             system([ 'fslroi  ' pwd '/' file ' ' pwd ['/' file(1:end-7) '_471.nii 0 471']])
%             system([ 'fslroi  ' pwd ['/' file(1:end-7) '_471.nii'] ' ' pwd ['/' file(1:end-7) '_471_cut.nii 0 -1 0 -1 1 44']])
%             gunzip([file(1:end-7) '_471_cut.nii.gz'])
            
        elseif ~isempty(strfind(subject_dir{j}, 'blip'))
            file = dir('f*.nii.gz');
            file = file.name;
            system([ 'fslroi  ' pwd ['/' file] ' ' pwd ['/' file(1:end-7) '_cut.nii 0 -1 0 -1 1 44']])
            gunzip([file(1:end-7) '_cut.nii.gz'])
            
        end
        
        cd ..
    end
    cd ..
end
