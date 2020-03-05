function correct_qc_dti(dti,par)

if ~exist('par','var'),par ='';end
defpar.bvals = 'bval';
defpar.bvecs = 'bvec';
defpar.seuil = 0.2;
defpar.dorealign = 0;
defpar.select_img = '^f';
defpar.do_write=0;
defpar.qc_file=fullfile(pwd,'QC_DTI.csv');

par = complet_struct(par,defpar);
WD=pwd;


for nbs=1:length(dti)
    bval = get_subdir_regex_files(dti{nbs},par.bvals,1);
    b=load(bval{1});
    
    par.skip=find(b<100);

    cout = get_slice_mean_struct(dti{nbs},par);
                
    if par.do_write
        res=struct2res(cout);
        write_result_to_csv(res,par.qc_file);
        continue
    end
    
    rmVol = unique([cout.mem.Vol_mTot_min_ind cout.mem.Vol_mTot_max_ind]);
    if ~isempty(rmVol)
        fprintf('series %s has %d bad volume\n',dti{nbs},length(rmVol));
        fprintf('dected white volumes %s\n',cout.Vol_mTot_max);
        fprintf('dected black volumes %s\n\n',cout.Vol_mTot_min);
        
        a = input(['Enter the volume number to be exclude\n if empty it will remove the volumes : ' num2str(rmVol) '\n and if you want to remove no volume type 0\n'],'s');
        if isempty(a)
            skipvol = rmVol;
        else
            skipvol = str2num(a);
        end

        if skipvol
            %we suppose we have 4D data here
            ff = get_subdir_regex_images(dti{nbs},par.select_img);
            
            cmd = sprintf('cd %s;fslsplit %s single_slice_data -t',dti{nbs},ff{1});
            unix(cmd);
            
            %backup data 
            backupdir = r_mkdir(dti(nbs),'orig_data')
            r_movefile(ff,backupdir,'move')
            
            ffvol = get_subdir_regex_files(dti{nbs},'single_slice_data');
            ffvolok = cellstr(char(ffvol));           
            ffvolok(skipvol) = '';
            
            do_fsl_merge({char(ffvolok)},ff)
            do_delete(ffvol,0);
            
            %change bvec and bvals
            bval_f = get_subdir_regex_files(dti{nbs},par.bvals);
            bvec_f = get_subdir_regex_files(dti{nbs},par.bvecs);
            
            bval=[];bvec=[];
            for k=1:length(bval_f)
                aa = load(deblank(bval_f{k}));
                bb = load(deblank(bvec_f{k}));
                bval = [bval aa];
                bvec = [bvec,bb];
            end
            
            if length(bval) ~= (length(ffvolok) + length(skipvol))
                error('there are %s bvalues but %d volumes',length(bval),(length(ffvolok) + length(skipvol)))
            end
            r_movefile(bval_f,backupdir,'move');
            r_movefile(bvec_f,backupdir,'move');
            
            bval(:,skipvol)=[];
            bvec(:,skipvol)=[];
            
            %Writing bvals and bvec
            
            fid = fopen(fullfile(dti{nbs},'bvals'),'w');
            fprintf(fid,'%d ',bval);  fprintf(fid,'\n');  fclose(fid);
            
            fid = fopen(fullfile(dti{nbs},'bvecs'),'w');
            for kk=1:3
                fprintf(fid,'%f ',bvec(kk,:));
                fprintf(fid,'\n');
            end
            
            fclose(fid);
            
        end
        

    else
        fprintf('no bad volumes detected for serie %s \n',dti{nbs});
    end
    
    
end

cd(WD)
