function convert_dicom_sge(P,spm_dir,par)
%function convert_dicom(in_dir,spm_dir

if ~exist('par','var'),par ='';end

defpar.output_type = 'nii'; % img nii 4D
defpar.jobname = 'matlab_convert_dicom';
par = complet_struct(par,defpar);

for nbdir = 1:length(P)
    
    dicdir = P{nbdir};
    if ischar(dicdir),P=cellstr(dicdir);end

    mat_cmd = sprintf('A=''%s'';\n convert_dicom(dicdir,spm_dir,par)',dicdir{1});
    
    jf(nbdir) = do_cmd_matlab_sge({mat_cmd},par);

    save(jf{nbdir},'dicdir','spm_dir','par')
    
end

if 0
    %again 
    f=get_subdir_regex_files(pwd,'err')
    f=cellstr(char(f)); 
    [pp fn] = get_parent_path(f);
    nd=get_subdir_regex(pwd,'again')

    for k=1:length(f)
        d=dir(f{k})
        if d.bytes
            freg = change_file_extension(fn{k},'')
            j=get_subdir_regex_files(pwd,freg)
            r_movefile(j,nd,'link')
        end
    end

    
end