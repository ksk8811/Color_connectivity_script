function [m_out] = HSVDFilter_oct(filename)


 [m_in.spec_time, m_in.spec_fft, m_in.hdr, m_in.ppm_range] = read_Numaris4(filename);

flppm = 4.33; 
fuppm = 5.07;
nbSV = 10;

[amp,phi,delta,FHz,Fppm,Z,C]=do_hsvd_oct(m_in,nbSV);

I = find(Fppm>flppm & Fppm<fuppm);

S = Z(:,I)*C(I);

%A = amp(I);
%D = delta(I);
%F = FHz(I)
%P = phi(I);

%t = (1:m_in.n_data_points)./m_in.spectral_width;
%S = 0;
%for pp=1:length(A)
%  S = S + amp(pp)*exp(-t*delta(pp)).*exp(j*2*pi*FHz(pp)*t).*exp(j*phi(pp));
%end

disp('flppm :'),disp(flppm)
disp('fuppm :'),disp(fuppm)
disp('frequencies found :'),disp(Fppm(I))
disp('amplitudes :'),disp(amp(I))

m_out = m_in;
m_out.spec_time = m_in.spec_time - S';
%m_out.spec_time = S';
m_out.spec_fft = fftshift(fft(m_out.spec_time));


%=========================================================================
function value = FindAndGet(charfilecontent, Paramstr,nbelement,type)
% function value = FindAndGet(charfilecontent, Paramstr)
%
% Function to extract file contents from the ASCII part of the file
%

%ascii_param_pos = findstr(charfilecontent, '### ASCCONV BEGIN ###') + 31;

if nargin<4
    type = 'num';
end
if nargin<3
    nbelement=3;
end

tpos = findstr(charfilecontent([1]:[end]), Paramstr);
tstring = sscanf(charfilecontent([tpos]:[end]), '%s', nbelement);
t2pos = findstr(tstring, ':');
tstringl = length(tstring);
charval = tstring([t2pos + 1]:tstringl);
if strcmp(type,'num')
    value = str2num(charval);
elseif strcmp(type,'string')
    value = charval;
end
