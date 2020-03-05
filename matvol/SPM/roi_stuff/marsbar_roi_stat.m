% Start marsbar to make sure spm_get works
marsbar('on')
% Set up the SPM defaults, just in case
spm('defaults', 'fmri');

stat_dirs = spm_select([1 Inf],'dir','Select subject stat model directories ','',pwd);

Proi = spm_select([1 Inf],'mat','Select Rois to analyze ','',pwd);

ff = fopen(fullfile(pwd,'All_result.csv'),'w+');

%load the roi

for nr=1:size(Proi,1)
  roi_array{nr} = maroi(deblank(Proi(nr,:)));
end

for ns =1:size(stat_dirs,1)
  
  statdir = deblank(stat_dirs(ns,:));
  spm_f = fullfile(statdir,'SPM.mat');
  
  [p f ] = fileparts(statdir);[p statdir] = fileparts(p);[p f] = fileparts(p);[p suj] = fileparts(p);
  
  for roi_no = 1:length(roi_array)
    
    roi = roi_array{roi_no};
    
    fprintf(ff,'\n%s,%s,%s\n',suj,statdir,label(roi))
    fprintf(ff,'contrast,con_val,stat,P,Pc\n');
    D = mardo(spm_f);

    % Extract data
    Y = get_marsy(roi, D, 'mean');
    
    % MarsBaR estimation
    E = estimate(D, Y);

    %get_contrast from design
    cc=get_contrasts(D);

    % Add contrast, return model, and contrast index
    [E IC] = add_contrasts(E,cc)
    %    [E Ic] = add_contrasts(E, 'stim_hrf', 'T', [1 0 0]);
    
    for kk=1:length(IC)
      % Get, store statistics
      ss = compute_contrasts(E, IC(kk));
      fprintf(ff,'%s,%.3f,%.3f,%.3f,%.3f\n',ss.rows{1}.name,ss.con,ss.stat,ss.P,ss.Pc);
    end
    

  end
  
  
end
