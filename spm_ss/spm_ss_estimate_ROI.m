function ss=spm_ss_estimate_ROI(ss)
% SPM_SS_ESTIMATE_ROI subject-specific ROI-based model estimation
% 
% ss=spm_ss_estimate_ROI(ss)
% see SPM_SS_DESIGN, SPM_SS_ESTIMATE

if nargin<1, 
    str='Select spm_ss*.mat analysis file';
    disp(str);
    Pdefault='';objname=findobj('tag','spm_ss');if numel(objname)==1,objdata=get(objname,'userdata');if isfield(objdata,'files_spm_ss'),Pdefault=objdata.files_spm_ss;end;end;
    P=spm_select(1,'^SPM_ss.*\.mat$',str,{Pdefault});
    if numel(objname)==1&&~isempty(P),objdata.files_spm_ss=P;set(objname,'userdata',objdata);end;
    load(P);
    ss.swd=fileparts(P);
end

cwd=pwd;

% explicit mask
if ~isempty(ss.ExplicitMasking),XM=spm_read_vols(spm_vol(ss.ExplicitMasking))>0;else XM=1;end

% creates transformed measures
neffects=size(ss.EffectOfInterest{1},1);
k=0;
for ne=1:neffects,
    for n=1:ss.n,
        for m=1:numel(ss.Localizer{n}),
            [pth2,nm2,ext2,num2]=spm_fileparts(ss.EffectOfInterest{n}{ne,m});
            Yvolume=[nm2,ext2,num2];
            k=k+1;
            ss.PY{k}=fullfile(pth2,Yvolume);
        end
    end
end
k=0;
ss.PV=[];
for n=1:ss.n,
    for m=1:numel(ss.Localizer{n}),
        [pth1,nm1,ext1,num1]=spm_fileparts(ss.Localizer{n}{m});
        Nvolume=[nm1,ext1,num1];
        k=k+1;
        ss.PN{k}=fullfile(pth1,Nvolume);
        ss.PV(n,k)=1/numel(ss.Localizer{n});
    end
end

cd(ss.swd);
ss.VN=spm_vol(char(ss.PN));
ss.VY=spm_vol(char(ss.PY));

% Creates overlap maps
ssPM1=['Overlap',ext1];
p=0;
for n=1:ss.n,
    idx=find(ss.PV(n,:));
    p1=0;
    for k=1:numel(idx),
        a1=spm_vol(ss.PN{idx(k)});
        b1=spm_read_vols(a1);
        p1=p1+(b1>0)/numel(idx);
    end
    p=p+(p1>.5);
    if n==1,
        ss.PL=['Localizer',ext1];
        e0=struct('fname',ss.PL,'descrip','spm_ss (localizer mask for each subject)','mat',a1.mat,'dim',a1.dim,'n',[1,1],'pinfo',[1;0;0],'dt',[spm_type('float32'),spm_platform('bigend')]);
        e0=repmat(e0,[ss.n,1]);for nb=1:ss.n,e0(nb).n=[nb,1];end
        e0=spm_create_vol(e0);
    end
    spm_write_vol(e0(n),p1);
end
e1=struct('fname',ssPM1,'descrip','spm_ss (inter-subject overlap map)','mat',a1.mat,'dim',a1.dim,'dt',[spm_type('float32'),spm_platform('bigend')]);
e1=spm_write_vol(e1,p/ss.n);
if ss.typen==2,
    ssPM2=['sOverlap',ext1];
    spm_smooth(e1,ssPM2,ss.smooth*[1,1,1]);
    ss.PM2=ssPM2;
end
fprintf(1,'\n');
ss.PM1=ssPM1;

% defines fROIs
if ss.typen==2,
    ss.PM=['fROIs',ext1];
    disp('GcSS defining ROIs. Please wait...');
    a2=spm_vol(ss.PM2);
    b2=spm_read_vols(a2);
    b3=spm_ss_watershed(-b2,find(b2>=ss.overlap_thr_vox));
    fprintf('Done. Defined %d regions\n',max(b3(:)));
    a3=struct('fname',ss.PM,'mat',a2.mat,'dim',a2.dim,'dt',[spm_type('int16') spm_platform('bigend')],'pinfo',[1;0;0]);
    spm_write_vol(a3,b3);  
else
    ss.PM=ss.ManualROIs;
end
ss.VM=spm_vol(ss.PM);
if numel(ss.VM)>1,error('multiple ROI image files not supported'); end
[XYZ{1},XYZ{2},XYZ{3}]=ndgrid(1:ss.VN(1).dim(1),1:ss.VN(1).dim(2),1:ss.VN(1).dim(3));
XYZ=reshape(cat(4,XYZ{:}),[],3)';XYZ=ss.VN(1).mat*cat(1,XYZ,ones(1,size(XYZ,2)));
frois=reshape(round(spm_get_data(ss.VM,pinv(ss.VM.mat)*XYZ))',[ss.VN(1).dim(1:3),numel(ss.VM)]);
if numel(XM)>1&&any(size(frois)~=size(XM)),error('mismatched volume dimensions between functional volumes and explicit mask images'); end
frois=XM.*frois;
nrois=max(frois(:));

% analysis

Nb=[size(ss.X,2),neffects];
extname=['_',ss.type];
VB=struct('fname',['spm_ss',extname,'_beta.img'],...
    'mat',ss.VN(1).mat,...
    'dim',ss.VN(1).dim,...
    'n',[1,1],...
    'pinfo',[1;0;0],...
    'dt',[spm_type('float32'),spm_platform('bigend')],...
    'descrip','spm_ss (effect sizes parameter estimates)');
VB=repmat(VB,[prod(Nb),1]);for nb=1:prod(Nb),VB(nb).n=[nb,1];end
VB=spm_create_vol(VB);
% VE=struct('fname',['spm_ss',extname,'_rss.img'],...
%     'mat',ss.VN(1).mat,...
%     'dim',ss.VN(1).dim,...
%     'n',[1,1],...
%     'pinfo',[1;0;0],...
%     'dt',[spm_type('float32'),spm_platform('bigend')],...
%     'descrip','spm_ss (residual sum squares)');
% VE=repmat(VE,[Nb(2)*Nb(2),1]);for nb=1:Nb(2)*Nb(2),VE(nb).n=[nb,1];end
% VE=spm_create_vol(VE);
VO=struct('fname',['spm_ss',extname,'_overlap.img'],...
    'mat',ss.VN(1).mat,...
    'dim',ss.VN(1).dim,...
    'pinfo',[1;0;0],...
    'dt',[spm_type('float32'),spm_platform('bigend')],...
    'descrip','spm_ss (proportion overlap)');
VO=spm_create_vol(VO);


Bplane=nan+zeros([Nb,nrois]);Cplane=zeros(ss.n,nrois);Eplane=nan+zeros(Nb(2),Nb(2),nrois);Oplane=nan+zeros(1,nrois);Zplane=zeros(ss.n,Nb(2),nrois);Nplane=nan+zeros([1,nrois]);Pplane=nan+zeros([1,nrois]);Mplane=nan+zeros([numel(ss.VN),nrois]);
fprintf('Performing model estimation...');
for nroi=1:nrois,
    fprintf(1,'.');
    idx=find(frois==nroi);
    [idx1,idx2,idx3]=ind2sub(size(frois),idx);
    xyz=[idx1,idx2,idx3,ones(numel(idx1),1)]';
    
    Y=spm_get_data(ss.VY,xyz);
    N=spm_get_data(ss.VN,xyz);
    Z=(N==0)|isnan(N);Y(repmat(Z,[Nb(2),1]))=0;N(Z)=0;Y(isnan(Y))=0;
        %data=cell(size(Y,1),1); for n1=1:size(Y,1), data{n1}=Y(n1,N(1+rem(n1-1,size(N,1)),:)); end; save(['data_roi',num2str(nroi),'.mat'],'data');     
    Mplane(:,nroi)=sum(N,2);
    Y=mean(Y.*repmat(N,[Nb(2),1]),2);
    N=mean(N,2);
    Y=reshape(Y./max(eps,repmat(N,[Nb(2),1])),[size(N,1),Nb(2)]);
    Y=ss.PV*Y;
    N=1./(ss.PV*(1./max(eps,N)));
    sN=mean(N>1e-4,1);
    if sN>0,
        if strcmpi(ss.estimation,'ols')
            iC=double(N>1e-4);%handles missing-data
        else
            n=N;
            y=Y.*sqrt(n(:,ones(1,Nb(2))));
            x=ss.X.*sqrt(n(:,ones(1,Nb(1))));
            e=Y-ss.X*(pinv(x'*x)*(x'*y));
            [nill,iC]=spm_ss_fls({e,n});%covariance estimation
        end
        y=Y.*iC(:,ones(1,Nb(2)));%whitening
        x=ss.X.*iC(:,ones(1,Nb(1)));
        [b,ee]=spm_ss_glm('estimate',x,y);
        Bplane(:,:,nroi)=b;
        Cplane(:,nroi)=iC;
        Eplane(:,:,nroi)=ee;
    end
    Nplane(nroi)=numel(idx);
    Pplane(nroi)=mean(N);
    Oplane(nroi)=sN;
    Zplane(:,:,nroi)=Y;
end
fprintf(1,'\n');

% save files
nb=1;for nb1=1:Nb(1),for nb2=1:Nb(2),z=nan+zeros(size(frois));for nroi=1:nrois,z(frois==nroi)=Bplane(nb1,nb2,nroi);end; spm_write_vol(VB(nb),z);nb=nb+1;end;end
% nb=1;for nb1=1:Nb(2),for nb2=1:Nb(2),z=nan+zeros(size(frois));for nroi=1:nrois,z(frois==nroi)=Eplane(nb1,nb2,nroi);end; spm_write_vol(VE(nb),z);nb=nb+1;end;end
z=nan+zeros(size(frois));for nroi=1:nrois,z(frois==nroi)=Oplane(nroi);end; spm_write_vol(VO,z);
% disp(['created beta volume       : ',fullfile(ss.swd,VB(1).fname),' - ',num2str(Nb),' volume(s)']); 
% disp(['created rss volume        : ',fullfile(ss.swd,VE(1).fname)]); 
% disp(['created overlap volume    : ',fullfile(ss.swd,VO(1).fname)]); 

ss.estimate=struct('BETA',VB,'OVERLAP',VO,'beta',Bplane,'rss',Eplane,'whitening',Cplane,'overlap',Oplane,'voxels',Nplane,'coverage',Pplane,'qa',Mplane,'y',Zplane); 
% ss.estimate=struct('BETA',VB,'RSS',VE,'OVERLAP',VO,'beta',Bplane,'rss',Eplane,'whitening',Cplane,'overlap',Oplane,'voxels',Nplane,'coverage',Pplane,'qa',Mplane,'y',Zplane); 
save(fullfile(ss.swd,['SPM_ss',extname,'.mat']),'ss');
disp(['Analysis file saved: ',fullfile(ss.swd,['SPM_ss',extname,'.mat'])]);

fname=['spm_ss',extname,'_data.csv'];
fh=fopen(fullfile(ss.swd,fname),'wt');
fprintf(fh,'Data\n');
fprintf(fh,'ROI#,ROI size,average localizer mask size,inter-subject overlap,');
for ns=1:ss.n,for ne=1:Nb(2),fprintf(fh,'Subject#%d[%d]',ns,ne); if ne<Nb(2)||ns<ss.n, fprintf(fh,','); else fprintf(fh,'\n'); end; end; end
for nroi=1:nrois,
    fprintf(fh,'%d,%d,%d,%f,',nroi,round(ss.estimate.voxels(nroi)),round(ss.estimate.voxels(nroi)*ss.estimate.coverage(nroi)),ss.estimate.overlap(nroi));
    for ns=1:ss.n, for ne=1:Nb(2),fprintf(fh,'%f',Zplane(ns,ne,nroi)); if ne<Nb(2)||ns<ss.n, fprintf(fh,','); else fprintf(fh,'\n'); end; end; end
end
fprintf(fh,'\nWeights\n');
fprintf(fh,'ROI#,');
for ns=1:ss.n,fprintf(fh,'Subject#%d',ns); if ns<ss.n, fprintf(fh,','); else fprintf(fh,'\n'); end; end;
for nroi=1:nrois,
    fprintf(fh,'%d,',nroi);
    for ns=1:ss.n, fprintf(fh,'%f',Cplane(ns,nroi)); if ns<ss.n, fprintf(fh,','); else fprintf(fh,'\n'); end; end;
end
fprintf(fh,'\nquality control (localizer mask sizes)\n');
fprintf(fh,'Subject#,Session/Partition#,filename'); for nroi=1:nrois,fprintf(fh,',ROI#%d',nroi);end;fprintf(fh,'\n');
nidxs=zeros(ss.n,1);
for nf=1:size(ss.estimate.qa,1),
    [nill,idxs]=max(ss.PV(:,nf));
    nidxs(idxs)=nidxs(idxs)+1;
    fprintf(fh,'%d,%d,%s',idxs,nidxs(idxs),ss.PN{nf});
    for nroi=1:nrois,fprintf(fh,',%d',round(ss.estimate.qa(nf,nroi)));end
    fprintf(fh,'\n');
end
fclose(fh);

% estimates defined contrasts
ss=spm_ss_contrast_ROI(ss);
cd(cwd);

end

