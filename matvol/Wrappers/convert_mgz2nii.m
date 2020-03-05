function fo = convert_mgz2nii(fi)

if ~exist('fi')
  P = spm_select([1 Inf],'.*\.mgz','select images','',pwd);
  fi = cellstr(P);
end

fi = cellstr(char(fi));

for k=1:length(fi)
  [p f e] = fileparts(fi{k});
  
  fo{k} = fullfile(p,[f,'.nii']);
 
  if ~exist(fo{k})
%    cmd = sprintf('source freesurfer5;export LD_LIBRARY_PATH=/usr/lib64:/lib64;source /usr/cenir/bincenir/freesurfer; mri_convert %s %s',fi{k},fo{k})
    cmd = sprintf(' mri_convert %s %s',fi{k},fo{k})
  
    unix(cmd)
  end
  
end


