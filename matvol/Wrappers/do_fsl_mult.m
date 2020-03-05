function out = do_fsl_mult(fo,outname)
%function out = do_fsl_mult(fo,outname)
%fo is either a cell or a matrix of char
%outname is the name of the fo volumes sum
%

if ~exist('par'),par ='';end

defpar.fsl_output_format = 'NIFTI';

par = complet_struct(par,defpar);


if iscell(outname)
 if length(fo)~=length(outname)
   error('the 2 cell input must have the same lenght')
 end
 
   
  for k=1:length(outname)
    out{k} = do_fsl_mult(fo{k},outname{k});
  end
  return
end


fo = cellstr(char(fo));

cmd = sprintf('\n export FSLOUTPUTTYPE=%s;\n fslmaths %s',par.fsl_output_format,fo{1});

for k=2:length(fo)
  cmd = sprintf('%s -mul %s',cmd,fo{k});
end

cmd = sprintf('%s %s',cmd,outname);

fprintf('writing %s \n',outname)
unix(cmd);

out = [outname '.nii.gz'];
