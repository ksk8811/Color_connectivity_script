
% outdir = '/icm/cluster_data/users/romain.valabregue/qc_spm';
if ~exist('outdir','var'), outdir = get_subdir_regex; outdir =char(outdir) ;end%'/servernas/images5/romain/test/qc';end
if ~exist('suj','var'), suj=get_subdir_regex;end

if ~exist('par','var')
    par.sge = 1;
    par.jobname = 'job_qc_mat';
    par.sge_queu = 'long';
    par.do_plot = 0;
    par.do_matlab_qc=0;
    par.do_fbirn=1;
    %par.fbirn_path = %'/usr/cenir/src/fbirn/bxh_xcede/bin/';
end
%sdir = get_subdir_regex(suj,'^S')


for nbser = nbser:length(sdir)
    tdir = sdir{nbser};
    %dicom info hh from load dicfile
    dicfile=fullfile(tdir,'dicom_info.mat');
    if ~exist(dicfile,'file')
        %warning('you should re convert the dicom to get the dicom info .mat file')
        continue
    end
    
    load(dicfile); %this load the hh struct of dicom field
    if iscell(hh),    hh = hh{1}; end
    if is_dicom_series_type(hh,'derived')
        continue
    end
    
    ff = get_subdir_regex_images(tdir,'^f');
    
    if isempty(ff)
        fprintf('series %s has no 4D data\n',tdir);
        continue
    end
    
    if length(ff)==1
        [ppp fff ext] = fileparts(ff{1});
        if strcmp(ext,'.nii')
            vy = spm_vol(char(ff));
            if length(vy)<=1
                fprintf('series %s has no 4D data\n',tdir);
                continue
            end
        end
    end
    
    
    %seq_name = nettoie_dir([hh.SequenceSiemensName ' ' hh.SequenceName ]);
    seq_name = nettoie_dir([hh.SequenceSiemensName ]);
    %seq_names{end+1} = seq_name;
    
    [P  E S] = get_ExamDescription(hh);
    Po = r_mkdir(outdir,{P});    Eo = r_mkdir(Po,E);    So = r_mkdir(Eo,S);
    
    skip=0;
    
    if is_dicom_series_type(hh,'dti')
        
        bval = get_subdir_regex_files(tdir,['bvals$']);
        
        if ~isempty(bval)
            b=load(bval{1});
            skip=find(b<100);
            %             if length(b)~=length(ff)
            %                 fprintf('series %s is incomplete\n',tdir);
            %                 continue
            %             end
        end
        
    elseif is_dicom_series_type(hh,'fmri')
        if par.do_fbirn
            ffo = fullfile(Eo{1},S);
            fff = cellstr(char(ff));
            cmd = 'analyze2bxh';
            for k=1:length(fff)
                cmd = sprintf('%s %s',cmd,fff{k});
            end
            cmd = sprintf(' %s %s.bxh',cmd,ffo);
            
            cmd = sprintf('%s\n fmriqa_generate.pl --forcetr %f %s.bxh %s_res',...
                cmd,hh.RepetitionTime/1000,ffo,ffo);
            
            if par.sge
                pp=par; pp.jobname = 'job_fbirn2';
                do_cmd_sge({cmd},pp);
            end
            %unix(cmd)
        end
    else
        %fprintf('The series %s has 4D data with seq %s but')
        warning(sprintf('SKING  4D series %s',hh.SequenceSiemensName));
    end
    
    if par.do_matlab_qc
        par.text_file = fullfile(outdir,['qc_' P '_' seq_name,'.csv']);
        par.skip = skip; par.do_plot=1;  par.hh=hh;
        par.outdir = So;
        if par.sge
            
            var_file = do_cmd_matlab_sge({'get_slice_mean_struct(tdir,par)'},par);
            save(var_file{1},'tdir','par');
            
        else
            cout = get_slice_mean_struct(tdir,par);
        end
    end
end









if 0 %pour la relecture
    d=get_subdir_regex
    st=get_subdir_regex(d,'^S');
    cout = get_slice_mean_struct(st);
    
    rff=get_subdir_regex_files(st,'^rf.*nii');
    ff=get_subdir_regex_files(st,'^f.*nii');
    
    par.save_qc_struct_file = 'qc_struct.mat';%seuil 02
    par.save_qc_struct_file = 'qc_struct_03.mat';
    par.seuil=0.2;
    cout = get_slice_mean_struct(st,par);
    
    %pour effacer les single serie
    [f p ] = get_subdir_regex_files(st,'qc_stru');
    do_delete(p)
    
    cfonc=cout(1);cdiff=cout(1);
    for k=1:length(cout)
        if cout(k).mem.skip==0,            cfonc(end+1) = cout(k);
        else  cdiff(end+1) = cout(k);        end
    end
    cfonc(1)='';cdiff(1)='';
    
    res=struct2res(cout);
    rdiff = struct2res(cdiff);
    rfonc = struct2res(cfonc);
    
    ind=rfonc.NumFile<30;
    cfonc(ind) = [];rfonc = struct2res(cfonc);
    
    [rdo, ind] = sort(res.date);
    rdnum=datenum(rdo,'yyyy_mm_dd');
    [rdnum_cum,i,j]=unique(rdnum);
    
    nf=fieldnames(res);
    for k=1:length(nf)
        aa=getfield(res,nf{k});
        aa = aa(ind);
        res = setfield(res,nf{k},aa);
    end
    
    yval = {'NumFile','V_mFond_all','VolArt','V_varFond','V_mTot'}
    clear y ycum ymean
    for ky=1:length(yval)
        y=getfield(res,yval{ky});
        
        for k=1:length(i)
            ind = find(j==k);
            ycum(k) = sum(y(ind));
            ymean(k) = mean(y(ind));
        end
        
        figure
        subplot(3,1,1);    plot(rdnum,y,'x');datetick(gca);grid on
        title(yval{ky});
        subplot(3,1,2);    plot(rdnum_cum,ycum,'x');datetick(gca);grid on
        subplot(3,1,3);    plot(rdnum_cum,ymean,'x');datetick(gca);grid on
    end
    
    rr=rfonc;cc=cfonc;
    rr=rdiff;cc=cdiff;
    proto=rr.protocol
    [rproto,i,j]=unique(proto);
    for k=1:length(rproto)
        rr=struct2res(cc(j==k));
        write_result_to_csv(rr,[rproto{k} '_diff.csv']);
    end
    
    
end
