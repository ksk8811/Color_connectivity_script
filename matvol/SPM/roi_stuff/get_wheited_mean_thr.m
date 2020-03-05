function [Y varargout] = get_wheited_mean_thr(fa,fcon,par)

if ~exist('par'),par ='';end

defpar.seuil = 0; %roi threshold
defpar.seuilinf = 0; %fa min threshold
defpar.seuilsup = 1; %fa max threshold

par = complet_struct(par,defpar);

seuil=par.seuil;

%at the subject level
fcon = cellstr(char(fcon));

Y = zeros(length(fa),length(seuil));

for i=1:length(fa)
     
    [FAimg,dimes,vox]=read_avw(fa{i});
    [Conimg,dimes,vox]=read_avw(fcon{i});

    ind = (Conimg> par.seuil) & (FAimg < par.seuilsup) & (FAimg > par.seuilinf) ;

    Y(i,:) = sum(FAimg(ind).*Conimg(ind))./sum(Conimg(ind));
    if nargout>1
        %fprintf('comput std\n')
        Ystd(i) = std(FAimg(ind));
    end
end

if nargout>1
    varargout{1} = Ystd;
end

