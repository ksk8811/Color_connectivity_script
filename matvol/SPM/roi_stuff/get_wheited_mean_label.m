function [cout, cmat] = get_wheited_mean_label(fa,fcon,par)

if ~exist('par'),par ='';end

defpar.seuil = '';
defpar.faname = '';
defpar.sujname = '';
defpar.roiname = 'freesurfer';
defpar.std=0;

par = complet_struct(par,defpar);

seuil=par.seuil;

%at the subject level
fcon = cellstr(char(fcon));

if isempty(getenv('FREESURFER_HOME'))
    setenv('FREESURFER_HOME','/usr/cenir/src/freesurfer5.3.0-centos6_x86_64')
end

[code, name, rgbv] = my_read_fscolorlut();



cout.pool = '1';
if isempty(par.sujname)
    [pp par.sujname] = get_parent_path(fcon,3);
end

cout.suj = par.sujname;

for i=1:length(fa)
    
    ffas = cellstr(fa{i});
    
    if isempty(par.faname)
        [pp ff] = get_parent_path(change_file_extension(ffas,''));
        par.faname = ff;
    end
    
    for nbfa = 1:length(ffas)
        [FAimg(:,:,:,nbfa),dimes,vox]=read_avw(ffas{nbfa});
    end
    
    [Conimg,dimes,vox]=read_avw(fcon{i});
    
    if isempty(par.seuil)
        seuil = unique(Conimg); %tous les label de l'image
        seuil(seuil==0)=[];%implicite mask .
    else
        seuil = par.seuil
    end
    
    for kk =1:length(seuil)
        switch par.roiname
            case 'freesurfer'
                con_name = nettoie_dir( name{code==seuil(kk)} );
            otherwise
                con_name = sprintf('%s%.2d',par.roiname,seuil(kk));
        end
        
        if ismember(con_name(1),'0123456789'), con_name=['a' con_name];end
        for nbfa = 1:length(ffas)
            oneFAimg = FAimg(:,:,:,nbfa);
            %Y = sum(oneFAimg(Conimg==seuil(kk)).*Conimg(Conimg==seuil(kk)))./sum(Conimg(Conimg==seuil(kk)))
            %Vol = length(find(Conimg(Conimg==seuil(kk))));
            Y = mean(oneFAimg(Conimg==seuil(kk)));
            Ystd = std(oneFAimg(Conimg==seuil(kk)));
            
            fieldname = [con_name '_' par.faname{nbfa} ] ;
            
            if isfield(cout,fieldname),  vv = getfield(cout,fieldname); end
            vv(i) = Y;
            cout = setfield(cout,fieldname,vv);
            
            if par.std
            fieldname = [con_name '_std_' par.faname{nbfa} ] ;
            
            if isfield(cout,fieldname),  vv = getfield(cout,fieldname); end
            vv(i) = Ystd;
            cout = setfield(cout,fieldname,vv);
            end
        end
        
    end
    
end

if nargout==2
    ff=fieldnames(cout);
    ff(1:2)='';
    if par.std
        amean=[];
        for k=1:2:length(ff)
            amean(:,end+1) = cout.(ff{k});
        end
        astd = [];
        for k=2:2:length(ff)
            astd(:,end+1) = cout.(ff{k});
        end
        
        cmat.mean = amean;
        cmat.std = astd;
        cmat.label = ff(1:2:end);
    end
end
