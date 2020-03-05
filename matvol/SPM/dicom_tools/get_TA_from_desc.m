function TA = get_TA_from_desc(str,patname)
% give the Acquisition Time in second, givent the study_series_description

TA=0;

switch str
  case 'PROTO^U678_MOTEUR GRE FIELD MAP 3iso'
    TA=67; %1:07
  case 'PROTO^U678_MOTEUR DTI 50 PtkSms TR12'
    TA=648; %10:48
  case 'PROTO^U678_MOTEUR DTI 50 PtkSms TR12_TRACEW '
    TA=648;
  case 'PROTO^U678_MOTEUR run6'
    TA=462;
%  case {'PROTO^GENEPARKDTI_axial_34dir_2mm_p2_FA ','PROTO^GENEPARKDTI_axial_34dir_2mm_p2_TRACEW '}
%    TA=600r;
%  case 'PROTO^GENEPARKfMRI 2'
%    TA=10r;
%  case 'PROTO^GENEPARKT2_EPI_SE_TE99'
%    TA=10r;
  case 'PROTO^SPECTRO_DYSTlocalizer multislice 3'
    TA=20;
  case 'PROTO^SPECTRO_DYSTT2 TSE TRA_short_short'
    TA=40;
  case 'PROTO^SPECTRO_DYSTT2 TSE TRA'
    TA=70;
  case 'PROTO^DEC_EEG t1mpr SAG NSel S176 '
    TA=517;
  otherwise
    warning(' do not find TA for sujet %s from ser  <%s> \n',patname,str);

end


