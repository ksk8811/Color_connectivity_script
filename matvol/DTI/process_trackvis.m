function process_trackvis(fi,par)

if ~exist('par')
  par='';
end
if ~exist('fi'), fi='';end

if ~isfield(par,'bval'),  par.bval = 'bvals_trackvis'; end
if ~isfield(par,'bvec'),  par.bvec = 'bvecs_trackvis'; end
if ~isfield(par,'angle_thr'), par.angle_thr = 30; end
if ~isfield(par,'trackvisRootdir') , par.trackvisRootdir = '/usr/cenir/src/track_vis/';end
if ~isfield(par,'test'), par.test = 0; end
if ~isfield(par,'rootname'), par.rootname = 'dti'; end

if isempty(fi)
  fi = spm_select(inf,'.*','select 4D data','',pwd);fi= cellstr(fi);
end


for k=1:length(fi)
  
  [cur_dir f] = fileparts(fi{k});
  
  bvec = get_subdir_regex_files(cur_dir,par.bvec,1);
  bval = get_subdir_regex_files(cur_dir,par.bval,1);
  bvals = load(bval{1});
  ind_B0 = find(bvals<50);
  
  bval_max = max(bvals);
  
  cmd = sprintf('%s/dti_recon "%s" "%s/%s" -gm "%s" -b %d -b0 %d -p 3 -sn 1 -ot nii -b0_th 50 ',par.trackvisRootdir,fi{k},cur_dir,par.rootname,bvec{1},bval_max,length(ind_B0));
  
    fprintf('Running\n%s\n',cmd)
  if par.test
    fprintf('Running\n%s\n',cmd)
  else
    unix(cmd)
  end
  
  
  mask_name = sprintf('%s_b0.nii',par.rootname');
  
  cmd = sprintf('%s/dti_tracker "%s/%s" "%s/track_tmp.trk" -at %d -iz -m  "%s" -l 0.01  ',par.trackvisRootdir,cur_dir,par.rootname,cur_dir,par.angle_thr,fullfile(cur_dir,mask_name));

    fprintf('Running\n%s\n',cmd)
  if par.test
    fprintf('Running\n%s\n',cmd)
  else
    unix(cmd)
  end
    
  cmd = sprintf('%s/spline_filter "%s/track_tmp.trk" 1 "%s/%s.trk"  ',par.trackvisRootdir,cur_dir,cur_dir,par.rootname);

  fprintf('Running\n%s\n',cmd)

  if par.test
    fprintf('Running\n%s\n',cmd)
  else
    unix(cmd)
  end
  
  
end
