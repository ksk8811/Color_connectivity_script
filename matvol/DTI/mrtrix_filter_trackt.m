function job=mrtrix_filter_trackt(track_in,par)

if ~exist('par')
    par='';
end

defpar.roi_include='';
defpar.roi_exclude='';
defpar.track_name='';
defpar.separate_include = 0;
defpar.jobname = 'mrtrix_filter_track';

par = complet_struct(par,defpar);


if isempty(par.roi_include) & isempty(par.roi_exclude)
    error('you must specify include or exclude roi with either par.roi_include or  par.roi_exclude')
end

job={};

for nbsuj = 1:length(track_in)
    
    [dir_mrtrix track_in_name ] = fileparts(track_in{nbsuj});
    
    if iscell(par.roi_include),    roi_include = par.roi_include{nbsuj};  else,    roi_include = par.roi_include;  end
    if iscell(par.roi_exclude),    roi_exclude = par.roi_exclude{nbsuj};  else,    roi_exclude = par.roi_exclude;  end
    
    out_name = change_file_extension(track_in_name,'');
    
    if par.separate_include
        roi_include = cellstr(roi_include);
        for ki = 1:length(roi_include)
            [dddd include_name ] = fileparts(roi_include{ki});
            include_name = change_file_extension(include_name,'');
            
            str_include{ki} = sprintf(' -include %s ',roi_include{ki});
            
            out_names{ki} = [out_name '_to_' include_name];
        end
        
    else
        
        str_include = '';
        if ~isempty(roi_include)
            roi_include = cellstr(roi_include);
            for ki = 1:length(roi_include)
                [dddd include_name ] = fileparts(roi_include{ki});
                include_name = change_file_extension(include_name,'');
                str_include = sprintf('%s -include %s ',str_include,roi_include{ki});
                out_name = [out_name '_Inc_' include_name];
            end
        end
    end
    
    str_exclude = '';
    if ~isempty(roi_exclude)
        roi_exclude = cellstr(roi_exclude);
        for ke = 1:length(roi_exclude)
            [dddd exclude_name ee] = fileparts(roi_exclude{ke});
            str_exclude = sprintf('%s -exclude %s ',str_exclude,roi_exclude{ke});
            %out_name = [out_name '_Exc_' exclude_name];
        end
    end
    if ~isempty(par.track_name), out_names = par.track_name; end
    
    if par.separate_include
        for ki = 1:length(roi_include)
            cmd = sprintf('cd %s;filter_tracks %s %s.trk %s %s',...
                dir_mrtrix,track_in{nbsuj},out_names{ki},str_include{ki},str_exclude);
            job{end+1} = cmd;
                        
        end
        
    else
        if ~isempty(par.track_name),            out_name = par.track_name;        end
        
        cmd = sprintf('cd %s;filter_tracks %s %s.trk %s %s',...
            dir_mrtrix,track_in{nbsuj},out_name,str_include,str_exclude);
        job{end+1} = cmd;
        
    end
    
end%for nbsuj = 1:length(track_in)

do_cmd_sge(job,par);

