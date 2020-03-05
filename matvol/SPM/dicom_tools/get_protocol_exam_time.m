function get_protocol_exam_time(proto_re,sujet_re,root_dir,log_filename)
%get_protocol_exam_time(proto_reg,sujet_reg,root_dir,log_filename)
%  proto_reg : mandatory regular expression of the protocol name
%  sujet_reg : optional regular expression of the subject to select
%             if empty or not define : default value '.*' ie all exam
%  root_dir : optional : path to the dir where protocol are 
%             if not define : default value /nasDicom/dicom_raw/
%             other possible value /nasDicom/PROTO_FINI/dicom_raw 
%             or /nasDicom/PROTO_FINI/dicom_raw_ARCHIVED/
%  log_filename : optional default value 'exam_time.csv' if empty no logfile
%
% exemple :
%         get_protocol_exam_time('AFM_SPINE')
%         get_protocol_exam_time('PROTO_MBB_ACC','.*','/nasDicom/PROTO_FINI/dicom_raw/')
%         get_protocol_exam_time('PROTO_MBB_SOCIAL',{'Suj','SUJ'},'/nasDicom/PROTO_FINI/dicom_raw/')
%
% Note this is a minimum estimate of the exam duration because 
% the exam duration is compute as  
% the start time of the last sequence - start time of the first sequence   
% (I do not take into account the duration of the last sequence (duration is not stored in dicom file)

if ~exist('sujet_re'), sujet_re='';end
if ~exist('root_dir'), root_dir = '/nasDicom/dicom_raw/'; end
if ~exist('log_filename'), log_filename = 'exam_time.csv'; end

if isempty(sujet_re), sujet_re='.*';end
if isempty(root_dir), root_dir = '/nasDicom/dicom_raw/'; ;end
  
fonc_re  = {'.*'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
proto = get_subdir_regex(root_dir,proto_re);
subjects=get_subdir_regex(proto,sujet_re);
char(subjects);
funcdirs={};

for n=1:length(subjects)
  funcdirs{n} =get_subdir_regex(subjects{n},fonc_re);
  
  [p,f]=get_parent_path(funcdirs{n}(1));
  if isempty(findstr('S01',f{1}))
    fprintf('warning taking the series creation time order for \t %s\n',p{1})
    funcdirs{n} = get_subdir_regex_order_time(subjects{n},fonc_re);
  end
 
end

if isempty(funcdirs)
  fprintf('no subjects found, check your path')
  return
end


P={};hdr={};
for n=1:length(subjects)

  pp = dir(funcdirs{n}{1});
  P{end+1} = fullfile(funcdirs{n}{1},pp(3).name);
  hdr(end+1) = spm_dicom_headers(P{end});
  
  %Skip certain series name
  [sujpath,serie_name] = get_parent_path(funcdirs{n}(end));
  while ~isempty(findstr(serie_name{1},'DERIVED')) || ~isempty(findstr(serie_name{1},'FA')) ...
            || ~isempty(findstr(serie_name{1},'TRACEW'))|| ~isempty(findstr(serie_name{1},'ADC'))...
            || ~isempty(findstr(serie_name{1},'TENSOR')) ||  ~isempty(findstr(serie_name{1},'REPORT')) ...
            || ~isempty(findstr(serie_name{1},'Report')) ...
    %fprintf('skiping last series (reconstructed)  %s\n',funcdirs{n}{end});
    funcdirs{n}(end) = '';
    [sujpath,serie_name] = get_parent_path(funcdirs{n}(end));

  end
  
  %prend la derniere image de la derniere series
  pp = dir(funcdirs{n}{end});
  P{end+1} = fullfile(funcdirs{n}{end},pp(end).name);
  hdr(end+1) = spm_dicom_headers(P{end});

  while isfield(hdr{end},'DerivationDescription')
    %fprintf('skiping last series (reconstructed) from %s %s\n',hdr{end}.PatientsName,hdr{end}.SeriesDescription)
    funcdirs{n}(end) = '';
    
    pp = dir(funcdirs{n}{end});
    P{end} = fullfile(funcdirs{n}{end},pp(3).name);
    hdr(end) = spm_dicom_headers(P{end});
 
  end
  [aaaa last_series_name(n)] = get_parent_path(funcdirs{n}(end));
  [aaaa first_series_name(n)] = get_parent_path(funcdirs{n}(1));

  if findstr(hdr{end}.CSAImageHeaderType,'IMAGE NUM 4')
    
%    hdr{end}.total_scan_time = get_TA_from_desc([hdr{end}.StudyDescription,hdr{end}.SeriesDescription],[hdr{end}.PatientsName,'_E',hdr{end}.StudyID]);
  
    % lecture du temps de la serie
    % cherche l'info de duree de la sequence dans le header
    % dicom et le converti en seconde
    if isfield(hdr{end},'Private_0051_100a')
      st = hdr{end}.Private_0051_100a;
      if strcmp(st(6),'.')
	scan_time = str2num(st(4:5))+1;
      elseif strcmp(st(6),':')
	scan_time = str2num(st(4:5))*60 + str2num(st(7:8));
      else
	warning('SHOULD NOT HAPPEN CALL ROMAIN') %#ok<WNTAG>
      end
      % recupere le facteur de multiplication si existe
      indd = findstr(st,'*');
      if indd
	multfac = str2num(st(indd+1:end));
      else
	multfac=1;
      end
      % on applique le coefficient multiplicateur pour avoir le
      % temps de la serie.
      scan_time = scan_time*multfac;
                
      %fprintf('last serie %s : %s is %d\n',hdr{end}.ProtocolName,st,scan_time);
      
      hdr{end}.total_scan_time = scan_time; %#ok<AGROW>
    else
      fprintf('WARNING no last series time for %s \n',hdr{end}.Filename)
      hdr{end}.total_scan_time = 0;
    end
  else
    
    [fid, dcmInfo] = spec_read(P{end});
    [img, ser, mrprot] = parse_siemens_shadow(dcmInfo);
    
    hdr{end}.total_scan_time =  mrprot.lTotalScanTimeSec;
  end
end

if ~isempty(log_filename),  do_log=1; else do_log=0, end

if do_log
  ff=fopen(log_filename,'a+');
  fprintf(ff,'\nName , date,exam_start_time ,first_acq_time  , last_acq_time ,  exam_duration (mm),first series name,last_series naume\n');
end

for k=1:length(subjects) %2:length(hdr)
  hh=hdr{2*k-1};
  hh2 = hdr{2*k};
  dur = ceil( (hh2.AcquisitionTime + hh2.total_scan_time -  hh.AcquisitionTime)/60 );
              
  [heure,min,sec,ms] = get_time_from_dic_siemens(hh.StudyTime);
  timeStudy = sprintf('%0.2dh%0.2dm%0.2ds',heure,min,sec);

  [heure,min,sec,ms] = get_time_from_dic_siemens(hh.AcquisitionTime);
  timeAcq = sprintf('%0.2dh%0.2dm%0.2ds',heure,min,sec);

  [heure,min,sec,ms] = get_time_from_dic_siemens(hh2.AcquisitionTime+hh2.total_scan_time );
  timeAcq2 = sprintf('%0.2dh%0.2dm%0.2ds',heure,min,sec);


  fprintf('%s ,  %s  ,  %s ,   %s ,  %s ,duree  %d mn , %s , %s\n',hh.PatientsName,datestr(hh.StudyDate),timeStudy,timeAcq,timeAcq2,dur,first_series_name{k},last_series_name{k});

  if do_log
    fprintf(ff,'%s ,  %s  ,  %s ,   %s ,  %s ,  %d , %s ,%s \n',hh.PatientsName,datestr(hh.StudyDate),timeStudy,timeAcq,timeAcq2,dur,first_series_name{k},last_series_name{k});
  
  end
  
  sdate = datestr(hh.StudyDate,29);
  syear(k) = str2num(sdate(1:4));
  etime(k) = dur;
end

fprintf('\n\n');
if do_log
  fprintf(ff,'\nYear, Nr of sujbjects, Total time (h)\n');
end

[aa ii jj]=unique(syear);
for k=1:length(aa)
  tot_time = sum(etime(jj==k))/60;

  fprintf('Anne %d \t %d sujets \t %.2f heures\n',aa(k),length(find(jj==k)),tot_time)
  if do_log
    fprintf(ff,'%d , %d , %.2f \n',aa(k),length(find(jj==k)),tot_time);
  end

end

if do_log
  fprintf('\nWriting to log file %s \n',fullfile(pwd,log_filename));
  fclose(ff);
end
