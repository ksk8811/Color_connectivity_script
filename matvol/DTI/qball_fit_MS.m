%==========================================================================
% qball_fit_MS.m

% Resolves the GFA value at each voxel for a diffusion-weighted dataset and
% saves in the same format as a typical DTI FA image

%addpath('/home/mike/batch5//dti_simulations/max_provided/')
%addpath('/home/mike/batch5/niftii_tools')    

%rootdir = '/servernas/images2/christine/dti/PROTO_HD_TRACK';
rootdir = '/home/yulia/data/DTI_fsl'

%get_subjects2=get_subdir_regex(rootdir,'.*','dti_clean');
get_subjects2=get_subdir_regex(rootdir,'.*','DTI')

file_get1  = {'^4D.*unw'};  % THE EDDY CORRECTED IMAGE FILE 
file_get2  = {'^bvecs$'}; % THE BVECS FILE

files1=get_subdir_regex_files(get_subjects2,file_get1,1); 
files2=get_subdir_regex_files(get_subjects2,file_get2,1); 

% Specify lmax
lmax = 4;
 
%==========================================================================

for x=1:size(get_subjects2,2)
run=x

% Load diffusion weighted data and bvecs files for subject
try
  ff = unzip_volume(files1{x});
  data=load_untouch_nii(ff{1});  
  ff=gzip_volume(ff);
catch
  [p,f] = fileparts(ff{1})
  ff= fullfile(p,'4D_eddycor.nii.gz'); %car le unzip du lien symbolique ne  marche pas
  ff = unzip_volume(ff);
  data=load_untouch_nii(ff{1});  
  ff=gzip_volume(ff);  

end

bvecs=load (files2{x}); 
bvecs=bvecs'; 

% Auto-Detection on bzeros 
bv=bvecs; 
    
bvindex=zeros(size(bv,1),4); 
bvindex(:,2:4)=bv;
bvindex(:,1)=1:1:size(bv,1);
    
whichbzeros=zeros(1,10); 
    
a=1; 
    for y=1:size(bv,1) 
        if bvindex(y,2:4)==[0 0 0]
        whichbzeros(a)=bvindex(y,1); 
        a=a+1; 
        end
    end

whichbzeros=whichbzeros(whichbzeros~=0); 
bzeros=sort(whichbzeros,'descend')
clear a bvindex bv whichbzeros

szb=size(bzeros,2);

% Remove bzeros from bvecs and image files
for db=1:szb
data.img(:,:,:,bzeros(1,db))=[];
bvecs(bzeros(1,db),:)=[];
end
 
% Calculate gfa for each voxel in image
dataimg=data.img;
sizeimg=size(dataimg); 
gfa_img=zeros(sizeimg(1),sizeimg(2),sizeimg(3)); 
gradient_scheme = gen_scheme(bvecs, lmax);

for i=1:sizeimg(1)
    run=x
    completed_of_128=i
    for j=1:sizeimg(2)
        for k=1:sizeimg(3)
            S=zeros(sizeimg(4),1); 
            S(:,1)=dataimg(i,j,k,:);
  
            % AMP2SH.M SLOTTED IN==========================================
            if ~isfield (gradient_scheme, 'shinv')
                gradient_scheme.shinv = pinv(gradient_scheme.sh);
            end
            S_SH = gradient_scheme.shinv * S;
            %==============================================================
                      
            % ESTIMATE_QBALL.M SLOTTED IN==================================
            lambda=0.006;
            sharp=0; 
            
            % build the regularization matrix up to lmax:
            kk = 1;
            for l = 0:2:lmax      
                diagl = 2*pi*legendre(l,0);
                diagP = diagl(1);
            for m = -l:l
                L(kk,kk) = l^2*(l+1)^2;
                if(sharp ~= 0)
                    P(kk,kk) = diagP*(sharp*l*(l+1) + 1);
                else
                    P(kk,kk) = diagP;
                end
            kk = kk+1;      
            end
            end 
            % generate qball 
            F_SH = P*S_SH;
            GFA = sqrt(1 - F_SH(1)^2 / sum(F_SH(:).^2));
            %==============================================================
            
            gfa_img(i,j,k)=GFA;
        end
    end
end

% Repack image as a GFA image in 3D
data.img=single(gfa_img); 
data.hdr.dime.dim=[3 sizeimg(1) sizeimg(2) sizeimg(3) 1 1 1 1]; 
data.hdr.dime.glmax=1.2247; 
data.hdr.dime.datatype=16; 
data.hdr.dime.bitpix=32;

% Save new GFA image
name=strcat(char(get_subjects2{x}),'GFA_data.nii') 
save_untouch_nii(data, name);

end


               

