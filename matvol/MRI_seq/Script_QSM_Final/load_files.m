function [Data matrix_size voxel_size ImagingFrequency TE header_spm]=load_files

data_dir_mag = uigetdir('Open magnitude directory');
data_dir_pha = uigetdir('Open phase directory');
files_mag = dir( fullfile(data_dir_mag,'*.hdr') );
files_pha = dir( fullfile(data_dir_pha,'*.hdr') );
cd(data_dir_mag);
header=load('dicom_info');
header_spm=spm_vol(files_mag(1,1).name);
SliceThickness=header.hh{1,1}.SliceThickness;
PixelSpacing=header.hh{1,1}.PixelSpacing;

matrix_size=header_spm.dim;
voxel_size=[PixelSpacing;SliceThickness]';
ImagingFrequency=header.hh{1,1}.ImagingFrequency;

%%Preallocating Memory
Data=zeros([matrix_size length(files_mag)]); 
TE=zeros(length(files_mag),1);
%

for i=1:length(files_mag)
    cd(data_dir_mag);
    V_mag=spm_vol(files_mag(i,1).name);
    TE(i)=str2double(strtok(V_mag.private.descrip(regexp(V_mag.private.descrip,'TE=')+3:end),'ms'));
    magnitude=spm_read_vols(V_mag);
    cd(data_dir_pha);
    V_pha=spm_vol(files_pha(i,1).name);
    phase=spm_read_vols(V_pha)/4096 * pi;
    Data(:,:,:,i)=magnitude.*exp(1i*phase);
end

TE=TE.*10^-3; % to get in seconds