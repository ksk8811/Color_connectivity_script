function [ExamDescription,PatientName,SeriesDescription] = get_description_from_dicom_hdr(hh)


SeriesDescription = []; ExamDescription = []; PatientName=[];



hdr = hh{1};

if hdr.Modality == 'MR' |  hdr.Modality == 'OT' |  hdr.Modality == 'SR'
    
    if isfield(hdr,'StudyDescription')
        E_description = [hdr.StudyDescription];
    else
        if isfield(hdr,'StudyID')
            E_description = [hdr.StudyID];
        else
            E_description = datestr(hdr.StudyDate);
        end
    end
    
    Snum = sprintf('S%.2d',hdr.SeriesNumber);
    if isfield(hdr,'SeriesDescription')
        S_description = [Snum, '-',hdr.SeriesDescription];
    else
        if isfield(hdr,'ProtocolName')
            S_description = [Snum, '-',hdr.ProtocolName];
        else
            S_description = [Snum];
        end
    end
    
    %Attetion changement le 15/11/2013 en fait StudyDate c'est la creation de la study mais Acquisition date c'est bien la date d'acquisition
    %P_description = [datestr(hdr.StudyDate,29), '_', hdr.PatientsName ];
    if ~isfield(hdr,'AcquisitionDate') %for spectro data
        thedate = hdr.StudyDate;
    else
        if hdr.StudyDate>hdr.AcquisitionDate %I do not know why this happen for tensor series
            thedate = hdr.StudyDate;
        else
            thedate = hdr.AcquisitionDate;
        end
    end
    
    P_description = [datestr(thedate,29), '_', hdr.PatientsName ];
    
    
    if isfield(hdr,'StudyID')
        if str2num(hdr.StudyID) > 1
            P_description = [ P_description ,'_E',num2str(str2num(hdr.StudyID))];
        end
    end
    
    
    %     SeriesDescription = [SeriesDescription;{S_description}];
    %     ExamDescription = [ExamDescription;{E_description}];
    %     PatientName = [PatientName;{P_description}];
    SeriesDescription =nettoie_dir(S_description);
    ExamDescription = nettoie_dir(E_description);
    PatientName = nettoie_dir(P_description);
    
else
    error('grrr')
end





