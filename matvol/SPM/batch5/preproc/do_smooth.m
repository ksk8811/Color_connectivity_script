function jobs = do_smooth(ff,params,jobs)
%jobs = do_smooth(ff,params,jobs) 
%INPUT
%  ff a list of cell containing images to be smooth
%  params.smoothing = 8 (for a 8*8*8 mm smoothing kernel)
%  params.doit if field doit is defined, it will run it
%  params.display if field display is defined, it will display it
%  jobs structure (optional) to add the smooth job in
%OUTPUT
%  jobs structure or sff (the in file ff with the prefix 's') if doit field is defined

if ~exist('jobs')
  jobs='';
end
if ~exist('params'), params='';end
if ~isfield(params,'logfile'),params.logfile='';end;

nbjobs = length(jobs) + 1;


logmsg(params.logfile,sprintf('Smoothing %d files ("%s"...) with fwhm = %d mm',sum(cellfun('size',ff,1)),ff{1}(1,:),params.smoothing));


jobs{nbjobs}.spatial{1}.smooth.data = cellstr(strvcat(ff));
jobs{nbjobs}.spatial{1}.smooth.fwhm = params.smoothing;

    
if isfield(params,'doit')
  spm_jobman('run',jobs);
end

if isfield(params,'display')
  spm_jobman('interactive',jobs);
  spm('show');

end
