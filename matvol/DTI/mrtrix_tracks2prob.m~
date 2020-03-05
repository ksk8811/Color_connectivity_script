function [job fout] = mrtrix_tracks2prob(intrk,ref,par,jobappend)
%input trk output volume ref volume or ref voxel size

if ~exist('par','var'), par='';end
if ~exist('jobappend','var'), jobappend ='';end

defpar.volout = {}; 
defpar.jobname = 'mrtrix_track2prob';

par = complet_struct(par,defpar);

if isstr(intrk),    intrk=cellstr(intrk);end

volout = par.volout;
if isstr(volout),    volout = repmat({volout},size(intrk));end

do_voxsize=0;
if any(size(intrk)-size(ref))
    if isnumeric(ref)
        ref={ref}; ref = repmat(ref,size(intrk));
        do_voxsize=1;
    else
        error('rrr \n the 2 input must have the same size\n')
    end
    
else
    if isnumeric(ref)
        ref={ref}; ref = repmat(ref,size(intrk));
        do_voxsize=1;
    end
end

job={};

for k=1:length(intrk)    
    alltrk = cellstr(intrk{k});  
    
    for kv=1:length(alltrk)      
        [dir_mrtrix ff ] = fileparts(alltrk{kv});
        
        if ~isempty(volout)
            out = volout{k}(kv,:);
        else
            out = fullfile(dir_mrtrix,[ff '_prob.nii']);
        end
        
        %cd(dir_mrtrix)
        if exist(out),            delete(out);        end
        
        if do_voxsize
            cmd = sprintf('tracks2prob -vox %d %s - |mrconvert - %s -datatype Int32',...
                ref{k},alltrk{kv},out);
        else
            cmd = sprintf('tracks2prob -template %s %s - |mrconvert - %s -datatype Int32',...
                ref{k},alltrk{kv},out);
        end
        
        job{end+1} = cmd;
        ffout{kv} = out;
    end
    fout{k} = char(ffout);
end

do_cmd_sge(job,par,jobappend)
