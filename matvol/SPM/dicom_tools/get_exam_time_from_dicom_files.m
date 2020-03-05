rootdir = '/nasDicom/dicom_raw/';
%rootdir = '/home/romain/data/spectro';

proto_re = {'PROTO_DEC_EEG'};
sujet_re = {'ujet'};
fonc_re  = {'.*'};


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
proto = get_subdir_regex(rootdir,proto_re);
subjects=get_subdir_regex(proto,sujet_re);
funcdirs={};


for n=1:length(subjects)
  
  funcdirs{n} =get_subdir_regex(subjects{n},fonc_re);

end

P={};hdr={};
for n=1:length(subjects)

  pp = dir(funcdirs{n}{1});
  P{end+1} = fullfile(funcdirs{n}{1},pp(3).name);
  hdr(end+1) = spm_dicom_headers(P{end});
  
  pp = dir(funcdirs{n}{end});
  P{end+1} = fullfile(funcdirs{n}{end},pp(end).name);
  hdr(end+1) = spm_dicom_headers(P{end});
  
  if findstr(hdr{end}.CSAImageHeaderType,'IMAGE NUM 4')
    
    hdr{end}.total_scan_time = get_TA_from_desc([hdr{end}.StudyDescription,hdr{end}.SeriesDescription],[hdr{end}.PatientsName,'_E',hdr{end}.StudyID]);
  
  else
    
    [fid, dcmInfo] = spec_read(P{end});
    [img, ser, mrprot] = parse_siemens_shadow(dcmInfo);
    
    hdr{end}.total_scan_time =  mrprot.lTotalScanTimeSec
  end
end

%P=char(P);
%hdr=spm_dicom_headers(P);

ff=fopen('info.csv','w')
fprintf(ff,'Name , exam num,date,exam_start_time ,first_acq_time  ,  last_acq_time  ,  exam_duration (mm)\n');

for k=1:2:length(hdr)
  hh=hdr{k};
  hh2 = hdr{k+1};
  dur = ceil( (hh2.AcquisitionTime + hh2.total_scan_time -  hh.AcquisitionTime)/60 );
              
  [heure,min,sec,ms] = get_time_from_dic_siemens(hh.StudyTime);
  timeStudy = sprintf('%0.2dh%0.2dm%0.2ds',heure,min,sec);

%  [heure,min,sec,ms] = get_time_from_dic_siemens(hh.SeriesTime);
%  timeSeries = sprintf('%0.2dh%0.2dm%0.2ds',heure,min,sec);
%  [heure,min,sec,ms] = get_time_from_dic_siemens(hh2.SeriesTime);
%  timeSeries2 = sprintf('%0.2dh%0.2dm%0.2ds',heure,min,sec);

  [heure,min,sec,ms] = get_time_from_dic_siemens(hh.AcquisitionTime);
  timeAcq = sprintf('%0.2dh%0.2dm%0.2ds',heure,min,sec);

  [heure,min,sec,ms] = get_time_from_dic_siemens(hh2.AcquisitionTime+hh2.total_scan_time );
  timeAcq2 = sprintf('%0.2dh%0.2dm%0.2ds',heure,min,sec);


  fprintf(ff,'%s ,  E%s ,  %s  ,  %s ,   %s ,  %s ,  %d\n',hh.PatientsName,hh.StudyID,datestr(hh.StudyDate),timeStudy,timeAcq,timeAcq2,dur);

end

fclose(ff);
