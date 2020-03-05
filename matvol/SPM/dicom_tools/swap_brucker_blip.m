function swap_brucker_blip(fin,par)


if ~exist('par')
    par='';
end

defpar.prefix = 'swap_';

par = complet_struct(par,defpar);

fo = addprefixtofilenames(fin,par.prefix);


for nbi = 1:length(fin)
    
    [V,img_KO] = nifti_spm_vol(fin{nbi});
    sizeI =  size(img_KO);
    mil_X = 0.5 * sizeI(1);
    img_OK = zeros(size(img_KO));

    %% devant _ derriere
    for i=1:mil_X
        for j=1:sizeI(2)
            for k=1:sizeI(3)
                for l=1:sizeI(4)
                    img_OK(i+mil_X,j,k,l) = img_KO(i,j,k,l);
                    img_OK(i,j,k,l) = img_KO(i+mil_X,j,k,l);
                end
            end
        end
    end
    %% retournement
    img_final = zeros(size(img_OK));

    for i=1:sizeI(1)
        for j=1:sizeI(2)
            for k=1:sizeI(3)
                for l=1:sizeI(4)
                    img_final(i,j,k,l) = img_OK((sizeI(1)-i)+1,j,k,l);
                end
            end
        end
    end
    
    [pp ff ee] = fileparts(deblank(fo{nbi}));
    if strcmp(ee,'.gz')
        fo{nbi} = fullfile(pp,ff);
    end
    
    for nbv=1:length(V)
        V(nbv).fname  = fo{nbi};
        spm_write_vol(V(nbv),img_final(:,:,:,nbv));
    end
    
    
end
