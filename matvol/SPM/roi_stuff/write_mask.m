function fo = write_mask(fi,label,outname,redoo)

if ~exist('redoo'), redoo=0; end


if ~iscell(fi), fi={fi};end

for k=1:length(fi)
  [p f e] = fileparts(fi{k});
  
  fo{k} = fullfile(p,[outname,'.nii']);
 
  if ~exist(fo{k}) | redoo
    exp = sprintf('i1==%d',label);

    job = job_image_calc(fi(k),fo{k},exp,0,2);
  
    fprintf('computing mask %s (for label %d)\n',fo{k},label);
    spm_jobman('run',job);  
    %spm_jobman('interactive',job);
  end
  

end


