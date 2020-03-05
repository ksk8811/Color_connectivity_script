function compute_vfa_T1(P,Prot,par)


if ~exist('par'),par ='';end

defpar.seuilT2=200;
defpar.method = 'lin';% exp 'lin'
defpar.sge=0;
defpar.jobname='computeT2';
defpar.walltime = '10:00:00';
defpar.mask  = '';
defpar.prefix = 'T1MAP_';
defpar.skip = 0;
par = complet_struct(par,defpar);



if ischar(P),    P=cellstr(P);end

T1filename = addprefixtofilenames(P,par.prefix);
T1MSEfilename = addprefixtofilenames(T1filename,'MSE');

alpha = Prot.alpha*pi/180;
TR = Prot.TR;



VY = spm_vol(char(P));

if par.skip
    VY(par.skip) = []
end

NbFiles = length(VY);
dim = VY(1).dim(1:3);

if iscell(par.mask)
    mask = spm_read_vols(spm_vol(par.mask{nbv}));
else
    mask=ones(dim);
end


T1img=VY(1);        T1img.fname =T1filename{1}(1,:);
T1img = spm_create_vol(T1img);
T2MSEimg=VY(1);        T2MSEimg.fname =T1MSEfilename{1}(1,:);
T2MSEimg = spm_create_vol(T2MSEimg);

errors=0;

for nb_slice = 1:dim(3)
    
    X2 = zeros(dim(1:2));
    Xmse = zeros(dim(1:2));
    Mi      = spm_matrix([0 0 nb_slice]);
    clear Xm;
    
    for nb_vol = 1:NbFiles
        
        X       = spm_slice_vol(VY(nb_vol),Mi,VY(nb_vol).dim(1:2),0);
        Xm(:,nb_vol) = X( (mask(:,:,nb_slice)>0) );
    end
    
    
    alphas = repmat(alpha,[size(Xm,1) 1]);
    
    y=Xm./sin(alphas);
    x = Xm./tan(alphas);
    
%     for nn=1:size(Xm,1)
%         yy=y(nn,:);
%         xx=x(nn,:);
%         var_x = sum((xx-mean(xx)).^2);
%         cv = sum( (xx-mean(xx)).*(yy-mean(yy)) );
%         pente(nn) = cv./var_x;
%         Kconst(nn) = mean(yy)-pente(nn).*mean(xx);
%     end
    
    mmx=  repmat(mean(x,2),1,size(x,2));
    mmy=  repmat(mean(y,2),1,size(y,2));
    var_x = sum((x-mmx).^2,2);
    cv = sum( (x-mmy).*(y-mmy) ,2);
    pente = cv./var_x;
    
    %ind_remove = (pente<0.01) + (pente>0.99);    
    %pente(logical(ind_remove)) = 0.01;
    pente(pente<0) = NaN;
    T1 = -TR(1)./log(pente);

    ind_remove = (T1<50e-3) + (T1>5);    
    T1(logical(ind_remove)) = 50e-3;
    
    beta0 = mean(y,2) - mean(x,2).*pente;
    KM0 = beta0 ./ (1 - pente);
        
    %figure; plot(x,y)
    
    %         var_x = repmat ( sum((x-mean(x)).^2)/size(y,2), size(y,1),1);
    %         cv=sum( repmat(x-mean(x),size(y,1),1) .* (y-repmat(mean(y,2),1,size(y,2)) ),2 )/size(y,2);
    
    
    
    X2(mask(:,:,nb_slice)>0) = T1;

    switch par.method
        case 'exp'
            %opts=optimset('Display','off','Robust','on');
            %opts=statset('Robust','on','Display','off');
            opts = optimoptions(@lsqnonlin,'Algorithm','levenberg-marquardt','Display','off');
            
            warning('OFF','MATLAB:singularMatrix')
            warning('OFF','MATLAB:log:logOfZero')
            warning('OFF','MATLAB:divideByZero')
            warning('OFF','MATLAB:singularMatrix')
            
            fix=logical([0 0 1]);
            
           for nbp=1:size(Xm,2)
                yy     = Xm(nbp,:);
                xstart = [KM0(nbp) T1(nbp) 1]
                
                objfcn = @(x_in) ( Sdirect_SPGR(choose( xstart, x_in, fix ),Prot) - yy);
                [vestimated,res_norm,residuals,exitflag,output] = lsqnonlin(objfcn,xstart(~fix),[],[],opts);

           end
            
            X2(mask(:,:,nb_slice)>0) = at2;
            Xmse(mask(:,:,nb_slice)>0) = amse;
            
            spm_write_plane(T1img,X2,nb_slice);
            spm_write_plane(T2MSEimg,Xmse,nb_slice);
            
            
            
        case 'lin'
            spm_write_plane(T1img,X2,nb_slice);
    end
    
    
    %   b=mean(y,2) - repmat(mean(x),size(y,1),1).*a;
    %   yest=a*x + repmat(b,1,size(y,2))
    
end

if errors
    fprintf('Fitting of done with %d errors (%s)\n',errors,T1filename{nbv}(1,:))
end

