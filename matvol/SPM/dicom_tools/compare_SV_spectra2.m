
%filename=f;

%if  exist(filename,'dir' )
%  files=dir(filename);files=files(3:end);
%  files_dir=filename;
%else 
%  files.name = filename;
%  files_dir='';
%end

liste = spm_get(-Inf,'*','Select Directories of DICOM files');
sizeListe = size(liste,1);
nbf=1;
close all

do_fit=0;

for i = 1:sizeListe

    D = liste(i,:);
    files = spm_get('Files',D,'*.IMA');

    for n=1:size(files,1)
  
      %  filename = fullfile(files_dir,files(nbf).name);
      f = files(n,:)    ;
      ff=strrep(f,' ','');
    
      [spec_time, spec_fft, ahdr, ppm_range] = read_Numaris4(ff);
  
      %find the max
      [val,ind]=max(real(spec_fft ));
      h2o_ppm(nbf) = ppm_range(ind);
  
      hdr(nbf) = ahdr;
%      data_time(:,nbf) = spec_time';
%      data_fft(:,nbf) = spec_fft';
      data_time{nbf} = spec_time';
      data_fft{nbf} = spec_fft';

       
      if(do_fit)
	m_in.spec_time = spec_time;
	m_in.spec_fft = spec_fft;
	m_in.hdr = ahdr;
	m_in.ppm_range = ppm_range;
	[amp,phi,delta,FHz,Fppm,Z,C]=do_hsvd_oct(m_in,1);
	T2(nbf) = 1/(delta*pi);
	width_ppm(nbf) = delta/pi/ahdr.synthesizer_frequency;
	
      end	
      
      nbf=nbf+1;

    end
    [ddd fff]=fileparts(D); 
    Numfile(i) = n;
    indser(i) = nbf;
end

mi=min(h2o_ppm);ma=max(h2o_ppm);

plot(h2o_ppm)
title ('ppm of the h20 peak' )
hold on
for k=1:length(indser)
plot([indser(k),indser(k)],[mi,ma],'--')
end
xlabel('acquired fid')
ylabel('ppm')
