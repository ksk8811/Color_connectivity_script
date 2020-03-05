function varargout = convert_dicom_without_tri(spm_dir,hdr_dic,unique_serie_index,ExamDescription,PatientName,SeriesDescription,USI,par)

if ~exist('par','var'),par ='';end

defpar.output_type = 'img'; % nii 4D
defpar.skipderived=1;

par = complet_struct(par,defpar);

I=unique_serie_index;
WD=pwd;
serout='';

for k = 1:size(I,1)
    exa_dirname = nettoie_dir(ExamDescription{I(k)});
    ser_dirname = nettoie_dir(SeriesDescription{I(k)});
    pat_dirname = nettoie_dir(PatientName{I(k)});
    
    ind=(USI==k);
    
    hdr = hdr_dic(ind);
    %P = char(Filenames(ind));
    
    %     if isfield(hdr{1},'ImageComments')
    %         if strcmp(hdr{1}.ImageComments,'DTI Tensor')
    %             fprintf('skiping TENSOR convertion\n');
    %             break
    %         end
    %     end
    
    serie_dir_spm = fullfile(spm_dir,exa_dirname,pat_dirname,ser_dirname);
    
    if par.skipderived
        if ~isempty(strfind(hdr{1}.ImageType,'DERIVED')) || ~isempty(strfind(hdr{1}.ImageType,'SECONDARY')) ...
                || ~isempty(strfind(hdr{1}.ImageType,'\ADC\')) || ~isempty(strfind(hdr{1}.ImageType,'\TENSOR\')) ...
                || ~isempty(strfind(hdr{1}.ImageType,'\FA\')) || ~isempty(strfind(hdr{1}.ImageType,'\TRACEW\')) ...
                || ~isempty(strfind(hdr{1}.ImageType,'\OTHER\'))
            fprintf('skiping DERIVED series\n');
            serout{k}='none';
            continue
        end
        
        
        switch hdr{1}.SOPClassUID
            case '1.2.840.10008.5.1.4.1.1.7'
                fprintf('skiping FA Color ? convertion %s \n',serie_dir_spm);
                continue
            case '1.3.12.2.1107.5.9.1'
                %if strfind(hdr{1}.CSAImageHeaderType,'DTI NUM')  %if SPEC NUM 4 it is spectro data
                fprintf('skiping Tensor or spectra convertion %s \n',serie_dir_spm);
                continue
                %end
                
        end
        hh = get_dicom_info(hdr(1));
        if strfind(upper(hh{1}.SeriesDescription),upper('MPR Range'))
            continue
        end
    end
    
    if ~exist(serie_dir_spm)
        mkdir(serie_dir_spm)
    end
    
    
    cd(serie_dir_spm);
    %hdr = spm_dicom_headers(P);
    
    fprintf('%s\n',pwd)
    if strcmp(par.output_type,'img')
        spm_dicom_convert(hdr,'all','flat','img');
    else
        spm_dicom_convert(hdr,'all','flat','nii');
        
        switch par.output_type
            case '4D'
                %only convert functional volume (starting with f)
                parrr.verbose=0;
                ff=get_subdir_regex_files(pwd,'^[sf].*nii$',parrr);
                
                if ~isempty(ff)
                    ff=cellstr(char(ff));
                    if length(ff)>1
                        [pp nn] = get_parent_path(ff);
                        ind = nn{1}-nn{end} ;
                        inddiff = find(ind);
                        common_name = nn{1}(1:inddiff(1));
                        while strcmp(common_name(end)','0') || strcmp(common_name(end),'-')
                            common_name(end)='';
                        end
                        unix(sprintf(' fslmerge  -t %s_4D_v%d *.nii',common_name,length(ff)));
                        unix('rm -f *.nii');
                    end
                end
        end
    end
    cd(WD)
    serout{k} = serie_dir_spm;
end

if nargout==1
    varargout{1} = serout;
end

