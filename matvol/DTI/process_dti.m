function process_dti(dti_files,bval_f,bvec_f,dti_dir,sujname,par)

if ~exist('par')
  par=''
end

if ~isfield(par,'do_merge'), par.do_merge=0;end
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

%for bedpost
if ~isfield(par,'dti_mask'),    par.dti_mask = 'nodif_brain_mask.nii.gz';  end
if ~isfield(par,'bvals')    par.bvals = 'bvals';  end
if ~isfield(par,'bvecs')    par.bvecs = 'bvecs';  end

if ~isfield(par,'bet_frac')    par.bet_frac = 0.1;  end
%fractional intensity threshold (0->1); default=0.5; smaller values give larger brain outline estimates

if nargin==0
  fprintf('select DTI files (imgs only) \n');
  dti_files=get_subdir_regex_files();
  bval_f=get_subdir_regex_files();
  bvec_f=get_subdir_regex_files();
  par.do_merge=1;
  dti_dir = input('new dti dir name : ','s');
  sujname = input('suj root name : ','s');
end


bval_f=cellstr(char(bval_f));
bvec_f=cellstr(char(bvec_f));

if iscell(dti_files)
  dti_files = char(dti_files);
end
%remove skiping volume
if ~isempty(par.skip_vol)
  dti_files(par.skip_vol,:)='';
end

if ~exist(dti_dir)
  mkdir(dti_dir)
end

if par.sge
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
  fprintf(fj,'echo working on $HOSTNAME \n',dti_dir);
     
else
  cwd = pwd;
  cd(dti_dir)
  %for relative path make it absolute
  if ~exist(dti_dir),    dti_dir=pwd;  end
end

  
if par.do_merge
  cmd =' fslmerge  -t 4D_dti ';
  
  for k=1:size(dti_files,1)
    cmd = [cmd ' ' dti_files(k,:) ];
  end
  
  if par.sge
    fprintf(fj,cmd);fprintf(fj,'\n');
  else
    unix(cmd)
  end
  

  bval=[];bvec=[];
  for k=1:length(bval_f)
    aa = load(deblank(bval_f{k}));
    bb = load(deblank(bvec_f{k}));
    bval = [bval aa];
    bvec = [bvec,bb];
  end
  
  %remove skiping volume
  if ~isempty(par.skip_vol)
    bval(:,par.skip_vol)=[];
    bvec(:,par.skip_vol)=[];
  end
  
  %Writing bvals and bvec

  fid = fopen(fullfile(dti_dir,'bvals'),'w');
  fprintf(fid,'%d ',bval);  fprintf(fid,'\n');  fclose(fid);
  
  fid = fopen(fullfile(dti_dir,'bvecs'),'w');
  for kk=1:3
    fprintf(fid,'%f ',bvec(kk,:));  
    fprintf(fid,'\n');  
  end
  
  fclose(fid);
end


%running fsl dti preprocessing
if par.do_bet
  cmd =sprintf(' bet2 4D_dti nodif_brain -m -n -f %f',par.bet_frac);
  
  if par.sge
    fprintf(fj,cmd);fprintf(fj,'\n');
  else
    unix(cmd)
  end

end

outvolname = '4D_dti';

if par.do_eddcor
  cmd ='eddy_correct  4D_dti 4D_eddycor 0';

  if par.sge
    fprintf(fj,cmd);fprintf(fj,'\n');
  else
    unix(cmd)
  end

  outvolname = '4D_eddycor';

end

if par.do_unwrap
  mag = par.inmag;
  phase = par.inphase;
    
  if isfield(par,'data_to_unwarp')
    outvolname = par.data_to_unwarp;
  end
  

  if ~isfield(par,'unwarp_outvol')
    par.unwarp_outvol = [outvolname '_unwarp'];
  end
  
  cmd = sprintf('/usr/cenir/bincenir/epidewarp.rrr.fsl --mag %s --dph %s --epi %s.nii.gz --tediff %f --esp %f --unwarpdir %s --vsm voxel_shift_map --epidw %s \n',mag,phase,outvolname,par.tediff,par.esp,par.unwarpdir,par.unwarp_outvol);
  
  
  if par.sge
    fprintf(fj,cmd);fprintf(fj,'\n');
  else
    fprintf(cmd)
    unix(cmd)
  end

  outvolname = '4D_eddycor_unwrap';
end
  
if ~isfield(par,'data_to_fit')
  par.data_to_fit = outvolname;
end

if par.correct_bvec
  
  dataa_to_fit = fullfile(dti_dir,[par.data_to_fit ]);

  bvecss = fullfile(dti_dir,par.bvecs);


  if exist(fullfile(dti_dir,[par.bvecs '_old']))
    error('bvec_old exist')
  end
  
  %  cmd = ['rotate_bvecs ' dataa_to_fit '.ecclog ' bvecss];
  cmd = ['rotate_bvecs *.ecclog ' bvecss];

  if par.sge
    fprintf(fj,cmd);fprintf(fj,'\n');
  else
    fprintf('runing %s\n',cmd)
    unix(cmd)
  end

end

if par.do_fit
  cmd = ['dtifit -k ' par.data_to_fit ' -o ' ,sujname, ' -m nodif_brain_mask -r bvecs -b bvals'];

  if par.sge
    fprintf(fj,cmd);fprintf(fj,'\n');
  else
    fprintf('runing %s\n',cmd)
    unix(cmd)
  end

end



if par.do_bedpost

  mkdir (fullfile(dti_dir,par.bedpost_dir));
    
  if ~strcmp(par.data_to_fit(1),'/');
    par.data_to_fit = fullfile(dti_dir,[par.data_to_fit '.nii.gz']);
  end
  if ~strcmp(par.dti_mask(1),'/');
    par.dti_mask = fullfile(dti_dir,par.dti_mask);
  end
  if ~strcmp(par.bvals(1),'/');
    par.bvals = fullfile(dti_dir,par.bvals);
  end
  if ~strcmp(par.bvecs(1),'/');
    par.bvecs = fullfile(dti_dir,par.bvecs);
  end
  
    
  cmd = sprintf('ln -s %s %s',par.data_to_fit,fullfile(dti_dir,par.bedpost_dir,'data.nii.gz'));
  unix(cmd);
  cmd = sprintf('ln -s %s %s',par.dti_mask,fullfile(dti_dir,par.bedpost_dir,'nodif_brain_mask.nii.gz'));
  unix(cmd);
  cmd = sprintf('ln -s %s %s',par.bvals,fullfile(dti_dir,par.bedpost_dir,'bvals'));
  unix(cmd);
  cmd = sprintf('ln -s %s %s',par.bvecs,fullfile(dti_dir,par.bedpost_dir,'bvecs'));
  unix(cmd);
        
%  cmd = sprintf('bedpostx %s -q %s',par.bedpost_dir,par.queu);
  cmd = sprintf('bedpostx %s ',par.bedpost_dir);
    
  if par.sge
    error('bedpostx is already with sge ...')
    fprintf(fj,cmd);fprintf(fj,'\n');
  else
    fprintf('runing %s\n',cmd)
    unix(cmd)
  end


  
end

if par.sge

  fclose(fj);
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

