
d=get_subdir_regex(pwd,'PROTO','.*','DTI_50.*TR12$')

P=char(d)

if ~exist('P')
  P = spm_select([1 Inf],'dir','Select directories of dicom files','',pwd); 
end

if ~exist('outdir')
  outdir = spm_select([1 Inf],'dir','Select output dir','',pwd); 
end

ff = get_first_files_recursif(P);
%ff = get_files_recursif(P);

Series_header_name = fullfile(outdir,'liste_sequences_archive.csv')

write_dicom_info_to_csv(ff,Series_header_name)

