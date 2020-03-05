%this script doe the time course extraction in a sphere

spm('defaults','FMRI')

%s_dir = get_subdir_regex('E:\ANGER_SA_2008\IRM data nov 2008\Raw data',{'S10'})
%'S' est l'expression reguliere sur les dir des sujets

%stat_dir = get_subdir_regex(s_dir,'stats');
%stat_dir = get_subdir_regex(stat_dir,'17cond');

dir_sel = spm_select(inf,'dir','select a dirs where to find SPM.mat','',pwd)
dir_sel=cellstr(dir_sel);


NBsession = 4;
FcontrastSession = [47 48 49 50]; %number of Fcontrast for each session

hReg=0;%spm_figure;

for nbsuj = 1:length(stat_dir)
    

    results.swd = stat_dir{nbsuj};
    results.title = 'toto';
    results.Ic = 1;
    results.Im = '';
    results.u = 1;
    results.k = 0;
    results.thresDesc = 'none';
    

    [SPM,xSPM] = spm_getSPM(results);

    xY.xyz  = [10 10  10]  % coordonee en mm du centre de la sphere
    xY.name = 'SPC';
    xY.Sess = 1;           %
    xY.def  = 'sphere';    %
    xY.spec = 5;           % rayon de la sphere

    for k = 1:NBsession
      xY.Sess = k;  
      xY.Ic   = FcontrastSession(k);
    
      [Y,xY,voiname]  = rrr_spm_regions(xSPM,SPM,0,xY);
      
      %cc = [1 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
      %ppiname = ['cond1-3','_Sess',num2str(k)];
      
      %rrr_spm_peb_ppi(SPM,voiname,cc,ppiname)

      cc = [1 0 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0];
      ppiname = ['cond1-4','_Sess',num2str(k)];
      
      rrr_spm_peb_ppi(SPM,voiname,cc,ppiname)
    end
end

%ajoute le model - tout - ou tout sauf le contrast -
%a chaque session ajoute la voi de la session correspond
