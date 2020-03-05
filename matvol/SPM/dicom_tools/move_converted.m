function move_converted(Filenames,unique_serie_index,ExamDescription,PatientName,SeriesDescription)

global GUIOK
if isempty(GUIOK), GUIOK=0; end

I=unique_serie_index;

old_dic_dir='/nasDicom/dicom_raw';
old_spm_dir='/nasDicom/spm_raw';
new_spm_dir='/nasDicom/spm_raw2';

if (GUIOK)   h = waitbar(0,'Copying SPM files...');end

for k = 1:size(I,1)
  exa_dirname = nettoie_dir(ExamDescription{I(k)});
  ser_dirname = nettoie_dir(SeriesDescription{I(k)});
  pat_dirname = nettoie_dir(PatientName{I(k)});

  
[pathdic,filename,ext] = fileparts(Filenames{I(k)});
pathspm=fullfile(old_spm_dir,pathdic(length(old_dic_dir)+1:end));

pathspm_new = fullfile(new_spm_dir,exa_dirname,pat_dirname,ser_dirname);

  
if exist(pathspm)
  
  if ~exist(pathspm_new)
    mkdir(pathspm_new)
  end
  
  cmd=['!cp -rf  ',pathspm,'/* ',pathspm_new];
  eval(cmd)
end

if (GUIOK)            waitbar(i/size(I,1),h);end

end
