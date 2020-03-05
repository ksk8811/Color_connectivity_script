function dti_preproc(dti_dir,sujname,par)

if ~exist('par'),  par='';end

if ~isfield(par,'do_bet'), par.do_bet=0;end
if ~isfield(par,'do_eddcor'), par.do_eddcor=0;end
if ~isfield(par,'do_fit'), par.do_fit=0;end

if ~isfield(par,'do_bedpost'), par.do_bedpost=0;end
if ~isfield(par,'bedpost_dir'), par.bedpost_dir = 'bedpostdir'; end

if ~isfield(par,'do_unwrap'), par.do_unwrap=0; end
if ~isfield(par,'correct_bvec'), par.correct_bvec=0;end

if ~isfield(par,'skip_vol'),  par.skip_vol=''; end

if ~isfield(par,'sge'),  par.sge=0; end
if ~isfield(par,'queu'),  par.queu = 'server_ondule';end
if ~isfield(par,'dirjob'),  par.dirjob = pwd ;end

if ~isfield(par,'data4D'),    par.data4D = '4D_dti';  end
if ~isfield(par,'dti_mask'),    par.dti_mask = 'nodif_brain_mask.nii.gz';  end
if ~isfield(par,'bvals')    par.bvals = 'bvals';  end
if ~isfield(par,'bvecs')    par.bvecs = 'bvecs';  end


  type='fsl_preproc';
  
  p.verbose=0;
  ff = get_subdir_regex_files(par.dirjob,type,p);
  if isempty(ff)
    numjob=1;
  else
    numjob=size(ff{1},1)+1;
  end
  
  jname = fullfile(par.dirjob,sprintf('%s_job_%.3d',type,numjob) ); 
  jname_err = [jname '_err.log'];
  jname_log = [jname '_log.log'];
    
  fj = fopen(jname,'w+');

  fprintf(fj,'#$ -S /bin/bash \n source /usr/cenir/bincenir/fsl_path2; \n  ');
%  [datapath invol ext] = fileparts(param.invol);
%  invol = [invol ext];
  fprintf(fj,'cd %s\n',dti_dir);
     
if ~par.sge
  cwd = pwd;
  cd(dti_dir)
end


%running fsl dti preprocessing
if par.do_bet
  cmd =sprintf(' bet2 %s nodif_brain -m -n -f 0.1',par.data4D);
  
  fprintf(fj,cmd);fprintf(fj,'\n');
  if ~par.sge
    unix(cmd)
  end

end

if par.do_eddcor
  
  cmd =sprintf('eddy_correct %s %s_eddycor 0',par.data4D,par.data4D);

  fprintf(fj,cmd);fprintf(fj,'\n');
  if ~par.sge
    %    if ~exist(par.data4D), error('can not do eddycor because NO FILE %s\n',par.data4D);end    
    unix(cmd)
  end

  par.data4D = [par.data4D '_eddycor'];

end

if par.do_unwrap

  unwarp_outvol = [par.data4D '_unwarp'];
  
  cmd = sprintf('/usr/cenir/bincenir/epidewarp.rrr.fsl --mag %s --dph %s --epi %s.nii.gz --tediff %f --esp %f --unwarpdir %s --vsm voxel_shift_map --epidw %s \n',par.inmag,par.inphase,par.data4D,par.tediff,par.esp,par.unwarpdir,unwarp_outvol);
  
  

    fprintf(fj,cmd);fprintf(fj,'\n');
  if ~par.sge
    %    if ~exist(par.data4D), error('can not do unwarp because NO FILE %s\n',par.data4D);end    
    fprintf(cmd)
    unix(cmd)
  end

  par.data4D = [par.data4D '_unwarp'];

end

if par.correct_bvec
  
  %ecc_f = get_subdir_regex_files(dti_dir,'ecclog$',1);

  bvecss = fullfile(dti_dir,par.bvecs);

  if exist([par.bvecs '_old']), error('bvec_old exist');  end
  
  cmd = ['rotate_bvecs *.ecclog ' bvecss];


  fprintf(fj,cmd);fprintf(fj,'\n');
  if ~par.sge
    fprintf('runing %s\n',cmd)
    unix(cmd)
  end

end

if par.do_fit
  cmd = ['dtifit -k ' par.data4D ' -o ' ,sujname, ' -m nodif_brain_mask -r bvecs -b bvals'];


  fprintf(fj,cmd);fprintf(fj,'\n');
  if ~par.sge
    fprintf('runing %s\n',cmd)
    %    if ~exist(par.data4D), error('can not do dti fit because NO FILE %s\n',par.data4D);end    
    unix(cmd)
  end

end



if par.do_bedpost

  mkdir (fullfile(dti_dir,par.bedpost_dir));
    
%  if ~strcmp(par.data_to_fit(1),'/');
%    par.data_to_fit = fullfile(dti_dir,[par.data_to_fit '.nii.gz']);
%  end
%  if ~strcmp(par.dti_mask(1),'/');
%    par.dti_mask = fullfile(dti_dir,par.dti_mask);
%  end
%  if ~strcmp(par.bvals(1),'/');
%    par.bvals = fullfile(dti_dir,par.bvals);
%  end
%  if ~strcmp(par.bvecs(1),'/');
%    par.bvecs = fullfile(dti_dir,par.bvecs);
%  end
  
    
  cmd = sprintf('ln -s %s %s',par.data4D,fullfile(dti_dir,par.bedpost_dir,'data.nii.gz'));
  unix(cmd);
  cmd = sprintf('ln -s %s %s',par.dti_mask,fullfile(dti_dir,par.bedpost_dir,'nodif_brain_mask.nii.gz'));
  unix(cmd);
  cmd = sprintf('ln -s %s %s',par.bvals,fullfile(dti_dir,par.bedpost_dir,'bvals'));
  unix(cmd);
  cmd = sprintf('ln -s %s %s',par.bvecs,fullfile(dti_dir,par.bedpost_dir,'bvecs'));
  unix(cmd);
        
  cmd = sprintf('bedpostx %s -q %s',par.bedpost_dir,par.queu);
    
  fprintf(fj,cmd);fprintf(fj,'\n');
  if ~par.sge
    fprintf('runing %s\n',cmd)
    unix(cmd)
  end


  
end

fclose(fj);

if par.sge
  fprintf('writing job %s\n',jname);

  qsubname = fullfile(par.dirjob,'do_qsub.sh');

  if ~exist(qsubname)
    fqsub = fopen(qsubname,'w+');
    fprintf(fqsub,'source /usr/cenir/sge/default/common/settings.sh \n');

  else
    fqsub = fopen(qsubname,'a+');
  end

  fprintf(fqsub,'qsub -q %s -o %s -e %s %s\n',par.queu,jname_log,jname_err,jname);

  fclose(fqsub);

  unix(['chmod +x  ' qsubname]);

else
  cd(cwd)
end

