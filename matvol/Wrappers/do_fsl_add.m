function out = do_fsl_add(fo,outname,par)
%function out = do_fsl_add(fo,outname)
%fo is either a cell or a matrix of char
%outname is the name of the fo volumes sum
%


if ~exist('par'),par ='';end
defpar.sge=0;
defpar.software = 'fsl'; %to set the path
defpar.software_version = 5; % 4 or 5 : fsl version
defpar.jobname = 'fslmerge';
defpar.checkorient=1;

par = complet_struct(par,defpar);


if iscell(outname)
 if length(fo)~=length(outname)
   error('the 2 cell input must have the same lenght')
 end
 
   
  for k=1:length(outname)
    do_fsl_add(fo{k},outname{k});
  end
  return
end


fo = cellstr(char(fo));

delete_tmp=[];

if par.checkorient
for k=2:length(fo)
    if compare_orientation(fo(1),fo(k)) == 0
        fprintf('\ndifferent orientation do reslice\n')
        ppp.outfilename = {tempname};
        
        fo(k) = do_fsl_reslice(fo(k),fo(1),ppp);
        delete_tmp=[delete_tmp k];
        %error('volume %s and %s have different orientation or dimension',fo{1},fo{k})        
        %return
    end
end
end

cmd = sprintf('fslmaths %s',fo{1});

for k=2:length(fo)
  cmd = sprintf('%s -add %s',cmd,fo{k});
end

cmd = sprintf('%s %s',cmd,outname);

fprintf('writing %s \n',outname)
unix(cmd);

if ~isempty(delete_tmp)
    do_delete(fo(delete_tmp),0)
end

out = [outname '.nii.gz'];
