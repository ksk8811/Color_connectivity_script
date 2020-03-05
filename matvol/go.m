init_path

if exist('Exams')
  AddExams=1;
end

%for Warning with spm2 and 5
spm('defaults','fmri')
spm_jobman('initcfg')

 %spm_defaults
 %global defaults
 %defaults.modality='FMRI';

%get_series_from_dataPath
%remove_anat
%clear prog choix_prog choix_p


