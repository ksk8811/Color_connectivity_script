function compute_T1(P,TI,par)


if ~exist('par'),par ='';end

defpar.seuilT2=200;
defpar.method = 'exp';%'lin'
defpar.sge=0;
defpar.jobname='computeT1';
defpar.walltime = '10:00:00';
defpar.mask  = '';
defpar.prefix = 'T1MAP_';
par = complet_struct(par,defpar);


if ~exist('P')
    Pd = spm_select([1 Inf],'dir','a dir of images','',pwd);
    ff = dir(fullfile(Pd,'*.img'))
    for k=1:length(ff)
        P(k,:) = fullfile(Pd,ff(k).name);
    end
    
end

if ~exist('TI')
    TI=[300 600 900 1200 1500 1800 2100 2400 2700 3000 ];
end


if ischar(P),    P=cellstr(P);end

T1filename = addprefixtofilenames(P,par.prefix);
T2MSEfilename = addprefixtofilenames(T1filename,'MSE');


withmask=0;

for nbs=1:length(P)
    VY = spm_vol(P{nbs});
    NbFiles = length(VY);
    dim = VY(1).dim(1:3);
    
    if ~exist('maskfile')
        %mask=ones(dim(1:2));
        mask=ones(dim);
    else
        vm=spm_vol(maskfile);
        if any(dim-vm.dim(1:3))
            error('wrong maks dimention %d %d %d',vm.dim(1:3))
        end
        for nb_slice = 1:dim(3)
            mask(:,:,nb_slice) = spm_slice_vol(vm,spm_matrix([0 0 nb_slice]),dim(1:2),0);
        end
    end
    
    
    T1img=VY(1);
    T1img.fname = T1filename{nbs};
    
    T1img = spm_create_vol(T1img);
    
    
    for nb_vol = 1:NbFiles
        for nb_slice = 1:dim(3)
            Mi      = spm_matrix([0 0 nb_slice]);
            X(:,:,nb_slice) = spm_slice_vol(VY(nb_vol),Mi,VY(nb_vol).dim(1:2),0);
        end
        mask(X==0)=0;
    end
    
    
    for nb_slice = 1:dim(3)
        
        X2 = zeros(dim(1:2));
        Mi      = spm_matrix([0 0 nb_slice]);
        clear Xm;
        
        for nb_vol = 1:NbFiles
            
            X       = spm_slice_vol(VY(nb_vol),Mi,VY(nb_vol).dim(1:2),0);
            Xm(:,nb_vol) = X( (mask(:,:,nb_slice)>0) );
        end
        
        ii = find(Xm(:,1)>0);
        opts=statset('Display','off');
        
        for nbp=1:length(ii)
            yy = Xm(ii(nbp),:);
            
            beta0 = [max(yy) 1000];
            try
                [ betaEnd ,R,J,COVB,MSE] = nlinfit(TI,yy,@T1_exp,beta0,opts);
            catch
                betaEnd(2)=0;
                MSE=-1;
            end
            at2(ii(nbp)) = betaEnd(2);
            amse(ii(nbp)) = MSE;
            
        end
        X2(mask(:,:,nb_slice)>0) = at2;
        Xmse(mask(:,:,nb_slice)>0) = amse;
        
        %                     at2(at2<0) = 0;
        %   at2(at2>1500) = 0;
        
        X2(mask(:,:,nb_slice)>0) = at2;
        
        spm_write_plane(T1img,X2,nb_slice);
        
        %   b=mean(y,2) - repmat(mean(x),size(y,1),1).*a;
        %   yest=a*x + repmat(b,1,size(y,2))
        
    end
end


if (0)
    mask = zeros(VY(1).dim(1:3));
    mask2=mask;
    
    for nb_vol=1:NbFiles
        for j = 1:VY(nb_vol).dim(3)
            Mi      = spm_matrix([0 0 j]);
            X       = spm_slice_vol(VY(nb_vol),Mi,VY(nb_vol).dim(1:2),0);
            slice_mean(j,nb_vol) = mean(X(:));
        end
        vol_mean(nb_vol) = mean(slice_mean(:,nb_vol));
        
        seuil(nb_vol) = vol_mean(nb_vol)/4;
        
        nbpts=0;
        
        for j = 1:VY(nb_vol).dim(3)
            Mi      = spm_matrix([0 0 j]);
            X       = spm_slice_vol(VY(nb_vol),Mi,VY(nb_vol).dim(1:2),0);
            nbpts(j) = sum(sum(X>=seuil(nb_vol)));
            slice_mean_spm(j,nb_vol) = sum(sum(X(X>=seuil(nb_vol))));
            mask2(:,:,j) = mask2(:,:,j) + (X>=seuil(nb_vol));
        end
        
        nb_pts(nb_vol) = sum(nbpts);
        vol_mean_spm(nb_vol) = sum(slice_mean_spm(:,nb_vol))./nb_pts(nb_vol);
        nb_pts(nb_vol) = nb_pts(nb_vol) / prod(VY(nb_vol).dim(1:3)) *100 ;
        
        for j = 1:VY(nb_vol).dim(3)
            Mi      = spm_matrix([0 0 j]);
            X       = spm_slice_vol(VY(nb_vol),Mi,VY(nb_vol).dim(1:2),0);
            
            mask(:,:,j) = mask(:,:,j) + (X>=vol_mean_spm(nb_vol)) + (X==0)*(-999);
        end
    end
    
    figure
    for k=1:size(mask,3)
        imagesc(mask(:,:,k)>1)
        pause(0.05)
    end
end