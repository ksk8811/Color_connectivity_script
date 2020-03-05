function varargout = convert_dicom_without_tri(spm_dir,hdr_dic,unique_serie_index,ExamDescription,PatientName,SeriesDescription,USI,par)

if ~exist('par','var'),par ='';end

defpar.output_type = 'img'; % nii 4D

par = complet_struct(par,defpar);

I=unique_serie_index;
serout='';

for k = 1:size(I,1)
    exa_dirname = nettoie_dir(ExamDescription{I(k)});
    ser_dirname = nettoie_dir(SeriesDescription{I(k)});
    pat_dirname = nettoie_dir(PatientName{I(k)});
    
    ind=(USI==k);
    
    hdr = hdr_dic(ind);
    
    serie_dir_spm = fullfile(spm_dir,exa_dirname,pat_dirname,ser_dirname);
     
    if ~exist(serie_dir_spm)
        mkdir(serie_dir_spm)
    end
    
    fprintf('%s\n',pwd);
    [pp ff] = fileparts(hdr{1}.Filename);

    cmd = sprintf('cd %s \n dcm2nii -o %s/ -d N -f N -p N',pp,serie_dir_spm)
    for kk=1:length(hdr)
	[pp ff] = fileparts(hdr{k}.Filename);
        cmd = sprintf('%s %s',cmd,ff);
    end
    unix(cmd);
    
    ff = get_subdir_regex_files(serie_dir_spm,'.*nii.gz',1);
    ffo = addprefixtofilenames(ff,'f');
    r_movefile(ff,ffo,'move');
    
    serout{k} = serie_dir_spm;
end

if nargout==1
    varargout{1} = serout;
end

