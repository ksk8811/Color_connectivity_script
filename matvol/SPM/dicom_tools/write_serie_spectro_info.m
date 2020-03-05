function write_serie_spectro_info(fid,hh)
if isfield(hh,'Private_0029_1120')
  if ischar(hh.Private_0029_1120)
   
    charcontent = char(hh.Private_0029_1120);
    hdr_str = read_spectro_header(charcontent);

    fprintf(fid,'Type %s (%s)  Sequence ?\n',hh.CSAImageHeaderType,hh.ImageType);
    fprintf(fid,'TR: %6.2f  TE: %6.2f  FlipAngle: %6.2f NEX: %6.2f\n',hdr_str.tr,hdr_str.tr,hdr_str.flip_angle,hdr_str.no_averages);
    fprintf(fid,'Synt freq %6.4f\n',hdr_str.synthesizer_frequency);
    fprintf(fid,'dwell time %6.3f spec width %6.3f NumPts %d\n',hdr_str.dwell_time, hdr_str.spectral_width,hdr_str.spectra_nb_pts);

  end
end    
