function move_file(output_dir,Filenames,ExamDescription,PatientName,SeriesDescription,movefile)

global GUIOK
if isempty(GUIOK), GUIOK=0; end

if isempty(movefile)
    movefile=1
end

% retrie tous les fichiers pour les ranger dans le bon repertoire
if movefile
    if (GUIOK)   h = waitbar(0,'Moving DICOM files...');end
else
    if (GUIOK)   h = waitbar(0,'Copying DICOM files...');end
end

%keyboard

for i=1:size(Filenames)
    % nom du repertoire dans lequel ranger le fichier
    exa_dirname = nettoie_dir(ExamDescription{i});
    ser_dirname = nettoie_dir(SeriesDescription{i});
    pat_dirname = nettoie_dir(PatientName{i});
    
    % copie le fichier dans le repertoire approprie
    
    fff = Filenames{i};
    ind=findstr(fff,'null');
    if ~(isempty(ind))
        
        h1=spm_dicom_headers(fff);    h1=h1{1};
        
        ffin  = [fff(1:ind-2),'\',fff(ind-1:ind+3),'\',fff(ind+4:end)]; %add &\ before the ()
        ffout = [fff(1:ind-3),fff(ind+5:end)]; %remove the '.(null)'
        [p ffout eout] = fileparts(ffout);
        
        if ~isfield(h1,'AcquisitionNumber') |  ~isfield(h1,'InstanceNumber')
            ffout = [sprintf('Unknow_i%.4d_',i)  ffout];
        else
            
            ffout = [sprintf('sepctre_S%d_A%.3d_I%.3d_',h1.SeriesNumber,h1.AcquisitionNumber,h1.InstanceNumber) ffout];
        end
        
        if movefile
            cmd = ['!mv -i ',ffin,' ',fullfile(output_dir,exa_dirname,pat_dirname,ser_dirname,[ffout eout])];
        else
            cmd = ['!cp ',ffin,' ',fullfile(output_dir,exa_dirname,pat_dirname,ser_dirname,[ffout eout])];
        end
        eval(cmd);
        
    else
        if movefile
            cmd = ['!mv -i ',Filenames{i},' ',fullfile(output_dir,exa_dirname,pat_dirname,ser_dirname,'/')];
        else
            cmd = ['!cp ',Filenames{i},' ',fullfile(output_dir,exa_dirname,pat_dirname,ser_dirname,'/')];
        end
        eval(cmd);
        %  movefile(Filenames{i},fullfile(output_dir,exa_dirname,pat_dirname,ser_dirname));
    end
    
    
    if (GUIOK)            waitbar(i/size(Filenames,1),h);end
    
end
if (GUIOK)    close(h);end

