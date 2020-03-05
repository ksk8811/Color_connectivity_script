function jobs = do_coregister_and_reslice(src,ref,other,logfile,jobs)

if ischar(ref)
  ref = cellstr(ref)
end
if ischar(src)
  src = cellstr(src)
end


if ~exist('logfile')
logfile='';
end

if ~exist('jobs')
  nbjobs = 1;
else
  nbjobs = length(jobs) + 1;
end

logmsg(logfile,sprintf('Coregistering "%s" onto "%s"',src{1},ref{1}));


jobs{nbjobs}.spatial{1}.coreg{1}.estwrite.ref = ref;
jobs{nbjobs}.spatial{1}.coreg{1}.estwrite.source = src;

if ~isempty(other)
  
  if ischar(other)
    other = cellstr(other)
  end

  
  logmsg(logfile,sprintf('Applying coregistration to "%d" file starting with "%s"',length(other),other{1}));

  jobs{nbjobs}.spatial{1}.coreg{1}.estwrite.other = other;

end
