
result_file_name = 'roi_activation.csv';
seuil_stat = 0.01;
extent = 0 ;  %cluster size

result_file_name = fullfile(pwd,result_file_name);

%select subject
suj = get_subdir_regex('/servernas/images5/jason/GBMOV');
[pp sujname] = get_parent_path(suj);
model_name = 'model_d0_norepair'; %ou une liste  {'model_d0_norepair','model_dM_norepair'}

stat_dir = get_subdir_regex(suj,'stat',model_name)

%select roi
roi_f  = get_subdir_regex_files({'/usr/cenir/SPM/spm8/toolbox/wfu_pickatlas/MNI_atlas_templates'});

roi_f = cellstr(char(roi_f));
[pp roiname]= get_parent_path(roi_f);roiname=change_file_extension(roiname,'');

volr = spm_vol(roi_f{1});

o = maroi_image(struct('vol',volr, 'binarize',1,'func', 'img>0'));

ff = fopen(result_file_name,'a+');
fprintf(ff,'\nSujet name,%s\n',roiname{1});

nbsuj = 1;
spm_file = fullfile(stat_dir{nbsuj},'SPM.mat');
l = load(spm_file);
cwd=pwd;
for nbcon = 1:length(l.SPM.xCon)
    fprintf(ff,',V_%s,T_%s',l.SPM.xCon(nbcon).name,l.SPM.xCon(nbcon).name);
end

    
for nbsuj = 1:length(stat_dir)
    spm_file = fullfile(stat_dir{nbsuj},'SPM.mat');
    l = load(spm_file);

    fprintf(ff,'\n%s',sujname{nbsuj});
    
    for nbcon = 1:length(l.SPM.xCon)
        
        jobs{1}.stats{1}.results.spmmat = cellstr(spm_file);
        jobs{1}.stats{1}.results.conspec(1).titlestr = l.SPM.xCon(nbcon).name;
        jobs{1}.stats{1}.results.conspec(1).contrasts = nbcon;
        jobs{1}.stats{1}.results.conspec(1).threshdesc = 'none'; % FWE
        jobs{1}.stats{1}.results.conspec(1).thresh = seuil_stat ;
        jobs{1}.stats{1}.results.conspec(1).extent = 0;
        jobs{1}.stats{1}.results.print = 0;
        
        spm_jobman('run',jobs);
        
        vspm = xSPM.Vspm;
        sp=mars_space(vspm);
        rspm = maroi_pointlist(struct('mat',vspm.mat,'XYZ',xSPM.XYZ),'vox');    rspm = spm_hold(rspm,0);
        
        rspmm=maroi_matrix(rspm,sp);
        om=maroi_matrix(o,sp);
        res = rspmm & om;
        resm = maroi_matrix(res,sp);
        fprintf(ff,'%d,%f',volume(resm),mean(getdata(resm,xSPM.Vspm)) );
    end
    
end

fprintf(ff,'\n')
cd (cwd)
fclose(ff);