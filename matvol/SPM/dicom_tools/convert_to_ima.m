
 P = spm_select([1 Inf],'image','Select directories of dicom files');

 fid =fopen('cmd.sh','w');
fprintf(fid,'. /usr/local/src/SHFJ_pack-stable-linux-3.0.2/bin/SHFJEnvironmentVariables.sh;\n');
 
 for k=1:size(P,1)
   fprintf(fid,' AimsFileConvert -i %s -o %s \n' ,P(k,1:end-2), [P(k,1:end-6),'.ima']);
 end
