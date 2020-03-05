function fo = combine_mask(fi,expression,redoo,outname)

if ~exist('fi')
  rrr = spm_select([1 Inf],'image','Select roi image ','',pwd);
  fi = cellstr(rrr);
end

if ~exist('expression')
  aa=inputdlg('enter expression to combine roi','merce',1,{'&'});
  expression = aa{1};
end

if ~exist('redoo'), redoo=0; end

exxp='';

switch expression
  case '&'
    exp_name = '_et_';
    expp = '.*';
  case '|'
    exp_name = '_ou_';
    expp = '+';
  case '|~'
    exp_name = '_NOT_';
    expp = '&';
    exxp = '~';
  otherwise
    exp_name = '_';
end

icalc = '(i1>0)';

[p1 oname e] = fileparts(fi{1});


for k=2:length(fi)
  icalc =sprintf('%s %s %s(i%d>0) ',icalc,expp,exxp,k);
  [p f e] = fileparts(fi{k});
  oname =sprintf('%s%s%s',oname,exp_name,f) ;
end

if exist('outname')
  oname = fullfile(p1,outname);
else
  oname = fullfile(p1,[oname,'.nii']);
end

 
if ~exist(oname) | redoo
  
  fprintf('wrinting  images %s \n',oname)
  job = job_image_calc(fi,oname,icalc,0,2);
  %spm_jobman('interactive',job);
  spm_jobman('run',job);  

end
  
fo = oname;



