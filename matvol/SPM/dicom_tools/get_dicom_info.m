function hhout = get_dicom_info(ff)
%function  hhout = get_dicom_info(ff)
% function to extract the dicom parameters of a liste of dicom files and write it to a csv file
% ff list of file
%

if isstruct(ff{1})
    % this is already the spm_dicom_headers structure
    hhh = ff;
else
    hhh = spm_dicom_headers(char(ff));
end


for i=1:size(hhh,2)
    
    hh = hhh{1,i};
    
    %     cmd = sprintf('strings %s |grep tCoilID',hh.Filename);
    %     [a,b] = unix(cmd);
    %     ii=findstr(b,'""');
    %     if ~isempty(ii)
    %         hh.coilstr =  b((ii(1)+2):(ii(2)-1));
    %     end
    
%     %%%% PHASE DIRECTION
%     %cmd =  sprintf('strings %s |grep sAdjData.sAdjVolume.dInPl',hh.Filename);
%     cmd =  sprintf('strings %s |grep "asSlice\\[0\\].dInPlaneRot"',hh.Filename);
%     [a,b] = unix(cmd);
%     ii=findstr(b,'=');
%     
%     if ~isempty(ii)
%         if length(ii)>2
%             jj = ii(2)-ii(1)-1;
%             hh.phase_angle =  b((ii(1)+2):jj);
%         else
%             
%             hh.phase_angle =  b((ii(1)+2):end-1);
%         end
%     end
    %%%% sequence name
    %     cmd =  sprintf('strings %s |grep tSequenceFileName',hh.Filename);
    %     [a,b] = unix(cmd);
    %     ii=strfind(b,'=');
    %     if ~isempty(ii)
    %         hh.SequenceSiemensName = nettoie_dir(b(ii+1:end));
    %     end
    
    
    
    %%%%  Nbr of concatenation
%     cmd = sprintf('strings %s |grep sSliceArray.lConc',hh.Filename);
%     [a,b] = unix(cmd);
%     ii=findstr(b,'=');
%     if ~isempty(ii)
%         hh.concatenation = b(ii(1)+2:end-1);
%     else
%         hh.concatenation='?';
%     end
    
    %Verification des champs
    if ~isfield(hh,'StudyDescription'),hh.StudyDescription = '?';end
    if ~isfield(hh,'SeriesNumber'),hh.SeriesNumber = '?';end
    if ~isfield(hh,'SeriesDescription'),hh.SeriesDescription = 'serie';end
    if ~isfield(hh,'StudyID'),hh.StudyID = '?';end
    if ~isfield(hh,'SeriesTime'),hh.SeriesTime = hh.StudyTime; end
    if ~isfield(hh,'PatientsName'),hh.PatientsName = '?';end; if isfield(hh,'PatientName'), hh.PatientsName =hh.PatientName;end
    if ~isfield(hh,'PatientsAge'),hh.PatientsAge = '?';end;   if isfield(hh,'PatientAge'), hh.PatientsAge =hh.PatientAge;end
    if ~isfield(hh,'PatientsSex'),hh.PatientsSex = '?';end;    if isfield(hh,'PatientSex'), hh.PatientsSex =hh.PatientSex;end
    if ~isfield(hh,'PatientsWeight'),hh.PatientsWeight = '?';end; if isfield(hh,'PatientWeight'), hh.PatientsWeight =hh.PatientWeight;end
    if ~isfield(hh,'Private_0051_100a'),hh.Private_0051_100a = '?';end
    if ~isfield(hh,'InversionTime'),hh.InversionTime='?';end
    if ~isfield(hh,'PhaseEncodingDirection'),hh.PhaseEncodingDirection = '?';end
    if ~isfield(hh,'ScanOptions'),hh.ScanOptions = 'none';end
    if ~isfield(hh,'MRAcquisitionType'),hh.MRAcquisitionType = '?';end
    if ~isfield(hh,'SequenceName'),hh.SequenceName = '?';end
    if ~isfield(hh,'SpacingBetweenSlices'),
        if ~isfield(hh,'SliceThickness'),hh.SliceThickness = '?';else hh.SpacingBetweenSlices=hh.SliceThickness;end
    end
    if ~isfield(hh,'ScanningSequence'),hh.ScanningSequence = '?';end
    if ~isfield(hh,'SequenceVariant'),hh.SequenceVariant = '?';end
    if ~isfield(hh,'RepetitionTime'),hh.RepetitionTime = '?';end
    if ~isfield(hh,'EchoTime'),hh.EchoTime = '?';end
    if ~isfield(hh,'FlipAngle'),hh.FlipAngle = '?';end
    if ~isfield(hh,'VariableFlipAngleFlag'),hh.VariableFlipAngleFlag = '?';end
    if ~isfield(hh,'NumberofAverages'),hh.NumberofAverages = '?';end
    if ~isfield(hh,'PixelBandwidth'),hh.PixelBandwidth = '?';end
    if ~isfield(hh,'InversionTime'),hh.InversionTime = '?';end
    if ~isfield(hh,'PhaseEncodingDirection'),hh.PhaseEncodingDirection = '?';end
    if ~isfield(hh,'NumberofPhaseEncodingSteps'),hh.NumberofPhaseEncodingSteps = '?';end
    if ~isfield(hh,'CSAImageHeaderType'),hh.CSAImageHeaderType = '?';end
    if ~isfield(hh,'CSAImageHeaderType'),hh.CSASeriesHeaderInfo = '?';end
    if ~isfield(hh,'SoftwareVersions'),hh.SoftwareVersions = '?';end
    if ~isfield(hh,'ScanOptions'),hh.ScanOptions = '?';end
    if ~isfield(hh,'processing'),hh.processing = '?';end
    if ~isfield(hh,'AngioFlag'),hh.AngioFlag = '?';end
    if ~isfield(hh,'EchoTrainLength'),hh.EchoTrainLength = '?';end
    if ~isfield(hh,'EchoNumbers'),hh.EchoNumbers = '?';end
    if ~isfield(hh,'GradientMode'),hh.GradientMode = '?';end
    if ~isfield(hh,'FlowCompensation'),hh.FlowCompensation = '?';end
    if ~isfield(hh,'CoilString'),hh.CoilString = '?';end
    if ~isfield(hh,'transmitterCalibration'),hh.transmitterCalibration = '?';end
    if ~isfield(hh,'ImagingFrequency'),hh.ImagingFrequency = '?';end
    if ~isfield(hh,'SAR'),hh.SAR = '?';end
    if ~isfield(hh,'pixBW'),hh.pixBW = '?';end
    if ~isfield(hh,'PixelBandwidth'),hh.PixelBandwidth = '?';end
    if ~isfield(hh,'Rows'),hh.Rows = '?';end
    if ~isfield(hh,'Columns'),hh.Columns = '?';end
    if ~isfield(hh,'PixelSpacing'),hh.PixelSpacing = '?';end
    if ~isfield(hh,'SliceThickness'),hh.SliceThickness = '?';end
    if ~isfield(hh,'SpacingBetweenSlices'),hh.SpacingBetweenSlices = '?';end
    if ~isfield(hh,'PercentPhaseFieldofView'),hh.PercentPhaseFieldofView = '?';end
    if ~isfield(hh,'PercentSampling'),hh.PercentSampling = '?';end
    if ~isfield(hh,'Resper_str'),hh.Resper_str = '?';end
    if ~isfield(hh,'ImageOrientationPatient'),hh.ImageOrientationPatient =[0 0 0 0 0 0];end
    if ~isfield(hh,'ImagePositionPatient'),hh.ImagePositionPatient=[0 0 0 ];end
    
    hh.PATmod = '?';
    hh.pixBW = '?';
    hh.processing = '?';
    hh.GradientMode = '?';
    hh.CoilString   = '?';
    hh.FlowCompensation ='?';
    hh.transmitterCalibration ='?';
    hh.Resper_str = '?';
    hh.orientation_str = '?';
    hh.dim = [0 0 0];
    
    hh.coilstr = '?';
    hh.phase_angle = '?';
    hh.SequenceSiemensName = '?';
    hh.concatenation='?';
    hh.Spoil_grad='?';
    hh.RF_phase='?';
    hh.flReferenceAmplitude ='?';
    hh.fft_scale='?';
    hh.Gain='?';
    
    sof_ver = hh.SoftwareVersions ;
    
    if strcmp(sof_ver,'syngo MR B13 4VB13A ') || strcmp(sof_ver,'syngo MR B15') || strcmp(sof_ver,'syngo MR B17')
        
        if isfield(hh,'CSASeriesHeaderInfo')
            
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
            if ~isstr(str_csa);
                str_csa=char(str_csa);
            end
            
            hh.GradientMode = hh.CSASeriesHeaderInfo(47).item(1).val;
            hh.CoilString   =  hh.CSASeriesHeaderInfo(41).item(1).val;
            hh.FlowCompensation =  hh.CSASeriesHeaderInfo(48).item(1).val;
            hh.transmitterCalibration = hh.CSASeriesHeaderInfo(3).item(1).val;
            
            if isfield(hh,'Private_0051_1013'), hh.Resper_str = hh.Private_0051_1013; else hh.Resper_str = '?';end
            if isfield(hh,'Private_0051_100e'), hh.orientation_str = hh.Private_0051_100e; else hh.orientation_str = '?';end
            
            dim = read_dim_from_mosaic(hh);
            if dim(3)==1 % it was probably not a mosaic
                ind=findstr(str_csa,'sAdjData.sAdjVolume.dThickness');
                if ~isempty(ind)
                    inde = findstr(str_csa(ind:end),'='); ind = ind+inde(1);
                    indn =  findstr(str_csa(ind:end),'sAdjData');
                    dim(3) = str2num(str_csa(ind:(ind+indn(1)-2)));
                end
            end
            hh.dim = dim;
            
            %tSequenceFileName
            ind=strfind(str_csa,'tSequenceFileName');
            if ~isempty(ind)
                inde = findstr(str_csa(ind:end),'='); ind = ind(1)+inde(1);
                ii=findstr(str_csa(ind:end),'""');
                val = str_csa(ind+[ii(1)+2:ii(2)-2]);
                hh.SequenceSiemensName =  nettoie_dir(val);
            end
            
            %%%% sequence name
            ind=strfind(str_csa,'tCoilID');
            if ~isempty(ind)
                inde = findstr(str_csa(ind:end),'='); ind = ind(1)+inde(1);
                ii=findstr(str_csa(ind:end),'""');
                val = str_csa(ind+[ii(1)+1:ii(2)-2]);
                hh.coilstr =  nettoie_dir(val);
            end
            %%%% concatenation
            ind=strfind(str_csa,'sSliceArray.lConc');
            if ~isempty(ind)
                inde = findstr(str_csa(ind:end),'='); ind = ind(1)+inde(1);
                ii=findstr(str_csa(ind:end),char(10));
                val = str_csa(ind+[1 : ii(1)-2]);
                hh.concatenation =  (val);
            end
            %%%% phase direction to be test
            ind=strfind(str_csa,'sAdjData.sAdjVolume.dInPl');
            if ~isempty(ind)
                inde = findstr(str_csa(ind:end),'='); ind = ind(1)+inde(1);
                ii=findstr(str_csa(ind:end),char(10));
                val = str_csa(ind+[1 : ii(1)-2]);
                hh.phase_angle =  (val);
            end
            
            %%%% reference voltage
            ind=strfind(str_csa,'flReferenceAmplitude');
            if ~isempty(ind)
                inde = findstr(str_csa(ind:end),'='); ind = ind(1)+inde(1);
                ii=findstr(str_csa(ind:end),char(10));
                val = str_csa(ind+[1 : ii(1)-2]);
                hh.flReferenceAmplitude =  (val);
            end
            %%%% reference fft scale 
            ind=strfind(str_csa,'flFactor');
            if ~isempty(ind)
                inde = findstr(str_csa(ind:end),'='); ind = ind(1)+inde(1);
                ii=findstr(str_csa(ind:end),char(10));
                val = str_csa(ind+[1 : ii(1)-2]);
                hh.fft_scale =  (val);
            end
            %%%% Gain
            ind=strfind(str_csa,'bGainValid');
            if ~isempty(ind)
                inde = findstr(str_csa(ind:end),'='); ind = ind(1)+inde(1);
                ii=findstr(str_csa(ind:end),char(10));
                val = str_csa(ind+[1 : ii(1)-2]);
                hh.Gain =  (val);
            end
            
%     %%%% PHASE DIRECTION
%     %cmd =  sprintf('strings %s |grep sAdjData.sAdjVolume.dInPl',hh.Filename);
%     cmd =  sprintf('strings %s |grep "asSlice\\[0\\].dInPlaneRot"',hh.Filename);
%     [a,b] = unix(cmd);
%     ii=findstr(b,'=');
%     
%     if ~isempty(ii)
%         if length(ii)>2
%             jj = ii(2)-ii(1)-1;
%             hh.phase_angle =  b((ii(1)+2):jj);
%         else
%             
%             hh.phase_angle =  b((ii(1)+2):end-1);
%         end
%     end
            
            
            if findstr(hh.SequenceSiemensName,'CustomerSeq_pssfp')
                dd=dicominfo(hh.Filename);
                [img, ser, mrprot] = parse_siemens_shadow(dd);
                if length( mrprot.sWiPMemBlock.adFree)>7
                    hh.Spoil_grad =mrprot.sWiPMemBlock.adFree(8);
                else hh.Spoil_grad = 0; end
                if length(mrprot.sWiPMemBlock.alFree)>5
                    hh.RF_phase = mrprot.sWiPMemBlock.alFree(6);
                else hh.RF_phase = 0; end
            end
            
            
        else
            str_csa='';
            dim = [0 0 0];
        end
    end
    
    hhout{i} = hh;
end

