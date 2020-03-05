
%filename=f;

%if  exist(filename,'dir' )
%  files=dir(filename);files=files(3:end);
%  files_dir=filename;
%else 
%  files.name = filename;
%  files_dir='';
%end
close all
clear hdr
do_fit=0;

liste = spm_get(-Inf,'*','Select Directories of DICOM files');
sizeListe = size(liste,1);

for i = 1:sizeListe

    D = liste(i,:);
    files = spm_get('Files',D,'*.IMA');
    clear data_time data_fft hdr h2o_ppm T2 width_ppm
    
    for nbf=1:size(files,1)
  
      %  filename = fullfile(files_dir,files(nbf).name);
      f = files(nbf,:)    ;
      ff=strrep(f,' ','');
    
      [spec_time, spec_fft, ahdr, ppm_range] = read_Numaris4(ff);
  
      %find the max
      [val,ind]=max(real(spec_fft ));
      h2o_ppm(nbf) = ppm_range(ind);
  
      hdr(nbf) = ahdr;
      data_time(:,nbf) = spec_time';
      data_fft(:,nbf) = spec_fft';
       
      if(do_fit)
	m_in.spec_time = spec_time;
	m_in.spec_fft = spec_fft;
	m_in.hdr = ahdr;
	m_in.ppm_range = ppm_range;
	[amp,phi,delta,FHz,Fppm,Z,C]=do_hsvd_oct(m_in,1);
	T2(nbf) = 1/(delta*pi);
	width_ppm(nbf) = delta/pi/ahdr.synthesizer_frequency;
	
      end	
      
    end

    [ddd fff]=fileparts(D);
    titrefile{i} = fff; 

% plot(h2o_ppm)
% title ([ff ' res ' num2str(ppm_range(2)-ppm_range(1))])
    Res(i).data_time = data_time;
    Res(i).data_fft = data_fft;
    Res(i).hdr = hdr;
    Res(i).h2o_ppm = h2o_ppm;

    if exist('T2')
      Res(i).T2 =T2;
      Res(i).width_ppm=width_ppm;
    end
end
