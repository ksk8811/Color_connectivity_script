function jobs = job_new_segment(ff,params,jobs)
%do_new_segment(ff,params,jobs)
%INPUT
%  ff a list of cell containing images to be smooth
% params.newseg.outputGM = struct('native',[1 0],'warped',[0 0]);
% params.newseg.outputWM = struct('native',[1 0],'warped',[0 0]);
% params.newseg.outputCSF = struct('native',[1 0],'warped',[0 0]);
% for those 3 : 
%           if native(1) -> write native space. if  native(2)  dartelimport. 
%           If warped(1) -> unmodulated. If warped(2) -> modulated
% params.doit if define (whatever the value), it will run the job
% params.display if define (whatever the value), it will display the job
%  jobs structure (optional) to add this job at the end
%
%OUTPUT
%  jobs structure

if ~exist('params')
  params='';
end


if ~isfield(params,'logfile'),params.logfile='';end;

if ~exist('jobs')
  jobs = cell(0);
end

nbjobs = length(jobs) + 1;

msg = sprintf('Runing new spm8 segment on %d files ("%s"...) ',sum(cellfun('size',ff,1)),ff{1}(1,:));

logmsg(params.logfile,msg);


jobs(nbjobs) = job_new_segment_orig;


jobs{nbjobs}.spm.tools.preproc8.channel.vols = cellstr(strvcat(ff));


if isfield(params,'newseg')
  if isfield(params.newseg,'outputGM')
    if isfield(params.newseg.outputGM,'native')
      jobs{nbjobs}.spm.tools.preproc8.tissue(1).native =  params.newseg.outputGM.native;
    end
    if isfield(params.newseg.outputGM,'warped')
      jobs{nbjobs}.spm.tools.preproc8.tissue(1).warped =  params.newseg.outputGM.warped;
    end
  end

  if isfield(params.newseg,'outputWM')
    if isfield(params.newseg.outputWM,'native')
      jobs{nbjobs}.spm.tools.preproc8.tissue(2).native =  params.newseg.outputWM.native;
    end
    if isfield(params.newseg.outputWM,'warped')
      jobs{nbjobs}.spm.tools.preproc8.tissue(2).warped =  params.newseg.outputWM.warped;
    end
  end

  if isfield(params.newseg,'outputCSF')
    if isfield(params.newseg.outputCSF,'native')
      jobs{nbjobs}.spm.tools.preproc8.tissue(3).native =  params.newseg.outputCSF.native;
    end
    if isfield(params.newseg.outputCSF,'warped')
      jobs{nbjobs}.spm.tools.preproc8.tissue(3).warped =  params.newseg.outputCSF.warped;
    end
  end

end


if isfield(params,'display')
  spm_jobman('interactive',{jobs});
  spm('show');
end

if isfield(params,'doit')
  spm_jobman('run',jobs);
end

