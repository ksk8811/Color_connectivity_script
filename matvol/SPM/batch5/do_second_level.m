function do_second_level(param_file)
% Toplevel batch for preprocessings
%

if nargin==0
  param_file='';
end

%- Parameters for preprocessing a group of subjects
%----------------------------------------------------------------------
param_for_second_level=1;

if isstruct(param_file)
  parameters = param_file;
end

get_user_param

clear param_for_second_level

cwd = pwd;

%-Creating output directories if necessary
%----------------------------------------------------------------------
if ~strcmp(filesep,parameters.rfxfolder(1))
  rfxdir = fullfile(parameters.rootdir,parameters.rfxfolder);
else
  rfxdir = parameters.rfxfolder;
end

if ~exist(rfxdir,'dir')
  disp(sprintf('Creating new output directory for rfx analysis "%s".',rfxdir));
  mkdir(rfxdir);
end

rfxdir = fullfile(rfxdir,parameters.modelname);

if ~exist(rfxdir,'dir')
  disp(sprintf('Creating new output directory for rfx analysis "%s".',rfxdir));
  mkdir(fileparts(rfxdir),parameters.modelname);
end

if ~parameters.anova
  for i=1:length(parameters.namecon)
    if ~exist(fullfile(rfxdir,parameters.namecon{i}),'dir')
      logmsg(parameters.logfile,sprintf('Creating new output directory for RFX stat model "%s".',parameters.namecon{i}));
      mkdir(rfxdir,parameters.namecon{i});
    end
  end
end

%-Get contrasts files
%----------------------------------------------------------------------

ff = get_images_files(parameters,'contrast_file');
if (parameters.smooth_con > 0)
 sff = addprefixtofilenames(ff,'s');
else
    sff=ff;
end

if parameters.anova==-1
    for i=1:length(parameters.icon)
        sff1{i} = []; sff2{i} = [];
        for j=1:length(parameters.subjects)
            if ~isempty(regexp(parameters.subjects{j},parameters.sujet_group1_dir_wc))
                con1file = fullfile(parameters.subjects{j},'stats',parameters.modelname,sprintf('con_%04d.img',parameters.icon(i)));
                if ~exist(con1file), error('File %s does not exist',con1file); end
                sff1{i} = strvcat(sff1{i}, con1file);
            elseif ~isempty(regexp(parameters.subjects{j},parameters.sujet_group2_dir_wc))
                con2file = fullfile(parameters.subjects{j},'stats',parameters.modelname,sprintf('con_%04d.img',parameters.icon(i)));
                if ~exist(con2file), error('File %s does not exist',con2file); end
                sff2{i} = strvcat(sff2{i}, con2file);
            end
        end
    end
end

%- Jobs definition
%----------------------------------------------------------------------
params = parameters;

jobs = {};
nbjobs = 0;

for k=1:length(params.do_secondlevel)
  action = params.do_secondlevel{k};
  do_single_second_level;

end

