function out = do_fsl_copy_hdr(fref,fmove,par)

if ~exist('par'),par ='';end

defpar.sge=0;
%defpar.fsl_output_format = 'NIFTI_GZ'; %ANALYZE, NIFTI, NIFTI_PAIR, NIFTI_GZ


job={};

par = complet_struct(par,defpar);

for nbs=1:length(fref)
    fo = cellstr(char(fmove(nbs)));
    for nbmove = 1:length(fo)
        cmd = sprintf('fslcpgeom %s %s -d',fref{nbs},fo{nbmove});
        
        if par.sge
            job{end+1} = cmd;
        else
            unix(cmd);
        end
    end
    
end

if par.sge
    do_cmd_sge(job,par)
end
