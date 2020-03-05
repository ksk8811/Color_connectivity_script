function fout=concat_interleaved3(f1,f2,f3,par)


if ~exist('par','var'),par ='';end
defpar.out_prefix1 = 'rintercal_';
defpar.out_prefix2 = 'rinter_model_';
defpar.method = 'intercal'; %model
defpar.dimslice=2;

par = complet_struct(par,defpar);
dimslice=par.dimslice;

f1 = cellstr(char(f1));
f2 = cellstr(char(f2));
f3 = cellstr(char(f3));

for nbf=1:length(f1)
    V1 = spm_vol(f1{nbf});
    V2 = spm_vol(f2{nbf});
    V3 = spm_vol(f3{nbf});
    
    ima1 = spm_read_vols(V1);
    ima2 = spm_read_vols(V2);
    ima3 = spm_read_vols(V3);
    
    Vout          = V1;
    
    mat = V1(1).mat(1:3,1:3);
    vox = sqrt(diag(mat'*mat));  e=eye(3) ;e(1,1)=vox(1);e(2,2)=vox(2);e(3,3)=vox(3);
    rot = mat/e;
    %e(3,3) = e(3,3)/2;
    e(dimslice,dimslice) = e(dimslice,dimslice)/3;
    newmat = rot*e;
    
    for kk=1:length(Vout)
        Vout(kk).mat(1:3,1:3) = newmat;
    end
   
    z_order=[ V1(1).mat(dimslice,4),V2(1).mat(dimslice,4),V3(1).mat(dimslice,4)]
    [vv ii]=sort(z_order) ;
    Ima = {ima1,ima2,ima3};
    Ima=Ima(ii);
    ima1=Ima{1};
    ima2=Ima{2};
    ima3=Ima{3};
    
    switch par.method
        case 'model'
           
        case 'intercal'
            for kk=1:length(Vout)
                Vout(kk).dim(dimslice)   = V1(1).dim(dimslice)*3;
            end
            fout = addprefixtofilenames(f1,par.out_prefix1);
            
            for kk=1:length(Vout)
                imao = zeros(Vout(1).dim );
                switch dimslice
                    case 3
                        for nbslice = 1:size(ima1,3)
                            imao(:,:,3*nbslice-2) = ima1(:,:,nbslice,kk);
                            imao(:,:,3*nbslice-1) = ima2(:,:,nbslice,kk);
                            imao(:,:,3*nbslice)  =  ima3(:,:,nbslice,kk);
                        end
                    case 2
                        for nbslice = 1:size(ima1,2)
                            imao(:,3*nbslice-2,:) = ima1(:,nbslice,:,kk);
                            imao(:,3*nbslice-1,:) = ima2(:,nbslice,:,kk);
                            imao(:,3*nbslice,:) = ima3(:,nbslice,:,kk);
                        end
                        
                end
                ff=addsufixtofilenames(fout{nbf},sprintf('%.4d',kk));
                Vout(kk).fname =ff;
                Vout(kk).n=[1 1];
                spm_write_vol(Vout(kk),imao(:,:,:));
            end
            [pp ff]=fileparts(fout{nbf})
            ff = get_subdir_regex_files(pp,ff)
            par.checkorient=0;
            do_fsl_merge(ff,fout{nbf},par)
            do_delete(ff,0)
            
            
    end
end



