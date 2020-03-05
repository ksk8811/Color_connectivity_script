function [E_description,P_description,S_description] = get_ExamDescription(hdr)


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

 if ~isfield(hdr,'StudyDate')
     thedate = hdr.SeriesDate;
 else
     thedate=hdr.StudyDate
 end
 
P_description = [datestr(thedate,29), '_', hdr.PatientsName ];

if isfield(hdr,'StudyID')
    if str2num(hdr.StudyID) > 1
        P_description = [ P_description ,'_E',num2str(str2num(hdr.StudyID))];
    end
end

E_description=nettoie_dir(E_description);
P_description=nettoie_dir(P_description);
S_description=nettoie_dir(S_description);