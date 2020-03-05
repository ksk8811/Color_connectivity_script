%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% WARNING!!!
% the selected models on which task the partcicipant did first!!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


chemin={'/media/NewData/champignon/data/'};
% suj = get_subdir_regex(pwd,'^2')
%suj = get_subdir_regex(chemin);
%suj_root=suj;
suj = get_subdir_regex(chemin,'^subj');
% addpath('/media/NewData/champignon/tools/functions/')
par.run=0;par.display=1; 

for i=1:length(suj)
   suj{i}=[suj{i} '/comb_data/'];
end

suj

dirout='/media/NewData/champignon/second_level_with_congr_effect_noder_s4';


% second level

st = get_subdir_regex(suj,'^stat$','^champi_nopress$')

j = job_second_level_ttest(st,dirout,par)
spm_jobman('run',j)
% spm_jobman('run',j)


