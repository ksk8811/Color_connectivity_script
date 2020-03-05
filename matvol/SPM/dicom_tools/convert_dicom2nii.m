

if ~exist('P')
 P = spm_select([1 Inf],'dir','Select directories of dicom files','','/nasDicom/dicom_raw'); 
end


if ~exist('output_dir')
 output_dir = spm_select([1],'dir','Select directories where to put the converted data'); 
end
  
spm_defaults;


 spm_dir=output_dir;
 

 Filenames = get_files_recursif(P);
 
 %hh = spm_dicom_headers(char(Filenames));
 
 [ExamDescription,PatientName,SeriesDescription,unique_serie_index,USI,hdr_dic] = get_description_from_dicom(Filenames);
 
 write_info(output_dir,hdr_dic,ExamDescription,PatientName,SeriesDescription,unique_serie_index,0,USI)

 % fprintf('%s\n','Starting move files')
 %move_file(output_dir,Filenames,ExamDescription,PatientName,SeriesDescription,0)
 
 fprintf('%s\n','Starting analyze conversion')

 convert_dicom_2nii_without_tri(spm_dir,Filenames,unique_serie_index,ExamDescription,PatientName,SeriesDescription,USI)

 fprintf('%s\n','Done')
