function convert_dicom_without_tri_local(Filenames,unique_serie_index,ExamDescription,PatientName,SeriesDescription,USI)

I=unique_serie_index;
WD=pwd;


for k = 1:size(I,1)
%  exa_dirname = nettoie_dir(ExamDescription{I(k)});
%  ser_dirname = nettoie_dir(SeriesDescription{I(k)});
%  pat_dirname = nettoie_dir(PatientName{I(k)});

  ind=(USI==k);
  P = char(Filenames(ind));
   
%  serie_dir_spm = fullfile(spm_dir,exa_dirname,pat_dirname,ser_dirname);

  
%  if ~exist(serie_dir_spm)
%    mkdir(serie_dir_spm)
%  end


%  cd(spm_dir);

  hdr = spm_dicom_headers(P);
  
  cd(fileparts(hdr{1}.Filename))
  
  fprintf('%s\n',pwd)
  spm_dicom_convert(hdr);
  cd(WD)


end








