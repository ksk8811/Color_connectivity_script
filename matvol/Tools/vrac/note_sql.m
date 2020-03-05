
%ch = mysql('open','tac','cenir','pschitt')
ch = mysql('open','prepost','cenir','pschitt')
ch = mysql('open','localhost','cenir','pschitt')
cc = mysql('use','cenir')
%mysql('status')
mysql('close')

[name dt,def,kk,dd,ee]=mysql('SHOW COLUMNS from ExamSerie');

%total size and nb suj
for k=1:3
    switch k
        case 3
            [as pn at] = mysql(' select sum(fsize),PatientsName,AcquisitionTime from ExamSerie where MachineName like ''Verio'' group by Eid order by AcquisitionTime;');
            col = 'b';
        case 2
            [as pn at] = mysql(' select sum(fsize),PatientsName,AcquisitionTime from ExamSerie where MachineName like ''TrioTim'' group by Eid order by AcquisitionTime;');
            col ='g'
        case 1
            [as pn at] = mysql(' select sum(fsize),PatientsName,AcquisitionTime from ExamSerie group by Eid order by AcquisitionTime;');
            col ='k'
    end
    
    as = as./1024./1024./1024; %Gb
    tn = datenum(at); atmonth = datestr(tn,29);atmonth = atmonth(:,1:7);
    %     [a b c]  = unique(atmonth,'rows');
    %     clear cumsum_month_suj cumsum_month_fs
    %     for k=1:length(b)
    %         indm = find(c==k);    cumsum_month_suj(k) = length(indm);    cumsum_month_fs(k)  = mean(as(indm));
    %     end
    %     tnmont = datenum( atmonth(b,:)  )
    %
    %     figure(1)
    %     subplot(2,1,1); hold on
    %     %[AX,H1,H2] = plotyy(x,y1,x,y2,'plot'
    %     plot(tnmont,cumsum_month_suj,col);datetickzoom('x',12);ylabel('nb suj per month');
    %     subplot(2,1,2); hold on
    %     plot(tnmont,cumsum_month_fs,col);datetickzoom('x',12);ylabel('exam Size (GB) per month');
    %
    %version avec fenetre glissante
    clear cumsum_month_suj cumsum_month_fs ind
    tmin=min(tn);tmax= addtodate(max(tn),-1,'month');
    timevec = tmin; timevec2 = addtodate(timevec(1),7,'day');
    while timevec(end)<tmax
        timevec(end+1) = addtodate(timevec(end),2,'day'); timevec2(end+1) = addtodate(timevec(end),1,'month');
    end
    for kk=1:length(timevec)
        ind{kk} = find(tn>=timevec(kk) & tn<=timevec2(kk));
    end
    for kk=1:length(ind)
        cumsum_month_suj(kk) = length(ind{kk});    cumsum_month_fs(kk)  = mean(as(ind{kk}));
    end
    
    figure(1)
    subplot(2,1,1); hold on
    %[AX,H1,H2] = plotyy(x,y1,x,y2,'plot'
    plot((timevec+timevec2)/2,cumsum_month_suj,col);datetickzoom('x',12);ylabel('nb suj per month');
    subplot(2,1,2); hold on
    plot((timevec+timevec2)/2,cumsum_month_fs,col);datetickzoom('x',12);ylabel('exam Size (GB) per month');
    
    
    figure(3)
    subplot(2,2,1);hold on; plot(tn,1:length(tn),col);datetickzoom('x',12);ylabel('nb Suj');
    subplot(2,2,2);hold on; plot(tn,as,col);datetickzoom('x',12);ylabel('exam Size (GB)');
    subplot(2,2,3);hold on; plot(tn,cumsum(as),col);datetickzoom('x',12);ylabel('exam cum Exam Size');
    
end



cmd = 'select ExamName, count(PatientsName) as nbs from exam group by ExamName order by nbs;';
[a b] = mysql(cmd);


%Result vbm8
[gv wv cv resp] = mysql(' select  vbmgrayvol, vbmwhitevol , vbmcsfvol , dir_path from results_anat where status=1;');
indw=wv<300 | wv>800;
ff=get_subdir_regex_files(get_parent_path(resp(indw)),'^s');
do_fsl_slicer(ff,'/home/romain/tmp/fig')

%check if exist in DB
s=get_subdir_regex('/export/dataCENIR/dicom/nifti_proc','.*','.*','.*');
vb=get_subdir_regex(s,'vbm');
[pp proto suj ser vv] = get_parent_path(vb,4);

%check based on dicom dir nam but different form nifti raw because S08 S8 and change in dicom fields
for k=1:length(suj)
    dicpath{k} =fullfile('/export/dataCENIR/dicom/dicom_raw/',proto{k},suj{k});
end
for k=1:length(ser)
    cmd = sprintf('select Sid,SeqType from ExamSerie where dicom_dir like ''%s'' and dicom_sdir like ''%s''  ',...
        dicpath{k},ser{k});
    [a st] = mysql(cmd);
    if length(a)~=1
        fprintf('found %d serie for k=%d\n',length(a),k);
    else
        seqtype{k}=st{1};
    end
    
end

%check based on name ... not unique

[date sujname] = split_cell(suj,'_',3);
date = replace_str_from_cell_list(date,'_','-');
[sernum sername] = split_cell(ser,'_',1);
[ss sernum]= split_cell(sernum,'S',1);
sernum = str2num(char(sernum))   ;

[sujname exanum] = split_cell(sujname,'_E','end');
%argg remove false exanum
for k=1:length(exanum)
    if isempty(str2num(exanum{k}))
        if ~isempty(exanum{k})
            sujname{k} = [sujname{k} '_E' exanum{k} ];
        end
        exanum{k} = 1;
    else
        exanum{k}=str2num(exanum{k});
    end
end

for k=1:length(ser)
    
    
    %    cmd = sprintf('select Sid from ExamSerie where ExamName like ''%s'' and PatientsName like ''%s'' and substr(AcquisitionTime,1,10) like ''%s'' and Sname like ''%s'' and SNumber like ''%d'' and ExamNum like ''%d'' ',...
    %        proto{k},sujname{k},date{k},sername{k},sernum(k),exanum{k});
    cmd = sprintf('select Sid,SeqType from ExamSerie where ExamName like ''%s'' and PatientsName like ''%s%%'' and substr(AcquisitionTime,1,10) like ''%s'' and Sname like ''%s'' and SNumber like ''%d''  ',...
        proto{k},sujname{k},date{k},sername{k},sernum(k));
    [a st] = mysql(cmd);
    
    if length(a)==0
        cmd = sprintf('select Sid,SeqType from ExamSerie where ExamName like ''%s'' and PatientsName like ''%s%%''  and Sname like ''%s'' and SNumber like ''%d''  ',...
            proto{k},sujname{k},sername{k},sernum(k));
        [a st] = mysql(cmd);
        if length(a)==1
            fprintf('date pbr for k=%d',k);
        end
    end
    
    if length(a)~=1
        fprintf('found %d serie for k=%d\n',length(a),k);
    end
    seqtype{k}=st{1};
    
end



%select count(*) as nbs from serie  group by ExamRef ;'
% select count(*) from exam;'

%trouver une ligne d'exam sans Serie
select Eid from exam as e left join serie as s on e.Eid=s.ExamRef where s.ExamRef is null;

%anat scan
select distinct SeqType from ExamSerie;
cc='select distinct SeqName2 from ExamSerie where SeqName2 like ''%Customer%'';'
seqname=mysql(cc)
cc='select distinct SeqName2 from ExamSerie where SeqName2 like ''%Customer%'' and SeqName2 like ''%eja%'';'
seq_eja=mysql(cc)
seq_mrsdiff = mysql('select distinct SeqName2 from ExamSerie where SeqName2 like ''%Customer%'' and SeqName2 like ''%svs_DW%''')
seq_MB= mysql('select distinct SeqName2 from ExamSerie where SeqName2 like ''%Customer%'' and SeqName2 like ''%mbep%''')

seq_rest = mysql('select distinct SeqName2 from ExamSerie where SeqName2 like ''%Customer%'' and SeqName2 not like ''%eja%'' and SeqName2 not like ''%svs_DW%'' ')




%%%%%%%%%%%%%%%%%%%SEQUENCE
reg_seqnam={'mp2rage','UTE','esolve','advdiff','vfl_wip', 'eja' , {'svs_DW','svs_MAGIC','svs_se_fb_','svs_13delay'} , 'mbep', ...
    {'arfi','ARFI','HIFU','EPI_Nick_3D','ep2d_diff_cenir_2D'},'z-shim',{'Ptk','stejskal','epi_highresol'},...
    'pcasl','despot','ep2d_bold_multiecho_WIP','ep3d_bold_multiecho_3D','slicetrig','sead_uzay',{'fid_aim','fid_BISTRO'},'T1r_T2r','_diff_2drf',{'map_397','gre_cenir','sgstepi_'}}
reg_pool = {'WIP mp2rage','WIP UTE','WIP_dif resolve', 'WIP_diff','WIP vfl Double IR','spectro_mineapolis','franscescaDW','MB_mineapolis','HIFU arfi', 'Zshim',...
    'C2Pptk','C2P pcasl','C2Pdespot','WIP multiecho epi2D from poser (mathieu) ','C2P 3D epi multiecho from poser (mathieu) ','C2p slice triger','sead_mineapolis_biosca','spectrop phosphore',...
    'T2 T2 rho','diff moel C2P??','b1map de neurospin ? et autre test'}

%fff=fopen('sequence_db.txt','w')
%ccini = 'select distinct SeqName2 from ExamSerie where  SeqName2 like ''%Customer%'' ';
fff=fopen('sequence_proto_db.txt','w')
ccini = 'select ExamName, count(*), max(AcquisitionTime) from ExamSerie where  SeqName2 like ''%Customer%'' ';

%mysql> select    SName, ExamName , count(*) from ExamSerie where SeqName2 like '%tkSmsVB13ADwDualSpinEchoEpi_%' group by  ExamName ,SeqName2;

for k=1:length(reg_seqnam)
    if ~iscell(reg_seqnam{k})
        arg = reg_seqnam(k);
    else
        arg=reg_seqnam{k};
    end
    cc=sprintf(' ( SeqName2 like ''%%%s%%'' ',arg{1});
    ccr=sprintf(' ( SeqName2 not like ''%%%s%%'' ',arg{1});
    
    for kk=2:length(arg)
        cc=sprintf('%s OR SeqName2  like ''%%%s%%'' ',cc,arg{kk});
        ccr=sprintf('%s AND SeqName2 not like ''%%%s%%'' ',ccr,arg{kk});
    end
    
    cc =  sprintf('%s and %s ) group by ExamName',ccini,cc);
    [Exaname nbexam acqT]=mysql(cc);
    
    fprintf(fff,'\n*********************************************************************************\n');
    fprintf(fff,'Seq name for %s\n',reg_pool{k});
    for nn=1:length(Exaname)
    fprintf (fff,'%s \t\t nb = %d \t\t  last Acq %s\n',Exaname{nn},nbexam(nn),datestr(acqT(nn),29));
    end
    
    if k==1
        ccrest = sprintf('%s and %s ) ',ccini,ccr);
    else
        ccrest = sprintf('%s and %s ) ',ccrest,ccr);
    end
end
ccrest = sprintf('%s group by ExamName',ccrest);
[msg nb acqt] = mysql(ccrest);
fprintf(fff,'\nSequences restantes \n')
fprintf (fff,'%s\n',msg{:});
fclose(fff);
char(msg)

%select proto by date of last exam
select ExamName, max(AcquisitionTime) as tt , count(*) from exam  group by ExamName order by tt;
[pr ma nb] = mysql('select ExamName, max(AcquisitionTime) as tt , count(*) from exam  group by ExamName order by tt;')

%find those in dicom_raw
for k=1:length(pr)
    if str2num(ma{k}(1:4))<2014
        
        exa = get_subdir_regex('/nasDicom/dicom_raw',['^' pr{k} '$'],'^2');
        nbexa(k) = length(exa);
        exam{k} = pr{k};
    end
end
