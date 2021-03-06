if ~exist('parameters')
  if ~exist('param_file');param_file='';end
  if exist(param_file)
    eval(param_file);
    ss=sprintf('clear %s',param_file);
    eval(ss)
  else
    
    fprintf('Can not find the file << %s >> in the path\n' ,param_file);
    param_file =  spm_select([1],'m','Select a user param file','',fullfile(getenv('HOME'),'batch5/proto_def'));
    [p f]=fileparts(param_file);
    ss=sprintf('clear %s',f);
    eval(ss)
    
    cwd = pwd; cd(p); eval(f); cd(cwd);
  end
end

  
  if isfield(parameters,'spm_path')
    startup(parameters.spm_path)
  end

  if ~isfield(parameters,'subjects')
    parameters.subjects = get_subdir_regex(parameters.rootdir, parameters.sujet_dir_wc);
  end


  if isfield(parameters,'anat_dir_wc')
    for n=1:length(parameters.subjects)
      aa = get_subdir_regex(parameters.subjects{n},parameters.anat_dir_wc);
      if length(aa)~=1
	error('can not find anat dir for sujet %s',parameters.subjects{n});
      end
      parameters.anatdir(n) = aa;
    end
  end


  if isfield(parameters,'fonc_dir_wc')
    for n=1:length(parameters.subjects)
      parameters.funcdirs{n} = get_subdir_regex(parameters.subjects{n},parameters.fonc_dir_wc);
    end
  end
  if isfield(parameters,'fonc_dir_oposit_phase')
    for n=1:length(parameters.subjects)
      parameters.funcdirs_op{n} = get_subdir_regex(parameters.subjects{n},parameters.fonc_dir_oposit_phase);
    end
  end
  
  if isfield(parameters,'fonc_opposit_phase_dir_wc')
    for n=1:length(parameters.subjects)
      parameters.funcdirs_opposit_phase{n} = get_subdir_regex(parameters.subjects{n},parameters.fonc_opposit_phase_dir_wc);
    end
  end


  if isfield(parameters,'preproc_subdir')
    if isfield (parameters,'modelname')
      parameters.modelname = [parameters.modelname,'_',parameters.preproc_subdir];
    end
  end

  if isfield(parameters,'norm')
      if isfield(parameters.norm,'mask')
          parameters.norm.mask = get_subdir_regex_files(parameters.anatdir(n),parameters.norm.mask,1);
      end
  end
  
  if exist('param_for_second_level')
    %isfield(parameters,'do_secondlevel')
    
    spmfile = fullfile(parameters.subjects{1},'stats', parameters.modelname,'SPM.mat');
    if ~exist(spmfile)
        error('can not find %s',spmfile)
    end
    
    l=load(spmfile);
    
    if isstr(parameters.icon)
        
        parameters.icon = [];
        kkk=0;parameters.namecon={};
        
        for kk=1:length(l.SPM.xCon)
            if  strcmp(l.SPM.xCon(kk).STAT,'T')
                kkk=kkk+1;
                parameters.icon(kkk) = kk;
                parameters.namecon{kkk} =  l.SPM.xCon(kk).name;
            end
        end
    else
      if ~isfield(parameters,'namecon')
	for kk=1:length(parameters.icon)
	  parameters.namecon{kk} =  l.SPM.xCon(parameters.icon(kk)).name;
	end
      end
      
    end
    
  end %exist('param_for_second_level')

