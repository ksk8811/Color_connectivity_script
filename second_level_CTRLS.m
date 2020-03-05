%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% WARNING!!!
% the selected models on which task the partcicipant did first!!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear
clc

subjects_dir={'/Users/k.siudakrzywicka/Desktop/RDS_fMRI/Controls/Processed_566_471_vol'};

suj = get_subdir_regex(subjects_dir,'^10*');

par.run=0;
par.display=1;

dirout_words = '/Users/k.siudakrzywicka/Desktop/RDS_fMRI/Controls/second_level/words_final';
dirout_color = '/Users/k.siudakrzywicka/Desktop/RDS_fMRI/Controls/second_level/color_final';

if ~exist(dirout_words, 'dir')
    mkdir(dirout_words)
end

if ~exist(dirout_color, 'dir')
    mkdir(dirout_color)
end


%% second level WORDS

st = get_subdir_regex(suj,'stats_words')

j = job_second_level_ttest(st,dirout_words,par)
spm_jobman('run',j)


%% second level COLORS

st = get_subdir_regex(suj,'stats_color')

j = job_second_level_ttest(st,dirout_color,par)
spm_jobman('run',j)




