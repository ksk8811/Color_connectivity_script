function jobs = do_coregister(src,ref,other,logfile,jobs)

if ~exist('logfile')
logfile='';
end

%if ~isempty(logfile)
logmsg(logfile,sprintf('Coregistering "%s" onto "%s"',src,ref));
%end
if ~exist('jobs')
  nbjobs = 1;
else
  nbjobs = length(jobs) + 1;
end

jobs{nbjobs}.spatial{1}.coreg{1}.estimate.ref = cellstr(ref);
jobs{nbjobs}.spatial{1}.coreg{1}.estimate.source =cellstr(src);

if ~isempty(other)
  logmsg(logfile,sprintf('Applying coregistration to "%d" file starting with "%s"',size(other,1),other(1,:)));

  jobs{nbjobs}.spatial{1}.coreg{1}.estimate.other =cellstr(other);

end
