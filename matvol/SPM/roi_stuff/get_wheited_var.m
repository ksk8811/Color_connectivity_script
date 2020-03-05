function Y=get_wheited_var(fa,fcon,par)

if ~exist('par'),par ='';end

defpar.seuil = 0;

par = complet_struct(par,defpar);

seuil=par.seuil;

%at the subject level
fcon = cellstr(char(fcon));

Y = zeros(length(fa),length(seuil));

for i=1:length(fa)
    tt=zeros(1,length(seuil));
    %     [FAimg,dimes,vox]=read_avw(fa{i});
    %     for j=1:length(fcon)
    %         [Conimg,dimes,vox]=read_avw(fcon{j});
    %         Y(i,j) = sum(FAimg(Conimg>seuil).*Conimg(Conimg>seuil))./sum(Conimg(Conimg>seuil));
    %     end
    
    %try to find a save struct
    [pp fn]= get_parent_path(fa(i))
    
    [FAimg,dimes,vox]=read_avw(fa{i});
    [Conimg,dimes,vox]=read_avw(fcon{i});
    
    for kk =1:length(seuil)
        %tt(kk) = sum(FAimg(Conimg>seuil(kk)).*Conimg(Conimg>seuil(kk)))./sum(Conimg(Conimg>seuil(kk)));
        tt(kk) = std(FAimg(Conimg>seuil(kk)));
        
    end
    Y(i,:) = tt;
end
