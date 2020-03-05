function do_qc_series(serdir,par)

if ~exist('par','var'),par ='';end

defpar.outdir = '/servernas/nasDicom/QC/';
defpar.sge = 0;
defpar.jobname = 'job_qc_mat';
defpar.sge_queu = 'long';
defpar.do_plot = 1;
defpar.seuil = 0.2;
defpar.do_delete = 1;
defpar.do_write=1;
defpar.write_mail = 0;

par = complet_struct(par,defpar);

outdir = par.outdir;

doQC=1;

for nbser = 1:length(serdir)
    tdir = serdir{nbser};
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
    ff=cellstr(char(ff));
    
    if isempty(ff)
        fprintf('series %s has no 4D data\n',tdir);
        doQC=0;
    end
    
    if length(ff)==1
        [ppp fff ext] = fileparts(ff{1});
        if strcmp(ext,'.nii')
            vy = spm_vol(char(ff));
            if length(vy)<=1
                fprintf('series %s has no 4D data\n',tdir);
                doQC=0;
            end
        else
            doQC=0;
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
        end
        
    end
    
    par.skip = skip; par.do_plot=1;  par.hh=hh;
    par.outdir = So;
    
    if doQC
        if par.sge
            
            var_file = do_cmd_matlab_sge({'get_slice_mean_struct(tdir,par)'},par);
            save(var_file{1},'tdir','par');
            
        else
            cout = get_slice_mean_struct(tdir,par);
            
            if par.do_write
                text_qc = fullfile(outdir,P,['qc_' P '_' seq_name,'.csv']);
                res=struct2res(cout);
                write_result_to_csv(res,text_qc);
            end
        end
        if cout.V_mFond_all>10
            text_bf = fullfile(outdir,'Bad_series.csv')
            write_result_to_csv(res,text_bf);
            
            if par.write_mail
                msg= {sprintf('Bonjour\n Merci de verifier %s %s %s\n(dans /nasDicom/QC/\n)',cout.protocol,cout.Sujet,cout.Series)};
                setpref('Internet','SMTP_Server','courriel.upmc.fr');
                setpref('Internet','E_mail','Quality.Control@upmc.fr');
                try
                    sendmail({'romain.valabregue@upmc.fr'},'coucou',msg);
                    sendmail({'melanie.didier@icm-institute.org'},'coucou',msg);
                    sendmail({'frederic.humbert@upmc.fr'},'coucou',msg);
                    sendmail({'antoine.burgos@icm-institute.org'},'coucou',msg);
                    sendmail({'kevin.nigaud@upmc.fr'},'coucou',msg);
                    sendmail({'eric.bardinet@upmc.fr'},'coucou',msg);
                catch
                end
            end
            
        end
        
    end
    
    if par.do_write
        text_par = fullfile(outdir,P,['param_' P '_' seq_name,'.csv']);
        write_dicom_info_to_csv({hh},text_par);
    end
    
    
end


