models_words = {'faces_vs_(houses+tools)', 'houses_vs_(faces+tools)', 'tools_vs_(faces+houses)'};
model_color = {'all_color_vs_greyscale'};

cd('/Users/k.siudakrzywicka/Desktop/RDS_fMRI/Controls/second_level/words_final');

for i = length(models_words)
    cd(models_words{i})
        statsImgDir =  pwd;
        statsImgFile= 'ResMS.nii';
        maskFile  = fullfile(statsImgDir, 'mask.nii');
        rmm = 5;
        pthr = 0.005;
        iter = 1000; 

        [trshld] = MonteCarlo(statsImgDir,statsImgFile,maskFile, rmm, pthr, iter);
    cd ..
end

cd('/Users/k.siudakrzywicka/Desktop/RDS_fMRI/Controls/second_level/color_final');
for i = length(model_color)
    cd(model_color{i})
        statsImgDir =  pwd;
        statsImgFile= 'ResMS.nii';
        maskFile  = fullfile(statsImgDir, 'mask.nii');
        rmm = 5;
        pthr = 0.005;
        iter = 1000; 

        [trshld] = MonteCarlo(statsImgDir,statsImgFile,maskFile, rmm, pthr, iter);
    cd ..
end