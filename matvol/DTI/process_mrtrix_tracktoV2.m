function process_mrtrix_trackto(sdata,seed,par)

if ~exist('par')
    par='';
end
defpar.mask='mask.nii';
defpar.grad_file = 'grad.b';

defpar.type='SD_PROB';  % DT_STREAM SD_STREAM  SD_PROB.
defpar.track_num = 1000;
defpar.track_maxnum = '';

defpar.target='';
defpar.track_name='';
defpar.curvature=1;
defpar.stop = 0;
defpar.onedirection = 0;
defpar.exclude = '';
defpar.target_type = 'all'; %or 'single'
defpar.sge = 1;
defpar.jobname = 'mrtrix_trackto';

par = complet_struct(par,defpar);

if ischar(par.mask)
    par.mask  = get_file_from_same_dir(sdata,par.mask);
end

cwd=pwd;
job={};

for nbsuj = 1:length(sdata)
    
    [dir_mrtrix ff ] = fileparts(sdata{nbsuj});
    
    [pp seed_name ex] = fileparts(seed{nbsuj});
    
    seed_file = char(seed{nbsuj});
    
    mask_filename = par.mask{nbsuj};
    
    cmd = sprintf('cd %s; streamtrack %s %s -seed %s -mask %s -grad %s -num %d -curvature %d',...
        dir_mrtrix,par.type,sdata{nbsuj},seed_file,mask_filename,par.grad_file,par.track_num,par.curvature);
    
    if ~isempty(par.track_maxnum)
        cmd = sprintf('%s -maxnum %d',cmd,par.track_maxnum);
    end
    
    if par.stop
        cmd = sprintf('%s -stop',cmd);
    end
    
    if par.onedirection
        cmd = sprintf('%s -unidirectional',cmd);
    end
    
    if ~isempty(par.exclude)
        exclude_file = cellstr(par.exclude{nbsuj});
        for nbe = 1:length(exclude_file)
            cmd = sprintf('%s -exclude %s',cmd,exclude_file{nbe});
        end
    end
    
    if isempty(par.track_name), par.track_name=['seed' change_file_extension(seed_name,'') ]; end
    track_name = par.track_name;
    
    if ~isempty(par.target)
        target_file = cellstr(par.target{nbsuj});
	switch  par.target_type 
case 'all'
 
       for nbt=1:length(target_file)
%            [pp target_name] = fileparts(target_file{nbt});
%            target_name = change_file_extension(target_name,'');
%            trackname = [track_name '_to_' target_name];
            
            cmd = sprintf('%s -include %s  ',cmd,target_file{nbt});
            
        end
            cmdtar = sprintf('%s %s.trk ',cmd,track_name);

            job{end+1}  = cmdtar;
 
case 'single'
        for nbt=1:length(target_file)
            [pp target_name] = fileparts(target_file{nbt});
            target_name = change_file_extension(target_name,'');
            trackname = [track_name '_to_' target_name];
            
            cmdtar = sprintf('%s -include %s %s.trk ',cmd,target_file{nbt},trackname);
            
            job{end+1}  = cmdtar;
        end
end
    else
        cmd = sprintf('%s %s.trk',cmd,track_name)
        
        job{end+1} = cmd;
    end
    
end%for nbsuj = 1:length(sdata)

do_cmd_sge(job,par)
