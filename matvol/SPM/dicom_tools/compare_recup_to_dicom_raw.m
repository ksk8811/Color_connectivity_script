%
if ~exist('recup_dir')
    recup_dir = get_subdir_regex('/servernas/nasDicom/recup/')
end


sr=get_subdir_regex(recup_dir,'.*','.*');

root_dic = '/nasDicom/dicom_raw';
ffid=fopen('mv_file.sh','w+');

pp.verbose = 0;

for k=1:length(sr)
    [p sujn] = get_parent_path(sr(k));
    [p proto] = get_parent_path(sr(k),2);
    sd = get_subdir_regex(root_dic,proto,['^' sujn{1} '$']);
    if isempty(sd)
        fprintf('SUBJECT missing PPProto %s sujet %s is missing\n',proto{1},sujn{1});
        fprintf(ffid,'mv %s %s;\n',sr{k},fullfile(root_dic,proto{1}));
        fprintf(ffid,'chmod 755 %s;\n',fullfile(root_dic,proto{1}, sujn{1}));
        fprintf(ffid,'chmod 755 %s/*;\n',fullfile(root_dic,proto{1}, sujn{1}));
        fprintf(ffid,'chmod 644 %s/*/*;\n',fullfile(root_dic,proto{1}, sujn{1}));
        
        
    elseif length(sd)==1
        ser = get_subdir_regex(sr(k),'.*');
        for ks=1:length(ser)
            [p sername] = get_parent_path(ser(ks));
            serdic = get_subdir_regex(sd,['^' sername '$']);
            if isempty(serdic)
                fprintf('Proto %s sujet %s Series %s is missing\n',proto{1},sujn{1},sername{1});
                fprintf(ffid,'mv %s %s;\n',ser{ks},sd{1});
                fprintf(ffid,'chmod -R 755 %s;\n',fullfile(sd{1},sername{1}));
                fprintf(ffid,'chmod -R 644 %s/*;\n',fullfile(sd{1},sername{1}));
            else
                ffd=get_subdir_regex_files(serdic,'.*dic$',pp);
                ff=get_subdir_regex_files(ser(ks),'.*dic$',pp);
                if isempty(ffd)
                    fprintf('WARNIGN EMPTY Proto %s sujet %s Series %s wrong Number\n',proto{1},sujn{1},sername{1});
                else
                    if any( size(ff{1},1) - size(ffd{1}),1)
                        fprintf('WARNIGN %d | %d  (recup | dicom_raw) Serie %s/%s/%s wrong Number  \n', ...
                            size(ff{1},1),size(ffd{1},1),proto{1},sujn{1},sername{1});
                    end
                end
            end
            
        end
        
    else
       error('too many se in dicom dir')
    end
    
end

fclose(ffid);
