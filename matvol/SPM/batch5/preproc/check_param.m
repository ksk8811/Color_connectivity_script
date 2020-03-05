function check_param(param_file,number_of_session,number_of_file_per_session)
%
verbose=1;
%- Parameters for preprocessing a group of subjects
%----------------------------------------------------------------------
if length(number_of_file_per_session)==1
  number_of_file_per_session = ones(1,number_of_session)*number_of_file_per_session;
end

get_user_param
root=parameters.rootdir;
param = parameters;

if (verbose), fprintf(' Working on %s.\n',root);fprintf(' Found  %d Subjects\n',length(parameters.subjects));end


for ns=1:length(parameters.subjects)
  param.funcdirs = parameters.funcdirs{ns};
  anat = spm_select('List', param.anatdir{ns}, param.anatwc);

  if (verbose), fprintf(' Working on Subject %s.\n',parameters.subjects{ns});end
  
  if size(anat,1)==1
    if (verbose), fprintf('  found 1 anat named %s.\n',anat);end    
  else
    warning('no unique anat for subject %s', parameters.subjects{ns})
  end
  clear ff
  for n=1:length(param.funcdirs)
    f = spm_select('List',param.funcdirs{n},param.funcwc);
    ff{n} = [repmat(spm_select('CPath','',param.funcdirs{n}),size(f,1),1), f];
  end


  if length(param.funcdirs)==number_of_session
    if (verbose)
    fprintf('  found %d files in %d session(s)\n',sum(cellfun('size',ff,1)),length(ff));
    end
    for n=1:length(param.funcdirs)
      if (size(ff{n},1)==number_of_file_per_session(n))
	if(verbose), fprintf('    with %d files in session %d (%s)\n',size(ff{n},1),n,param.funcdirs{n}(length(fileparts(param.funcdirs{n}))+2:end));end
      else
	warning('FOUND %d files instead of %d for session %s',size(ff{n},1),number_of_file_per_session(n),param.funcdirs{n} ) 
      end
    end
  else
    warning ('FOUND %d session instead of %d for subject %s',length(param.funcdirs),number_of_session,parameters.subjects{ns})
  end
  
  if verbose,fprintf('****************************\n');end
end


