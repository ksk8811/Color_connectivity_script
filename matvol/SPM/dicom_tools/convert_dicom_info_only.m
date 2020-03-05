

if ~exist('P')
 P = spm_select([1 Inf],'dir','Select directories of dicom files','','/nasDicom/dicom_raw'); 
end


if ~exist('output_dir')
 output_dir = spm_select([1],'dir','Select directories where to put the dicom information'); 
end
  
spm_defaults;


 spm_dir=output_dir;
 

 Filenames = get_files_recursif(P);
 
 %hh = spm_dicom_headers(char(Filenames));
 
 [ExamDescription,PatientName,SeriesDescription,unique_serie_index,USI] = get_description_from_dicom(Filenames);
 
 write_info(output_dir,Filenames,ExamDescription,PatientName,SeriesDescription,unique_serie_index,0,USI)

