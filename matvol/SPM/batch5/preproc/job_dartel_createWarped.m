function  matlabbatch =job_dartel_createWarped(flow,img,par)

if ~exist('par')
  par='';
end

if ~isfield(par,'preserve')
  par.preserve=0; %no modulation
end


if ~iscell(flow)
  flow = cellstr(flow);
end
if ~iscell(img)
  img = cellstr(img);
end

%-----------------------------------------------------------------------
% Job configuration created by cfg_util (rev $Rev: 3357 $)
%-----------------------------------------------------------------------

matlabbatch{1}.spm.tools.dartel.crt_warped.flowfields = flow;
matlabbatch{1}.spm.tools.dartel.crt_warped.images{1} = img;

nb_img=size(img{1},1)
  ff = cellstr(char(img));
for k=1:nb_img
	matlabbatch{1}.spm.tools.dartel.crt_warped.images{k} = ff(k:nb_img:end);
end

matlabbatch{1}.spm.tools.dartel.crt_warped.jactransf = par.preserve;
matlabbatch{1}.spm.tools.dartel.crt_warped.K = 6;
matlabbatch{1}.spm.tools.dartel.crt_warped.interp = 1;
