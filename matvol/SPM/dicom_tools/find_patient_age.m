
d=get_subdir_regex('/nasDicom/dicom_raw/PROTO_GENEPARK','200')

fid=fopen('ages.csv','w+')

for k=1:length(d)
  dd=get_subdir_regex(d(k),'LOCA');
  df= get_subdir_regex_files(dd,'.dic');

  h=spm_dicom_headers(df{1}(1,:));
  h=h{1};
   
  [p,f] = fileparts(d{k});
  [p,suj] = fileparts(p);
 
  fprintf(fid,'%s,%s\n',suj,h.PatientsAge);
   
end
 