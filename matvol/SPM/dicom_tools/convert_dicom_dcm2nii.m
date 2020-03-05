function convert_dicom_dcm2nii(P,spm_dir,par)
%function convert_dicom(in_dir,spm_dir,par)
%  it will recursivly search all dicom file in all subdir of in_dir
%  if no argmument you will be ask to choose them graphically

if ~exist('par','var'),par ='';end

defpar.output_type = 'img'; % nii 4D

par = complet_struct(par,defpar);


if ~exist('P')
    P = spm_select([1 Inf],'dir','Select directories of dicom files','',pwd);
end

if ischar(P),P=cellstr(P);end

if ~exist('spm_dir')
    spm_dir = spm_select([1],'dir','Select directories where to put the converted data');
end

for nbdir = 1:length(P)
    Filenames = get_files_recursif(P{nbdir});
    
    Bad_dicom_files_ind =[];
    
    for i=1:length(Filenames)
        if ~isdicom(Filenames{i})
            Bad_dicom_files_ind(end+1) = i;
        end
    end
    if ~isempty(Bad_dicom_files_ind)
        Filenames(Bad_dicom_files_ind)='';
    end
    if isempty(Filenames)
        fprintf('no dicom file for %s\n',P{nbdir});
        continue
    end
    
    [ExamDescription,PatientName,SeriesDescription,unique_serie_index,USI,hdr_dic] = get_description_from_dicom(Filenames);
    
    
    write_info(spm_dir,hdr_dic,ExamDescription,PatientName,SeriesDescription,unique_serie_index,0,USI);
    
    
    fprintf('%s\n','Starting analyze conversion')
    
    ser = convert_dicom_withdcm2nii(spm_dir,hdr_dic,unique_serie_index,ExamDescription,PatientName,SeriesDescription,USI,par);
    
    fprintf('%s %d of %d\n','Done',nbdir,length(P))

end