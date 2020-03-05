function ok=is_a_volumetric_serie(ser_dir)
files = dir(ser_dir);

if length(files)>3  kk=4;else  kk=3; end

hdr = spm_dicom_headers(fullfile(ser_dir,files(kk).name));
hh = hdr{1};

ok=0;

if isfield(hh,'CSAImageHeaderType')
  MRtype = hh.CSAImageHeaderType;
  if strncmp(MRtype,'IMAGE NUM 4',6)
    if ~strncmp(hh.ImageType,'DERIVED',7)
%      [p,f] = fileparts(ser_dir);
%      a=strfind(f,'LOCA');
%      if isempty(a) % skip serie name containing LOCA
	ok=1;
%      end
    end
  end
end
