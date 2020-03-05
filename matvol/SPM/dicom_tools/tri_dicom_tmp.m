%function tri_dicom_tmp()

global GUIOK
GUIOK=0;

dt = get_subdir_regex('/nasDicom/tmp_dcmtk_server/','.*');
%dt = get_subdir_regex('/servernas/home/romain/tmp/tmstoc','.*');

dtf=get_subdir_regex_files(dt,'.*\.dic');

output_dir = '/nasDicom/recup/dicom_raw/';
spm_dir = '/nasDicom/recup/spm_raw/';

%output_dir = '/servernas/home/romain/tmp/tmstoc/dicom/';
%spm_dir = '/servernas/home/romain/tmp/tmstoc/spm/';

spm_defaults;

for kk=1:length(dtf)
    
    Filenames = cellstr(char(dtf(kk)));
    
    [ExamDescription,PatientName,SeriesDescription,unique_serie_index,USI,hdr_dic] = get_description_from_dicom(Filenames);
    
    if findstr(PatientName{1},'Service Patient')
        fprintf('Skiping %s \n', Filenames{1})
        dd=r_mkdir(output_dir,{'servicePAt'});
       r_movefile(Filenames,repmat(dd,size(Filenames)),'move');
        
    else
        
        SeriesDescription = write_info(output_dir,hdr_dic,ExamDescription,PatientName,SeriesDescription,unique_serie_index,'/tmp',USI);
        
        %check if you have output directories created
%         for nbser=1:unique_serie_index
%             exa_dirname = nettoie_dir(ExamDescription{nbser});
%             ser_dirname = nettoie_dir(SeriesDescription{nbser});
%             pat_dirname = nettoie_dir(PatientName{nbser});
%             
%             if  ~isdir(fullfile(output_dir,exa_dirname,pat_dirname,ser_dirname))
%                 error('no dir %s',fullfile(output_dir,exa_dirname,pat_dirname,ser_dirname))
%             end
%         end
        
        fprintf('%s\n','Starting move files')
        move_file(output_dir,Filenames,ExamDescription,PatientName,SeriesDescription,1)
        
        fprintf('%s\n','Starting analyze conversion')
        convert_dicom_after_tri(spm_dir,output_dir,unique_serie_index,ExamDescription,PatientName,SeriesDescription)
        
        fprintf('%s\n','Done')
    end
    
end

%fprintf('check in /tmp\n')
%unix('ls -ltr /tmp')
