result_file_name = 'Beta_result.csv';

fprintf('select suj');
suj = get_subdir_regex();

%pour voir
char(suj)

%A modifier : remplace 'model' par le nom du dossier dans le répertoir stat
stat_dir = get_subdir_regex(suj,'stat','model_douleur_seul_8$');
char(stat_dir)


%A modifier : remplace 'model' par le chemin du répertoire des roi
fprintf('select ROI');
roi_f = get_subdir_regex_files();

roi_f = cellstr(char(roi_f));


ff = fopen(result_file_name,'a+');

fprintf(ff,'\nSujet name')

for nbsuj = 1:length(stat_dir)
    
    if nbsuj==1
        for nroi = 1:length(roi_f)
            D = mardo(fullfile(stat_dir{nbsuj},'SPM.mat'));
            R = maroi(roi_f{nroi});
            Y  = get_marsy(R, D, 'mean');
            xCon = get_contrasts(D);
            
            nn=region_name(Y); nn=nn{1};
            ind = findstr(nn,'.');  nn(ind:end)=[];
            
            
            for nbcon=1:length(xCon)
                fprintf(ff,',%s_%s',nn,xCon(nbcon).name);
            end
        end
    end
    
    [pp,sujname]=get_parent_path(stat_dir,3);
    
    fprintf(ff,'\n%s',sujname{nbsuj});
    
    for nroi = 1:length(roi_f)
        D = mardo(fullfile(stat_dir{nbsuj},'SPM.mat'));
        R = maroi(roi_f{nroi});
        
        % Fetch data into marsbar data object
        Y  = get_marsy(R, D, 'mean');
        % Get contrasts from original design
        xCon = get_contrasts(D);
        % Estimate design on ROI data
        E = estimate(D, Y);
        % Put contrasts from original design back into design object
        E = set_contrasts(E, xCon,0);
        % get design betas
        b = betas(E);
        % get stats and stuff for all contrasts into statistics structure
       
        marsS = compute_contrasts(E, 1:length(xCon));
        
        for nbcon=1:length(xCon)
            fprintf(ff,',%f',marsS.con(nbcon));
        end
    end
    
end

fprintf(ff,'\n')

fclose(ff);