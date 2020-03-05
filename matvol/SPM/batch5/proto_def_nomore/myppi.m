sujrootdir = 'E:\ANGER_SA_2008\IRM data nov 2008\Raw data\';

s_dir = get_subdir_regex(sujrootdir,{'^S[1234567890]'});
s_dir = get_subdir_regex(sujrootdir,{'^S5$'});
%if you want to choose graphicaly
%s_dir = get_subdir_regex(sujrootdir,'graphically');

stat_dir = get_subdir_regex(s_dir,'stats','Analyse1stlevel')

logfile = 'VOI_Rectus.log';

%contrast definition for voi selection
voicon.contrast = 2; %contrast number
voicon.thrdesc='none'; % correction
voicon.thresh = 1;
voicon.title = 'contrast 2';

VOI_coord = [10 32 -16];
%VOI_coord = [24 -50 -24;12 14 15;15 15 15;14 15 10]; pour avoir des
%coordonne differente pour chaque sujet

%3iem alternative pour definir les coordonnees : ecrire des fichiers texte (avec les coordonnees)
%dans un sous repertoir du sujet et donner comme argument ces fichiers par exemple
%VOI_coord = get_subdir_regex_files(stat_dir,'VOI_cerbeVI_coord.txt');

VOI_coord_change = 'keep'; 
%VOI_coord_change = 'nearestmax' will find the nearest t max for the given contrast
%VOI_coord_change = 'graphically' will let you position the voi center on
%the spm graph. Once you are done type enter in the matlab command windows


SPHERE_spec = 5;    %sphere radius
VOI_name = 'Rectus';

PPI_contrast = [0 0 0 1 0 0 0 -1 ];
ppi_name = 'SA vs OA';

NBsession = 4;
ContrastNumSession = [39 40 41 42]; %number of Fcontrast for each session for voi adjustment


do_ppi

