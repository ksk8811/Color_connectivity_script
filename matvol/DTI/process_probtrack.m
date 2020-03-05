function process_probtrack(seed_in,outdir_in,trackdir_in,par)
%function process_probtrack(seed,target,outdir,bedpostdir,par)


if ~exist('par'),  par='';end
%optional input parameters should be a cell of the same length than other input parameters
default_par.target = '';
default_par.waypoint = '';
default_par.xfm = '';
default_par.termination = '';
default_par.exclusion = '';
%defaults parameter
default_par.type='classification'; % 'waypoint' | 'multiplemask' | 'seed'
default_par.modeuler=0;
default_par.mask_filename='nodif_brain_mask';   % a mettre dans  le trackdir
default_par.nb_tirage = 5000;
default_par.steplength = 0.5;
default_par.probtrackx2 = 0;
default_par.onewaycondition = 0; %for probtrackx2
default_par.length= 0; % otherwise do the length correction : option  --pd in probtrackx
default_par.meshspace = '';
default_par.seedref = '';


default_par.delete_if_exist = 0;

default_par.software = 'fsl'; %to set the path
default_par.software_version = 5; % 4 or 5 : fsl version
default_par.jobname = 'probtrack';
%see also default params from do_cmd_sge

par = complet_struct(par,default_par);

jobs = {};

for nbsuj = 1:length(seed_in)
    
    seed = seed_in{nbsuj};
    
    trackdir = trackdir_in{nbsuj};
    outdir = outdir_in{nbsuj};
    
    if isfield(par,'length')
        if par.length
            outdir = [outdir '_LENGTH'];
        end
    end
    
    yesdoit=1;
    if ~exist(outdir)
        mkdir(outdir);
    else
        if length(dir(outdir))>2 % not an empty dir
            if (par.delete_if_exist)
                rmdir(outdir,'s')
                mkdir(outdir)
            else
                fprintf('skiping because %s exist \n',outdir)
                yesdoit=0;
            end
        end
    end
    
    if yesdoit
        
        if ~isempty(par.target)
            target_file = fullfile(outdir,'targets.txt');
            make_file_list(par.target{nbsuj},target_file)
        end
        
        if ~isempty(par.waypoint)
            waypoint_file = fullfile(outdir,'waypoint.txt');
            make_file_list(par.waypoint{nbsuj},waypoint_file);
        else
            waypoint_file = target_file;
        end
                
        if ~isempty(par.termination)
            stop_file= fullfile(outdir,'stop.txt');
            make_file_list(par.termination{nbsuj},stop_file)
            
        end
        
        if ~isempty(par.exclusion)
            avoid_file= fullfile(outdir,'avoid.txt');
            make_file_list(par.exclusion{nbsuj},avoid_file)
       
        end

        
        if par.probtrackx2
            cmd = sprintf('probtrackx2  ');
        else
            cmd = sprintf('probtrackx --mode=seedmask ');
        end
        
        if par.modeuler
            cmd = sprintf('%s --modeuler',cmd) ;
        end
        
        cmd = sprintf('%s -l -c 0.2 -S 2000 --steplength=%f -P %d --forcedir --opd    \\\\\n',cmd,par.steplength,par.nb_tirage) ;
        cmd = sprintf('%s -s %s    \\\\\n -m %s   \\\\\n',cmd,fullfile(trackdir,'merged'),fullfile(trackdir,par.mask_filename)) ;
        cmd = sprintf('%s --dir=%s    \\\\\n',cmd, outdir);
        
        switch par.type
            case 'seed'
                cmd = sprintf('%s -x %s    \\\\\n',cmd,seed);
                
            case 'classification'
                cmd = sprintf('%s -x %s  \\\\\n',cmd,seed);
                cmd = sprintf('%s --targetmasks=%s --os2t     \\\\\n',cmd,target_file);
                
            case 'waypoint'
                cmd = sprintf('%s -x %s \\\\\n',cmd,seed);
                cmd = sprintf('%s --waypoints=%s     \\\\\n',cmd,waypoint_file);
                
            case 'waypoint+classification'
                cmd = sprintf('%s -x %s \\\\\n',cmd,seed);
                cmd = sprintf('%s --targetmasks=%s --os2t     \\\\\n',cmd,target_file);
                cmd = sprintf('%s --waypoints=%s     \\\\\n',cmd,waypoint_file);
                
            case 'multiplemask'
                cmd = sprintf('%s --network %s     \\\\\n',cmd);
                cmd = sprintf('%s -x %s ',cmd,target_file);
                
        end
        
        
        %--modeuler
        
        if ~isempty(par.xfm)
            cmd =  sprintf('%s --xfm=%s     \\\\\n',cmd,par.xfm{nbsuj});
        end
        
        if ~isempty(par.termination)
            cmd =  sprintf('%s --stop=%s     \\\\\n',cmd,stop_file);
        end
        
        if ~isempty(par.exclusion)
            cmd =  sprintf('%s --avoid=%s     \\\\\n',cmd,avoid_file);
        end
        
        if par.length
            cmd =  sprintf('%s --pd ',cmd);
        end
        
        if par.onewaycondition
            %if tracking from surface % pour matrice de connection
            %save_paths
            if ~isempty(par.meshspace)
                cmd = sprintf('%s  --onewayonly --forcefirststep',cmd);
            else
                cmd = sprintf('%s --onewaycondition',cmd);
            end
        end
        
        if ~isempty(par.meshspace)
            cmd = sprintf('%s --meshspace=%s',cmd,par.meshspace);
        end
        
        if ~isempty(par.seedref)
            cmd = sprintf('%s\\\\\n --seedref=%s',cmd,par.seedref{nbsuj});
        end
        
        %--seedref	Reference vol to define seed space in simple mode - diffusion space assumed if absent

        jobs{end+1} = cmd;
        
    end
end

if ~isempty(jobs)
    do_cmd_sge(jobs,par)
end



function make_file_list(target,target_file)

target = cellstr(char(target));

ff=fopen(target_file,'w');

for k=1:length(target)
    fprintf(ff,'%s\n',target{k});
end
fclose(ff);
