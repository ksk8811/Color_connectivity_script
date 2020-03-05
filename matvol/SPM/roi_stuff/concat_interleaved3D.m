function fout=concat_interleaved(f1,f2)


if ~exist('par','var'),par ='';end
defpar.out_prefix1 = 'rintercal_';
defpar.out_prefix2 = 'rinter_model_';
defpar.method = 'intercal'; %model


par = complet_struct(par,defpar);


f1 = cellstr(char(f1));
f2 = cellstr(char(f2));

for nbf=1:length(f1)
    V1 = spm_vol(f1{nbf});
    V2 = spm_vol(f2{nbf});
    
    ima1=spm_read_vols(V1);
    ima2=spm_read_vols(V2);
    
    Vout          = V1;
    
    mat = V1.mat(1:3,1:3);
    vox = sqrt(diag(mat'*mat));  e=eye(3) ;e(1,1)=vox(1);e(2,2)=vox(2);e(3,3)=vox(3);
    rot = mat/e;
    e(3,3) = e(3,3)/2;
    newmat = rot*e;
    
    Vout.mat(1:3,1:3) = newmat;

    if V1.mat(3,4)>V2.mat(3,4)
        %swhitch 1 and 2
        ii=ima1;
        ima1=ima2;
        ima2=ii
    end
    

    
    switch par.method
        case 'model'
            Vout.dim(3)   = V1.dim(3)*2+1;
            
            fout = addprefixtofilenames(f1,par.out_prefix2);
            Vout.fname = fout{nbf};
            
            lad=linear_and_derivative(ima1,ima2);
            spm_write_vol(Vout,lad);
            
        case 'intercal'
            Vout.dim(3)   = V1.dim(3)*2;
            fout = addprefixtofilenames(f1,par.out_prefix1);
            
            imao = zeros(Vout.dim);
            
            for nbslice = 1:size(ima1,3)
                imao(:,:,2*nbslice-1) = ima1(:,:,nbslice);
                imao(:,:,2*nbslice) = ima2(:,:,nbslice);
            end
            
            Vout.fname = fout{nbf};
            spm_write_vol(Vout,imao);
            
    end
end



