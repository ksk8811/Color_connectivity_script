

if ~exist('P')
 P = spm_select([1 Inf],'dir','Select directories of dicom files','','/nasDicom/dicom_raw'); 
end

  
spm_defaults;


% spm_dir=output_dir;
 

 Filenames = get_files_recursif(P);
 Bad_dicom_files_ind =[];
 
 for i=1:length(Filenames)
    if ~isdicom(Filenames{i})
     Bad_dicom_files_ind(end+1) = i;
    end
 end
 if ~isempty(Bad_dicom_files_ind)
     Filenames(Bad_dicom_files_ind)='';
 end    
 
 [ExamDescription,PatientName,SeriesDescription,unique_serie_index,USI] = get_description_from_dicom(Filenames);
 
 
% write_info(output_dir,Filenames,ExamDescription,PatientName,SeriesDescription,unique_serie_index,0,USI)

 % fprintf('%s\n','Starting move files')
 %move_file(output_dir,Filenames,ExamDescription,PatientName,SeriesDescription,0)
 
 fprintf('%s\n','Starting analyze conversion')

 convert_dicom_without_tri_local(Filenames,unique_serie_index,ExamDescription,PatientName,SeriesDescription,USI)

 fprintf('%s\n','Done')
