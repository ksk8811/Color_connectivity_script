function [spec_time, spec_fft, hdr, ppm_range] = read_Numaris4(filename)

  
[FileId, file_open_error] = fopen(filename, 'r', 'ieee-le');
filecontent = fread(FileId);
charfilecontent = char(filecontent');

% -------------------------------------------
% EXTRACT HEADER information
% -------------------------------------------
hdr = read_spectro_header(charfilecontent);
hdr.file_size = length(filecontent);


% -------------------------------------------
% SPECTRAL DATA EXTRACTION (Binary part of file)
% -------------------------------------------
%bug with fseek in octave, so close it first
fclose(FileId);
[FileId, file_open_error] = fopen(filename, 'r', 'ieee-le');

fseek(FileId, (hdr.file_size - hdr.data_bytes_size),'bof');
%[temp_data, count] = fread(FileId, (hdr.data_bytes_size/4), 'float32');
[temp_data, count] = fread(FileId, Inf, 'float32');
temp_data = temp_data';

spec_time_real = temp_data(1:2:hdr.spectra_nb_pts*2);
spec_time_imag = temp_data(2:2:hdr.spectra_nb_pts*2);

spec_time = spec_time_real + i*spec_time_imag;
spec_fft = fftshift(fft(spec_time));

% ---------------------
% PPM-RANGE CALCULATION
% ---------------------
x_n       = -0.5 : 1/(hdr.spectra_nb_pts - 1) : 0.5;
x_hz      = hdr.frequency_format .* hdr.spectral_width .* x_n;

ppm_range = hdr.nucleus_offset_frequency +  (x_hz - 0 ) / hdr.synthesizer_frequency;

fclose(FileId);
