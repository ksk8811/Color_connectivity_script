clear
clc

cd ('/Users/k.siudakrzywicka/Desktop/RDS_fMRI/Controls/Raws')
files = dir('*');
files = {files.name};


for i = 4:length(files)
    newDir = ['/Users/k.siudakrzywicka/Desktop/RDS_fMRI/Controls/color_rs_connectivity/' sprintf('subject_%0.2d', i-3)];
    mkdir (newDir)
    to_copy = {'*T1_1mm', '*rest*'};
    for j = 1:2
        copyfile([files{i} '/' to_copy{j} '/'], newDir)
    end
    
end

