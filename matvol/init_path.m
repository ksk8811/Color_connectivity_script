function init_path

%make it short : include all subdir

dir_prog = [ fileparts(mfilename('fullpath')) filesep];
path(path,genpath(dir_prog));


%for user protocol definition
Pbatch = fullfile(getenv('HOME'),'batch5');
if ~exist(Pbatch)
  mkdir(Pbatch)
end
Pbatch = fullfile(Pbatch,'proto_def');
if ~exist(Pbatch)
  mkdir(Pbatch)
  if exist('/usr/local/src/matvol/SPM/batch5/proto_def_nomore/Template_param.m')
  	copyfile('/usr/local/src/matvol/SPM/batch5/proto_def_nomore/Template_param.m',Pbatch)
  end

end
path(path,Pbatch)


