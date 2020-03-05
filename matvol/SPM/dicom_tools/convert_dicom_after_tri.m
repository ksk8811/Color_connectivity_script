function varargout = convert_dicom_after_tri(spm_dir,output_dir,unique_serie_index,ExamDescription,PatientName,SeriesDescription)

I=unique_serie_index;
WD=pwd;

proto_dir = fullfile(output_dir,'..','protocol_stim');
if exist(proto_dir,'dir')
    write_proto_dir =1;
else
    write_proto_dir =0;
end

for k = 1:size(I,1)
    exa_dirname = nettoie_dir(ExamDescription{I(k)});
    ser_dirname = nettoie_dir(SeriesDescription{I(k)});
    pat_dirname = nettoie_dir(PatientName{I(k)});
    
    serie_dir_spm = fullfile(spm_dir,exa_dirname,pat_dirname,ser_dirname);
    serie_dir_dic = fullfile(output_dir,exa_dirname,pat_dirname,ser_dirname);
    serie_proto   = fullfile(proto_dir,exa_dirname,pat_dirname);
    
    %  if (is_a_volumetric_serie(serie_dir_dic))
    if ~exist(serie_dir_spm)
        mkdir(serie_dir_spm)
    end
    if write_proto_dir
        if ~exist(serie_proto)
            mkdir (serie_proto)
        end
    end
    
%     files = dir(serie_dir_dic);
%     for kk=3:length(files)
%         P(kk-2,:)=  fullfile(serie_dir_dic,files(kk).name);
%     end
    P = get_subdir_regex_files(serie_dir_dic,'.*dic$');

    cd(serie_dir_spm);
    hdr = spm_dicom_headers(char(P));
    fprintf('%s\n',pwd)
    
    if ~isfield(hdr{1},'ImageType')
       fprintf('Skiping conversion of %s\n',hdr{1}.Filename)

    elseif findstr(hdr{1}.ImageType,'TENSOR')
        fprintf('Skiping conversion of TRENSOR %s\n',hdr{1}.Filename)
        
    elseif findstr(hdr{1}.ProtocolName,'fid_aim')
        fprintf('Skiping conversion fid_aim')
    elseif findstr(exa_dirname,'_TIWI')
        fprintf('skiping TIWI conversion\n')
        
    else
        try
	spm_dicom_convert(hdr);
	catch
	end
    end
    
    %to convert in spm2 analyze format	unix('/home/dicom/bin/chris2spm2')
    
    cd(WD)
    clear P
    
    %  end
    serout{k} = serie_dir_spm;
end

if nargout==1
    varargout{1} = serout;
end








