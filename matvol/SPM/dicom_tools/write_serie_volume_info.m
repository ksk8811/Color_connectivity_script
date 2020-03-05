function write_serie_volume_info(fid,hh)

if ~isfield(hh,'InversionTime'), hh.InversionTime=[];end
if ~isfield(hh,'PhaseEncodingDirection'),      hh.PhaseEncodingDirection = '?';end
if ~isfield(hh,'ScanOptions'),      hh.ScanOptions = 'none';end
if ~isfield(hh,'SpacingBetweenSlices'),
    if ~isfield(hh,'SliceThickness')
        fprintf('arg no slice thickness just return')
        return;
    else
        hh.SpacingBetweenSlices=hh.SliceThickness;
    end
end
if ~isfield(hh,'NumberofAverages') , hh.NumberofAverages=0;end
if ~isfield(hh,'NumberofPhaseEncodingSteps'), hh.NumberofPhaseEncodingSteps=0;end
if ~isfield(hh,'PercentPhaseFieldofView'), hh.PercentPhaseFieldofView=0;end
    
sof_ver = hh.SoftwareVersions ;

if strcmp(sof_ver,'syngo MR B13 4VB13A ') || strcmp(sof_ver,'syngo MR B15') ||  strcmp(sof_ver,'syngo MR B17')
    
    if isempty(hh.CSASeriesHeaderInfo(42).item)
        hh.PATmod = 'none';
    else
        hh.PATmod =  hh.CSASeriesHeaderInfo(42).item(1).val;
    end
    
    if ~isempty(hh.CSAImageHeaderInfo(79).item)
        hh.pixBW =  hh.CSAImageHeaderInfo(79).item(1).val;
    else
        hh.pixBW = '?';
    end
    
    if isfield(hh,'Private_0051_1016'),hh.processing = hh.Private_0051_1016; else hh.processing ='?';end
    
    str_csa= hh.CSASeriesHeaderInfo(46).item(1).val;
    if ~isstr(str_csa)
        %str_csa=string(str_csa);
        str_csa=char(str_csa);
    end
    hh.GradientMode = hh.CSASeriesHeaderInfo(47).item(1).val;
    hh.CoilString   =  hh.CSASeriesHeaderInfo(41).item(1).val;
    hh.FlowCompensation =  hh.CSASeriesHeaderInfo(48).item(1).val;
    hh.transmitterCalibration = hh.CSASeriesHeaderInfo(3).item(1).val;
    
    if isfield(hh,'Private_0051_1013'), hh.Resper_str = hh.Private_0051_1013; else hh.Resper_str = '?';end
    if isfield(hh,'Private_0051_100e'), hh.orientation_str = hh.Private_0051_100e; else hh.orientation_str = '?';end
    
else
    hh.PATmod = '?';
    hh.pixBW = '?';
    hh.processing = '?';
    hh.GradientMode = '?';
    hh.CoilString   = '?';
    hh.FlowCompensation ='?';
    hh.transmitterCalibration ='?';
    hh.Resper_str = '?';
    hh.orientation_str = '?';
    str_csa='';
end

warning('off')

fprintf(fid,'Type %s (%s) Aquisition %s ',hh.CSAImageHeaderType,hh.ImageType,hh.MRAcquisitionType);
fprintf(fid,'Sequence %s (%s) (%s) ',hh.SequenceName,hh.ScanningSequence,hh.SequenceVariant);
fprintf(fid,'Versions:%s\n',hh.SoftwareVersions);

fprintf(fid,'TR: %6.2f ' ,hh.RepetitionTime);
fprintf(fid,'TE: %6.2f ' ,hh.EchoTime);
fprintf(fid,'FlipAngle: %6.2f (variable %s) ',hh.FlipAngle,hh.VariableFlipAngleFlag);
fprintf(fid,'NEX: %6.2f ' ,hh.NumberofAverages);
fprintf(fid,'BW: %d ' ,hh.PixelBandwidth);
fprintf(fid,'TI %d\n',hh.InversionTime);


fprintf(fid,'PhaseEcodingDirection: %s (%d step) ',hh.PhaseEncodingDirection,hh.NumberofPhaseEncodingSteps);
fprintf(fid,'IPAT %s ', hh.PATmod);


ind=findstr(str_csa,'sPat.lRefLinesPE');
if ~isempty(ind)
    inde = findstr(str_csa(ind:end),'='); ind = ind+inde(1);
    indn =  findstr(str_csa(ind:end),'sPat');
    ipatline = str2num(str_csa(ind:(ind+indn(1)-2)));
    fprintf(fid,' %d line ',ipatline);
end

fprintf(fid,'ScanOption %s ',hh.ScanOptions);
fprintf(fid,'Processing %s\n',hh.processing);


fprintf(fid,'Angio %s ',hh.AngioFlag);
fprintf(fid,'EchoTrainLength %d (num : %d) ',hh.EchoTrainLength,hh.EchoNumbers);

fprintf(fid,'%s : %s  ','GradientMode',hh.GradientMode);
fprintf(fid,'%s : %s  ','FlowCompensation',hh.FlowCompensation);
fprintf(fid,'%s : %s  ','CoilString',hh.CoilString);
fprintf(fid,'%s : %s  ','transmitterCalibration',hh.transmitterCalibration);


fprintf(fid,'ImagingFreq %6.9f  ',hh.ImagingFrequency);
fprintf(fid,'SAR:%6.3f ',hh.SAR);

if isstr(hh.pixBW)
    fprintf(fid,'BandwidthPerPixelPhaseEncode : %s  ', hh.pixBW);
else
    fprintf(fid,'BandwidthPerPixelPhaseEncode : %f  ', hh.pixBW);
end
fprintf(fid,'PixelBandwidth %d\n',hh.PixelBandwidth);

%       hh.CSAImageHeaderInfo(22).name %DiffusionGradientDirection
%        hh.CSAImageHeaderInfo(25)   DiffusionDirectionality

dim = read_dim_from_mosaic(hh);
if dim(3)==1 % it was probably not a mosaic
    ind=findstr(str_csa,'sAdjData.sAdjVolume.dThickness');
    if ~isempty(ind)
        inde = findstr(str_csa(ind:end),'='); ind = ind+inde(1);
        indn =  findstr(str_csa(ind:end),'sAdjData');
        dim(3) = str2num(str_csa(ind:(ind+indn(1)-2)));
    end
    
    %find Slice oversampling if exist
    ind=findstr(str_csa,'sKSpace.dSliceOversamplingForDialog');
    if ~isempty(ind)
        inde = findstr(str_csa(ind:end),'='); ind = ind+inde(1);
        indn =  findstr(str_csa(ind:end),'sKSpace');
        slice_over_samp = str2num(str_csa(ind:(ind+indn(1)-2)))*100;
    end
end

fprintf(fid,'Matrix: [%d %d %d] (Acquiere: [%d %d]) Pixel size [%3.4f %3.4f %3.4f ou %3.4f]\n',dim(1),dim(2),dim(3),hh.Rows,hh.Columns,hh.PixelSpacing(1),hh.PixelSpacing(2),hh.SliceThickness,hh.SpacingBetweenSlices);

fprintf(fid,'phase FOV %d PercentSampling %d ',hh.PercentPhaseFieldofView,hh.PercentSampling);
if exist ('slice_over_samp'), fprintf(fid,'SliceOversampling %.0f %% ',slice_over_samp); end

fprintf(fid,'Repere %s ',hh.Resper_str);

fprintf(fid,'Orientation %s : [%.4f,%.4f,%.4f,%.4f,%.4f,%.4f] \n',hh.orientation_str,hh.ImageOrientationPatient(1),hh.ImageOrientationPatient(2),hh.ImageOrientationPatient(3),hh.ImageOrientationPatient(4),hh.ImageOrientationPatient(5),hh.ImageOrientationPatient(6));

warning('on');

