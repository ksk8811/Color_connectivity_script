tic
norm_type = 'vbm8';
norm_type = 'new_seg';

proto_dir = '/nasDicom/spm_raw/VERIO_VE_TB3S/';
%proto_dir = '/nasDicom/spm_raw//VERIO_BALTAZAR/';
T1reg = 'S02_t1mpr';
T1reg = '3DT1$';

norm_roi = '/home/najib/data/prestoc2/roi_mni/sphere_10--50_30_36.nii';

root_outdir = fullfile(getenv('HOME'),'data','prestoc2');

if ~exist(root_outdir)
    mkdir(root_outdir);
end

sujdir = get_last_modif_dir(proto_dir);
T1dir = get_subdir_regex(sujdir,T1reg);
char(T1dir)

%T1dir = cellstr( spm_select([1 Inf],'dir','Select the T1 dir ','',proto_dir));

[p,sujname] = get_parent_path(T1dir,2);

switch norm_type
    case 'vbm8'
        anatdir = fullfile(root_outdir,sujname{1},'T1mprage_vbm8')
    case 'new_seg'
        anatdir = fullfile(root_outdir,sujname{1},'T1mprage_seg8')
end

if ~exist(anatdir)
    mkdir(anatdir)
    fT1=get_subdir_regex_files(T1dir,'.*img$',1);
    r_movefile(fT1,anatdir,'link');
    fT1=get_subdir_regex_files(T1dir,'.*hdr$',1);
    r_movefile(fT1,anatdir,'copy');
    r_movefile({norm_roi},anatdir,'link');
end
fT1=get_subdir_regex_files(anatdir,'.*img$',1);
froi = get_subdir_regex_files(anatdir,'^sphere_.*nii$',1);

switch norm_type
    case 'vbm8'
        inv_f = get_subdir_regex_files(anatdir,'^iy.*nii$');
        if isempty(inv_f)
            j = job_vbm8(fT1);
            spm_jobman('run',j)
        end
        inv_f = get_subdir_regex_files(anatdir,'^iy.*nii$');
        
        j=job_vbm8_create_wraped(inv_f,froi);
        spm_jobman('run',j)
        
    case 'new_seg'
        inv_f = get_subdir_regex_files(anatdir,'^iy.*nii$');
        if isempty(inv_f)
            j=job_new_segment(fT1);
            spm_jobman('run',j)
        end
        inv_f = get_subdir_regex_files(anatdir,'^iy.*nii$');
        
        j=job_vbm8_create_wraped(inv_f,froi);
        spm_jobman('run',j)
end

froi_nativ =  get_subdir_regex_files(anatdir,'^wsphere_.*nii$',1);

o=write_vol_to_roi(froi_nativ{1});
com = c_o_m(o)
  com = [com(1)+11,com(2),com(3)-8.5];


tt=toc
[cc ccc]=unix('hostname');


fp=fopen(fullfile(anatdir,'center_of_mass.txt'),'w+')
  if com(1)<0,  st1 =' L '; else, st1=' R '; end
  if com(2)<0,  st2 =' P '; else, st2=' A '; end
  if com(3)<0,  st3 =' F '; else, st3=' H '; end

  msg = sprintf(' %s %f\n %s %f \n %s %f\n Computed on %s in %f seconds \n %f \t %f \t %f \n',st1,abs(com(1)),st2,abs(com(2)),st3,abs(com(3)),ccc,tt,com);
fprintf(fp,msg)
fclose(fp)

fprintf(msg);

        setpref('Internet','SMTP_Server','mailhost.chups.jussieu.fr');
        setpref('Internet','E_mail','thebest@cenir');
        %try
        sendmail('najib.allaili@gmail.com','DLPFC coord',msg);
        %catch
        %end

        


if 0
    -40.3892
    -1.5421
    -22.4093
    
    %Elapsed time is 976.739584 seconds
    % 976./60=   16.2667
end
