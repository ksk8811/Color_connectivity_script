function hdr=read_spectro_header(charfilecontent)

hdr.tr = (0.001 .* FindAndGet(charfilecontent,'alTR[0]'));
hdr.te = (0.001 .* FindAndGet(charfilecontent,'alTE[0]'));
%hdr.ti = (0.001 .* FindAndGet(charfilecontent,'alTI[0]'));
hdr.flip_angle = FindAndGet(charfilecontent,'adFlipAngleDegree[0]');
hdr.no_averages = FindAndGet(charfilecontent,'lAverages');
hdr.synthesizer_frequency = (0.000001 .* FindAndGet(charfilecontent,'sTXSPEC.asNucleusInfo[0].lFrequency'));
hdr.total_meas_time = (FindAndGet(charfilecontent,'lTotalScanTimeSec'));

hdr.spectra_nb_pts = (FindAndGet(charfilecontent,'sSpecPara.lVectorSize'));

hdr.remove_oversampling = FindAndGet(charfilecontent,'sSpecPara.ucRemoveOversampling'); 

if isempty(hdr.remove_oversampling)
    remove_oversampling = 1; 
else
    remove_oversampling = hdr.remove_oversampling;
end
  
hdr.dwell_time = (remove_oversampling + 1) * 0.001 * (FindAndGet(charfilecontent,'sRXSPEC.alDwellTime[0]'));
hdr.spectral_width = 1 / (hdr.dwell_time * 1e-6);
try
  hdr.nucleus_offset_frequency = FindAndGet(charfilecontent,'sSpecPara.dDeltaFrequency');
    if (isempty(hdr.nucleus_offset_frequency))
      hdr.nucleus_offset_frequency = 0;
    end
catch
  hdr.nucleus_offset_frequency = 0;
end

%supposed always fixed
hdr.nucleus_offset_frequency = 4.67;   % set on default H2O line frequency
hdr.frequency_format = -1;

%deduced
hdr.data_bytes_size = hdr.spectra_nb_pts * 2 * 4;
