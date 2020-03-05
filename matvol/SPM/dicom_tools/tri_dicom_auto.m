function tri_dicom_auto(input_dir,output_dir,spm_dir)

global GUIOK
GUIOK=0;

%spm('Defaults','fmri')

Filenames = get_files_recursif(input_dir);
[ExamDescription,PatientName,SeriesDescription,unique_serie_index,USI,hdr_dic] = get_description_from_dicom(Filenames);

write_info(output_dir,hdr_dic,ExamDescription,PatientName,SeriesDescription,unique_serie_index,1,USI);
write_info(spm_dir,hdr_dic,ExamDescription,PatientName,SeriesDescription,unique_serie_index,0,USI);

fprintf('%s\n','Starting move files')
move_file(output_dir,Filenames,ExamDescription,PatientName,SeriesDescription,1)


% run python convert on the newlly moved series
% ssh romain@tac 'nohup bash -c  "/home/romain/bin/do_dicom_series_DB.py -c recup" > foo.out 2> foo.err </dev/null & '
I=unique_serie_index
for k = 1:size(I,1)
    exa_dirname = nettoie_dir(ExamDescription{I(k)});
    ser_dirname = nettoie_dir(SeriesDescription{I(k)});
    pat_dirname = nettoie_dir(PatientName{I(k)});
    
    serie_dir_dic = fullfile(output_dir,exa_dirname,pat_dirname,ser_dirname)
    
    %a=tempname('~');     ff=fopen(a,'w+')  ;
    log_file = fullfile(input_dir,'do_dicom_db.log');
    err_file = fullfile(input_dir,'do_dicom_db.err');
    cmd = sprintf('ssh dicom@tao ''nohup bash -c  "do_dicom_series_DB.py -c import_auto --input_dir=%s" > %s 2> %s </dev/null & ''',...
        serie_dir_dic,log_file,err_file);
    fprintf('runing do_dicom_db (python import) through tac  with cmd :\n%s\n\n',cmd);
    unix(cmd);
    
end



fprintf('%s\n','Starting analyze conversion')
ser = convert_dicom_after_tri(spm_dir,output_dir,unique_serie_index,ExamDescription,PatientName,SeriesDescription);

fprintf('%s\n','Done')


fprintf('%s\n','Starting QC ')
par.write_mail = 1;
do_qc_series(ser,par)
fprintf('%s\n','Done')

%exit
