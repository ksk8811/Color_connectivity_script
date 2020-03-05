function do_fsl_eddy(f4D,par,jobappend)

if ~exist('par'),par ='';end
if ~exist('jobappend','var'), jobappend ='';end

defpar.bvecs = '^bvecs$';
defpar.bvals = '^bvals$';
defpar.mask = 'nodif_brain_mask';
defpar.index = 'index.txt';

defpar.topup_dir = '';
defpar.topup = '4D_B0_topup';
defpar.topup_acqp = 'acqp.txt';
defpar.outsuffix = 'eddycor';
defpar.resamp = 'jac'; %'jac' 'lsr'
defpar.eddy_add_cmd='';
defpar.sge=1;
defpar.jobname='eddy';
defpar.walltime='12:00:00';

par = complet_struct(par,defpar);


par.index  = get_file_from_same_dir(f4D,par.index);
par.mask  = get_file_from_same_dir(f4D,par.mask);
par.bvecs = get_file_from_same_dir(f4D,par.bvecs);
par.bvals = get_file_from_same_dir(f4D,par.bvals);

par.topup_acqp = addsufixtofilenames(par.topup_dir,['/' par.topup_acqp]);
if ~strcmp(par.topup(1),'/')
    par.topup = addsufixtofilenames(par.topup_dir,['/' par.topup]);
end

outfile = addsufixtofilenames(f4D,par.outsuffix)

for k=1:length(f4D)

    cmd = sprintf('eddy %s --imain=%s  --mask=%s  --index=%s  --bvecs=%s  --bvals=%s  --acqp=%s  --topup=%s  --out=%s --resamp=%s\n',...
        par.eddy_add_cmd,f4D{k},par.mask{k},par.index{k},par.bvecs{k},par.bvals{k},par.topup_acqp{k},par.topup{k},outfile{k},par.resamp)
    
    job{k} = cmd;
end

job = do_cmd_sge(job,par,jobappend);