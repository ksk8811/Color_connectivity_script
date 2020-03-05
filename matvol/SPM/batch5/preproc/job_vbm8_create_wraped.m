function  matlabbatch = job_vbm8_create_wraped(flow,img,par)


if ~exist('par')
  par='';
end


defpar.module = 0; %no modulation
defpar.interp=5
defpar.sge = 0;

defpar.jobname='spm_warp';
defpar.walltime = '00:30:00';


par = complet_struct(par,defpar);


if ~iscell(flow)
  flow = cellstr(flow);
end
if ~iscell(img)
  img = cellstr(img)';
end


for k=1:length(flow)
  %matlabbatch{k}.spm.tools.vbm8.tools.defs.field = flow(k);
  matlabbatch{k}.spm.tools.vbm8.tools.defs.field1 = flow(k);
  imgss = cellstr(char(img(k)));
  
%  for kk=1:length(imgss)
    %arrg update spm 06/2011    matlabbatch{k}.spm.tools.vbm8.tools.defs.images = imgss;
%    matlabbatch{k}.spm.tools.vbm8.tools.defs.fnames = imgss;
    matlabbatch{k}.spm.tools.vbm8.tools.defs.images = imgss;
%  end

  matlabbatch{k}.spm.tools.vbm8.tools.defs.interp = par.interp;
  matlabbatch{k}.spm.tools.vbm8.tools.defs.modulate = par.module;
end


if par.sge
    for k=1:length(matlabbatch)
        j=matlabbatch(k);        
        cmd = {'spm_jobman(''run'',j)'};
        varfile = do_cmd_matlab_sge(cmd,par);
        save(varfile{1},'j');
    end
end