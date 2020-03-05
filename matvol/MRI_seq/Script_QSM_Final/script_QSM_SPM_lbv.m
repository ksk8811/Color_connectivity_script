function [qsm_SDI qsm_TSVD qsm_SHARP qsm_LBV]=script_QSM_SPM(seq,mag,phase,outdir)

%% Loading Magnitude Phase and sequence parameters...
%(matrix size, voxel size (mm), Imaging frequency (MHz)

if iscell(mag)
    for nbs=1:length(mag)
        fprintf('working on %s\n',outdir{nbs});
        %try
            script_QSM_SPM_lbv(seq,mag{nbs},phase{nbs},outdir{nbs});
        %catch
        %    fprintf('\n\nERROR for suj %s\n',outdir{nbs});
        %    keyboard
        %end
    end
    return
end

ff=fopen(fullfile(outdir,'log_qsm.log'),'a+');
fprintf(ff,'working with seq %d mag and phase \n%s\n%s\n',seq,mag,phase);
fclose(ff);


sigma=0.020; % user defined for SDI
delta=1/3; % user defined for SDI
lambda = 1000; % User defined for MEDI

%root_dir=pwd;
[Data matrix_size voxel_size ImagingFrequency TE header_spm]=load_files(mag,phase);
cd(outdir);

iMag=sqrt(sum(abs(Data).^2,4));


ff=fopen(fullfile(outdir,'log_qsm.log'),'a+');
fprintf(ff,'data loaded\n');
fclose(ff);


switch seq
    case 1 %% Sequence 1 Whole Brain Sagittal 12 Echoes : 1mm3 iso
        
        B0_dir=[0;1;0];
        Mask_hdr=spm_vol('rMask.nii');
        Mask=spm_read_vols(Mask_hdr);
        Mask=Mask>0.01;
        Mask(:,:,1:4)=0;Mask(:,:,end-3:end)=0;
        Mask=imclose(Mask,strel('disk',5,8));
        
        %6mm erosion
        val=round(6/voxel_size(1));
        Mask=imerode(Mask,strel('disk',val,8));
        %Nulling first and last slices
        Mask(:,:,1:4)=0;Mask(:,:,end-3:end)=0;
        
        
    case 2 %%Sequence 2 Axial Slab 9 echoes : 1mm3 iso
        
        B0_dir=[0;0;1];
        Mask_hdr=spm_vol('rMask.nii');
        Mask=spm_read_vols(Mask_hdr);
        Mask=Mask>0.01;
        Mask=imclose(Mask,strel('disk',5,8));
        
        %6mm erosion
        val=round(6/voxel_size(1));
        Mask=imerode(Mask,strel('disk',val,8));
        %Nulling first and last slices
        Mask(:,:,1:4)=0;Mask(:,:,end-3:end)=0;
        
    case 3 %%Sequence 3 High Resolution Axial Slab 9echoes : 0.5*0.5*2mm3
        
        B0_dir=[0;0;1];
        Mask_hdr=spm_vol('rMask.nii');
        Mask=spm_read_vols(Mask_hdr);
        Mask=Mask>0.01;
        Mask=imclose(Mask,strel('disk',10,8));
        
        %6mm erosion
        val=round(6/voxel_size(1));
        Mask=imerode(Mask,strel('disk',val,8));
        %Nulling first and last slices
        Mask(:,:,1:2)=0;Mask(:,:,end-1:end)=0;
        
end

if length(TE)<2
    delta_TE=TE;
else
    delta_TE = mean(diff(TE));
end

%Conversion from rad to ppm
%ImagingFreq is in MHz, delta_TE in seconds

Tau=2*pi*ImagingFrequency*delta_TE;
dimension=[1 voxel_size(2)./voxel_size(1) voxel_size(3)./voxel_size(1)]; % for anisotropic voxels (x,y,z)
[phase_combine, N_std]=combine(Data);

[LW inv_kernel_fourier inv_kernel_fourier_tsvd K]=precalculate(dimension, Tau, sigma, delta,matrix_size,voxel_size,B0_dir);
true_phase=ifftn(fftn(LW(phase_combine)).*inv_kernel_fourier); %%%Used throughout code
new_mask=apodization(Mask,matrix_size);


    %% QSM LBV /// LBV + MEDI L1
    fprintf('YYYYYYYYYYYYYYYYYYYY')
    
    LBV_phase=LBV(true_phase,Mask,matrix_size,voxel_size);
    save('lbv_phase','LBV_phase')
   % qsm_LBV=MEDI_L1(lambda,LBV_phase,N_std,Mask,iMag,matrix_size,voxel_size,B0_dir,Tau);
    
    %%%%Save results on NIFTI Format
  %  header_spm.descrip = 'QSM LBV (ppm)';
  %  header_spm.fname = ['qsm_LBV.img'];
  %  spm_write_vol(header_spm, qsm_LBV);

end

%% SHARP Phase
function SHARP_phase=SHARP(true_phase,matrix_size,voxel_size,Mask)
        radius=round(6/max(voxel_size)) * max(voxel_size);
        sphere=sphere_kernel(matrix_size,voxel_size,radius);
        conv_op=ifftn(fftn(true_phase).*(sphere));
        substraction=true_phase-conv_op;
        invert_sphere=1-sphere;
        invert_sphere(abs(invert_sphere)<0.05)=0.05;
        SHARP_phase=ifftn(fftn(substraction.*Mask)./(invert_sphere));
        
    end

%% Precalculation
function [LW inv_kernel_fourier inv_kernel_fourier_tsvd K ]=precalculate(dimension,Tau,sigma,delta,matrix_size,voxel_size,B0_dir)

kernel_x(:,:,1)=[0 0 0;0 0 0;0 0 0];
kernel_x(:,:,2)=[0 0 0;-1 2 -1;0 0 0];
kernel_x(:,:,3)=[0 0 0;0 0 0;0 0 0];
kernel_y(:,:,1)=[0 0 0;0 0 0;0 0 0];
kernel_y(:,:,2)=[0 -1 0;0 2 0;0 -1 0];
kernel_y(:,:,3)=[0 0 0;0 0 0;0 0 0];
kernel_z(:,:,1)=[0 0 0;0 -1 0;0 0 0];
kernel_z(:,:,2)=[0 0 0;0 2 0;0 0 0];
kernel_z(:,:,3)=[0 0 0;0 -1 0;0 0 0];

kernel=kernel_x/dimension(1).^2+kernel_y/dimension(2).^2+kernel_z/dimension(3).^2;
kernel=circshift(padarray(kernel,matrix_size-size(kernel),'post'),[-1 -1 -1]);

%Fourier domain Laplace kernel
kernel_fourier=fftn(kernel);
clear kernel;

%Laplacian Unwrapping operator
LW=@(X)cos(X).*ifftn(fftn(sin(X)).*kernel_fourier)-sin(X).*ifftn(fftn(cos(X)).*kernel_fourier);

%Fourier domain inverse Laplace kernel
inv_kernel_fourier=1./kernel_fourier;
inv_kernel_fourier(isinf(inv_kernel_fourier))=0;
inv_kernel_fourier_tsvd=inv_kernel_fourier;
inv_kernel_fourier(abs(kernel_fourier)<10^-15)=0; % Avoid troubles

%TSVD Regularization
inv_kernel_fourier_tsvd(abs(kernel_fourier)<sigma)=sigma;

%Fourier domain inverse dipole response
D=dipole_kernel_liu(matrix_size,voxel_size,B0_dir,'kspace');
D_prime=D;
D_prime(D>0)=delta;
D_prime(D<0)=-delta;
D_prime(abs(D)>delta) = D(abs(D)>delta);
D_prime(D_prime==0)=delta;

%Correction factor Cx
p_tilde=(D./D_prime);
%p=ifftn(p_tilde);
Cx=sum(p_tilde(:))./(matrix_size(1)*matrix_size(2)*matrix_size(3));
clear p_tilde

K=inv_kernel_fourier_tsvd.*Tau.^-1.*D_prime.^-1.*Cx.^-1;
clear D D_prime
end

%% Apodization with an hanning window
function new_mask=apodization(mask,matrix_size)

new_mask=zeros(size(mask));
width=min(size(mask,1),size(mask,2));
vect_hann=0.5*(1-cos(2*pi*(0:width-1)/(width-1)));
hanning2d=vect_hann'*vect_hann;
hanning2d=fftshift(padarray(hanning2d,...
    [(matrix_size(1)-width)/2 (matrix_size(2)-width)/2],0,'both'));
for i=1:size(mask,3)
    new_mask(:,:,i)=real(ifft2(fft2(mask(:,:,i)).*hanning2d));
end
end

%% Combining Echoes
function [phase_combine,x]=combine(Data)

NumSlices=size(Data,3);
NumEchoes=size(Data,4);
phase_combine=zeros(size(Data,1),size(Data,2),size(Data,3));x=zeros(size(Data,1),size(Data,2),size(Data,3));
for slice = 1:NumSlices
    im3d = squeeze(Data(:,:,slice,:));
    imc=zeros(size(im3d));
    ph=zeros(size(im3d));
    
    % combining echoes
    % first estimate of phase, to avoid unwrapping in temporal dimension
    [im0,p] = fte(im3d,64);
    
    % removing phase, linear model
    for echo = 1:NumEchoes
        A = exp(-1i*(angle(im0) + (echo-1)*p));
        imc(:,:,echo) = im3d(:,:,echo).*A;
    end
    
    % getting phase, unwrapped in time
    for echo = 1:NumEchoes
        ph(:,:,echo) = ((echo-1)*p) + angle(imc(:,:,echo)) + angle(im0);
    end
    
    % linear fit, weighted linear least squares
    [phase_combine(:,:,slice),x(:,:,slice),p0,r] = Fit_freq2(ph,abs(imc));
    
    
end
end
function [ Mb,p ] = fte( M ,n )
%FFTM Summary of this function goes here
%   Detailed explanation goes here

s = size(M);
d = size(s(:),1);

Mb = (fft(M,n,d));
[Mb,p]=max(Mb,[],d);
p = (p-(n+1)/2)./n*2*pi;
p = mod(p,2*pi)-pi;

end
function [p,dp,p0,r]=Fit_freq2(Y,D,sp)
% fit the phase to a line
% Y is the phase, unwrapped
% D is the weighting, signal amplitude usually
% sp is the relative echo time
% last dimension is echo time

s0=size(Y);
l0=length(s0);
nechos=size(Y,l0);

if nargin<2
    D=1;
end

% spacing or relative spacing of echo times
if nargin<3
    sp=0:nechos-1;
end

Y=reshape(Y,[prod(s0(1:l0-1)),s0(l0)]);
s=size(Y);
l=length(s);

if nargin>1
    D=reshape(D,[prod(s0(1:l0-1)),s0(l0)]);
end

v1=ones(1,nechos);
v2=(0:(nechos-1));
if nargin>1
    te=sp;
    v2=te./(te(2)-te(1));
end


% weigthed least square
% calculation of QA'*QA
a11=sum(D.^2.*(ones(s(1),1)*(v1.^2)),2);
a12=sum(D.^2.*(ones(s(1),1)*(v1.*v2)),2);
a22=sum(D.^2.*(ones(s(1),1)*(v2.^2)),2);

% invertion
d=a11.*a22-a12.^2;
ai11=a22./d;
ai12=-a12./d;
ai22=a11./d;

% projection
p1=sum(D.^2.*(ones(s(1),1)*v1).*Y,2);
p2=sum(D.^2.*(ones(s(1),1)*v2).*Y,2);

% fitted phase
p0=ai11.*p1+ai12.*p2;
p=ai12.*p1+ai22.*p2;

% error propagation
dp0=sqrt(ai11);
dp=sqrt(ai22);
% finally calculate the correlation with linear model

r=[];
if nargout>2
    % r=corr2(A,B);
    model=p0*v1+p*v2;
    % Y;
    % calcul covariance matrix
    % ecart type de la difference?
    % mY=mean(Y,2);
    % mmodel=mean(model,2);
    % cii=sum((Y-mY*v1).^2,2);
    % cjj=sum((model-mmodel*v1).^2,2);
    % cij=sum((model-mmodel*v1).*(Y-mY*v1),2);
    % r=cij./(sqrt(cii.*cjj));
    % residual
    % see if the weighting is to be considered here
    % disp('check weighting')
    % r = D.*(Y-model);
    r = (Y-model);
    r = sqrt(sum(r.^2,2));
    
end

if size(s0(1:l0-1),2)>1
    p=reshape(p,s0(1:l0-1));
    if nargout>2
        r=reshape(r,s0(1:l0-1));
    end
    p0=reshape(p0,s0(1:l0-1));
    dp=reshape(dp,s0(1:l0-1));
    dp0=reshape(dp0,s0(1:l0-1));
end

p(isnan(p))=0;
r(isnan(r))=0;
p0(isnan(p0))=0;
dp(isnan(dp))=0;
dp0(isnan(dp0))=0;

p=permute(p,[1 2 3 5 4]);
r=permute(r,[1 2 3 5 4]);
dp=permute(dp,[1 2 3 5 4]);
p0=permute(p0,[1 2 3 5 4]);
dp0=permute(dp0,[1 2 3 5 4]);
end

%% Load Files
function [Data matrix_size voxel_size ImagingFrequency TE header_spm]=load_files(data_dir_mag,data_dir_pha)

%data_dir_mag = uigetdir('Open magnitude directory');
%data_dir_pha = uigetdir('Open phase directory');

files_mag = dir( fullfile(data_dir_mag,'*.hdr') );
files_pha = dir( fullfile(data_dir_pha,'*.hdr') );
cd(data_dir_mag);
header=load(fullfile(data_dir_mag,'dicom_info'));
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
end