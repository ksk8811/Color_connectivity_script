
function coutAll = get_slice_mean_struct(in_dir,par)

if ~exist('par','var'),par ='';end

defpar.skip = 0;
defpar.do_plot = 0;
defpar.save_plot=1;
defpar.skip_slice=[];
defpar.select_img = '^f';
defpar.do_covariance = 0;
defpar.outdir = '';
defpar.subdir = '';
defpar.seuil = 0.2;
defpar.do_delete = 0;
defpar.save_qc_struct_file = 'qc_struct.mat';
defpar.dorealign=1;
defpar.realign_write_interp =0;
defpar.redo=0;
defpar.bvals = '';
defpar.mask = '';

par = complet_struct(par,defpar);

seuil = par.seuil
skip = par.skip;
do_plot = par.do_plot;
skip_slice = par.skip_slice;
do_covariance = par.do_covariance;
numstd = seuil;
first_slice=1;


if ~exist('in_dir')
    in_dir = get_subdir_regex;
end

if ischar(in_dir)
    in_dir=cellstr(in_dir);
end


for nbdir=1:length(in_dir)
    
    if ~isempty(par.outdir)
        outdir = par.outdir{nbdir};
    else
        if ~isempty(par.subdir);
            outdir = r_mkdir(in_dir{nbdir},par.subdir);outdir=outdir{1};
        else
            outdir = in_dir{nbdir};
        end
    end
    
    save_qc_struct = fullfile(outdir,par.save_qc_struct_file);
    if exist (save_qc_struct,'file')
        if par.redo==0
            load(save_qc_struct)
            coutAll(nbdir) = cout;
            continue
        end
    end
    
    if findstr('.',par.select_img) %sinon le addsuffi ne marche pas
        ff = get_subdir_regex_files(in_dir(nbdir),par.select_img);
    else
        ff = get_subdir_regex_images(in_dir(nbdir),par.select_img);
    end
    
    %get skip from bval if exist
    if ~isempty(par.bvals)
        bval = get_subdir_regex_files(in_dir(nbdir),par.bvals,1);
        b=load(bval{1});
        
        skip=find(b<100);
        
    end
    
    %%%%%%%%copy if needed and do realign
    [ppp fff ext] = fileparts(deblank(ff{1}(1,:)));
    if ~isempty(par.outdir)
        outdir = par.outdir{nbdir};
        if strcmp(ext,'.img')
            ff=r_movefile(ff,outdir,'linkn');
            fhdr = get_subdir_regex_files(in_dir(nbdir),'^f.*hdr');
            fhdr = r_movefile(fhdr,outdir,'copyn');
        else
            ff=r_movefile(ff,outdir,'copyn');
        end
        
    end
    
    [ppp fff ext] = fileparts(deblank(ff{1}(1,:)));
    if strcmp(ext,'.gz'),        ff=unzip_volume(ff);   fforig=ff; end
    
    if par.dorealign
        ppar.realign.write_interp = par.realign_write_interp ;
        ppar.realign.type = 'mean_and_reslice'; ppar.redo=0;
        j = do_realign(ff,ppar)
        if ~isempty(j), spm_jobman('run',j);end
        
        frp = get_subdir_regex_files(outdir,'^rp.*txt');
        rp=load(frp{1});
        drp = diff(rp);
        
        if par.do_delete
            if  ~isempty(par.outdir)
                do_delete(ff,0);
                if strcmp(ext,'.img'),     do_delete(fhdr,0);      end
            end
        end
        fforig=ff;
        ff = addprefixtofilenames(ff,'r');
        if  ~isempty(par.outdir)
            if strcmp(ext,'.img'),     fhdr =addprefixtofilenames(fhdr,'r');      end
        end
        
    end
    ff = cellstr(char(ff));
    
    %%%%%%%%%%%%%%%%%%%%
    save_mean_mat = fullfile(outdir,'slice_means.mat');
    if exist (save_mean_mat,'file')
        load(save_mean_mat)
    else
        VY= spm_vol(char(ff));
        
        if length(VY)<=1
            fprintf('skip serie single volume %s\n',in_dir{nbdir});
            continue
        end
        
        num_vol = 1:length(VY);
        
        
        dd = dir(in_dir{nbdir});
        dirdat = dd(1).date;
        
        VYok=VY;
        if length(VY)>length(ff) %for the 4D files
            for k=1:length(VY)
                VY(k).fname = [VY(k).fname ',' num2str(k)];
            end
        end
        
        if skip
            VYskip = VY(skip);
            VY(skip)=''; VYok(skip)='';
            num_vol(skip)='';
        end
        %arggg
        % si pas de mask VY=VYok; mais poss

        if isempty(par.mask)
            Automask = zeros(VY(1).dim);
            for k=1:length(VY)
                Automask = art_automask(VY(k).fname,-1,0) + Automask;
            end
            Automask(Automask>1)=1;
            
            %ajoute le mask générer par la B0 (pour les yeux)
            if skip
                for k=1:length(VYskip)
                    Automask = art_automask(VYskip(k).fname,-1,0) + Automask;
                end
                Automask(Automask>1)=1;
            end
            
            %arggg
            VY=VYok;

            [indartV indartS] = do_art_slice(VY,10);
            
            %Automask = art_automask(VY(1).fname,-1,0);
            M = Automask; skip_slice=[];
            for kk=1:size(Automask,3)
                [i j v] = find(Automask(:,:,kk));
                mini = min(i)-3; maxi = max(i)+3;
                if mini<1,mini=min(i); end
                if maxi>size(Automask,1), maxi = max(i);end
                %M(mini:maxi,:,kk) = 1;
                
                minj = min(j)-3; maxj = max(j)+3;
                if minj<1,minj=min(j); end
                if maxj>size(Automask,2), maxj = max(j);end
                M(mini:maxi,minj:maxj,kk) = 1;
                
                mask_size(kk) = length(find(M(:,:,kk)));
                brain_size(kk) = length(find(Automask(:,:,kk)));
                if mask_size(kk) <100
                    skip_slice(end+1) = kk;
                end
                
            end
            %skip the first and the last slice (
            skip_slice = [skip_slice 1 size(Automask,3)];
            
            mV = VY(1);
            mV.fname = fullfile(outdir,'brain_mask_all.nii');
            mV=rmfield(mV,'pinfo');mV=rmfield(mV,'n'); %for 4d volume those remaining info are wrong
            
            spm_write_vol(mV,Automask);
            
            mV.fname = fullfile(outdir,'brain_mask_qc.nii');
            spm_write_vol(mV,M);
            
            Automask = M;
            
            if ~isempty(par.subdir)
                %mv automask
                try
                    fautom = get_subdir_regex_files(ppp,'ArtifactMask',1)
                    r_movefile(fautom,outdir,'move')
                catch
                    fprintf('No ArtifactMask created\n')
                end
            end
        else
            fmask = get_subdir_regex_files(in_dir(nbdir),par.mask,1);
            [h Automask] = nifti_spm_vol(fmask{1});
            indartV =''; indartS='';
            for kka=1:size(Automask,3)
                
                brain_size(kka) = length(find(Automask(:,:,kka)));
            end
            mask_size=brain_size;
            %arggg
            VY=VYok;

        end
        slice_mean = zeros(length(first_slice:VY(1).dim(3)),length(VY));
        slice_mean_fond = slice_mean;slice_var_fond = slice_mean;
        
        for nb_vol=1:length(VY)
            for j = first_slice:VY(nb_vol).dim(3)
                if  any(skip_slice==j) %skip slice are constant value
                    slice_mean(j,nb_vol) = 1;
                    slice_mean_fond(j,nb_vol) = 1;
                    slice_var_fond(j,nb_vol) = 1;
                else
                    
                    Mi      = spm_matrix([0 0 j]);
                    X       = spm_slice_vol(VY(nb_vol),Mi,VY(nb_vol).dim(1:2),0);
                    Xfond = X .*(1-Automask(:,:,j));
                    %Xbrain = X .*(Automask(:,:,j));
                    slice_mean(j,nb_vol) = mean(X(:));
                    if slice_mean(j,nb_vol) == 0 % append for rf volume
                        slice_mean(j,nb_vol) = 1;
                        slice_mean_fond(j,nb_vol) = 1;
                        slice_var_fond(j,nb_vol) = 1;
                    else
                        
                        slice_mean_fond(j,nb_vol) = mean(Xfond(Xfond>0));
                        %                 slice_mean_brain(j,nb_vol) = mean(Xbrain(Xbrain>0));
                        slice_var_fond(j,nb_vol) = std(Xfond(Xfond>0));
                        %slice_rician(j,nb_vol) = RicianSTD2D(X);
                    end
                end
            end
        end
        
        save(save_mean_mat,'slice_mean','slice_mean_fond','slice_var_fond','skip_slice',...
            'indartV','indartS','mask_size','brain_size','skip','num_vol','VY')
    end
    
    
    if do_covariance
        [allmeancov ind2V ind2S indallV] =  get_vol_covariance(VY,numstd,first_slice);
    end
    
    %delete realign data
    if par.do_delete
        do_delete(ff,0)
        if strcmp(ext,'.img'),     do_delete(fhdr,0);      end
    end
    
    %your are finish with reading orig data
    if strcmp(ext,'.gz')
        gzip_volume(fforig);
    end
    
    
    bb   = nanstd(slice_mean(first_slice:end,:),0,2);
    bbmf = nanstd(slice_mean_fond(first_slice:end,:),0,2);
    bbvf = nanstd(slice_var_fond(first_slice:end,:),0,2);
    
    Mbb   = nanmean(nanmean(slice_mean(first_slice:end,:)));
    Mbbmf = nanmean(nanmean(slice_mean_fond(first_slice:end,:)));
    Mbbvf = nanmean(nanmean(slice_var_fond(first_slice:end,:)));
    
    %skip slice, just put a unique value, so no variation
    slice_mean(skip_slice,:) = 1;
    slice_mean_fond(skip_slice,:) = 1;
    slice_var_fond(skip_slice,:) = 1;
    
    aa=mean(slice_mean,2);        aa=repmat(aa,[1, size(slice_mean,2)]);
    slice_mean = slice_mean./aa;
    aa=mean(slice_mean_fond,2);        aa=repmat(aa,[1, size(slice_mean_fond,2)]);
    slice_mean_fond = slice_mean_fond./aa;
    aa=mean(slice_var_fond,2);        aa=repmat(aa,[1, size(slice_var_fond,2)]);
    slice_var_fond = slice_var_fond./aa;
    %         aa=mean(slice_mean_brain,2);        aa=repmat(aa,[1, size(slice_mean_brain,2)]);
    %         slice_mean_brain = slice_mean_brain./aa;
    
    
    
    [indSpos,indVpos,v]=find(slice_mean>(1+seuil));
    [indSneg,indVneg,v]=find(slice_mean<(1-seuil));
    
    [indS_mean_fond_pos,indV_mean_fond_pos,v]=find(slice_mean_fond>(1+seuil));
    [indS_mean_fond_neg,indV_mean_fond_neg,v]=find(slice_mean_fond<(1-seuil));
    [indS_var_fond,indV_var_fond,v]=find(slice_var_fond>(1+seuil));
    
    %find slice with big up and down mean
    indV_meandiff =[] ;
    for nbv=1:size(slice_mean,2)
        indup = find(diff(slice_mean(:,nbv))>0.03);
        inddonw = find(diff(slice_mean(:,nbv))<0.03);
        if length(find(diff(inddonw)==2))>5 &&  length(find(diff(indup)==2))>5 %alternate of + -
            indV_meandiff(end+1) = nbv;
        end
    end
    
    %get_indice before skiping B0
    %         indVokpos = num_vol(indVpos);        indVokneg = num_vol(indVneg);
    %         indVok_mean_fond_pos = num_vol(indV_mean_fond_pos) ; indVok_mean_fond_neg = num_vol(indV_mean_fond_neg) ;
    %         indVok_var_fond = num_vol(indV_var_fond) ;
    %         indartVok = num_vol(indartV);
    %
    if do_covariance
        %ind2Vok = num_vol(ind2V);
        Uind2V = unique(ind2V);
    end
    
    UindartV = unique(indartV);
    
    UindV = unique([indVpos ;indVneg]);
    UindVneg = unique(indVneg);        UindVpos = unique(indVpos);
    UindV_mean_fond = unique([indV_mean_fond_pos;indV_mean_fond_neg]);
    UindV_mean_fond_neg = unique(indV_mean_fond_neg);
    UindV_mean_fond_pos = unique(indV_mean_fond_pos);
    
    UindV_var_fond = unique(indV_var_fond);
    
    %[p]=fileparts(in_dir{nbdir});
    [p,f1]=fileparts(in_dir{nbdir});    [p,f2]=fileparts(p);    [p,f3]=fileparts(p);
    try
        f22= f2; %f2(12:end);
        f21=f2(1:10);
    catch
        f22=f2;f21=f2;
    end
    
    cout.protocol   = f3;
    cout.date       = f21;
    %cout.datefile	= dirdat;
    cout.Sujet      = f22;
    cout.Series     = f1;
    
    cout.NumFile	= length(VY);
    cout.NumSlice	= VY(1).dim(3);
    
    cout.V_mFond_all         = length(UindV_mean_fond);
    
    cout.V_mFond_min         = length(UindV_mean_fond_neg);
    cout.V_mFond_min_Slice	 = length(indS_mean_fond_neg);
    cout.V_mFond_max         = length(UindV_mean_fond_pos);
    cout.V_mFond_max_Slice	 = length(indS_mean_fond_pos);
    
    cout.V_mDiff_stride   = length(indV_meandiff);
    
    cout.meanVmean      = Mbb;
    cout.meanVstd       = median(bb);
    cout.maxVsdt        = max(bb);
    cout.mean_meanFond	= Mbbmf;
    cout.mean_stdFond	= median(bbmf);
    cout.max_stdFond    = max(bbmf);
    cout.mean_VstdFond	= Mbbvf;
    cout.mean_stdVarfond= median(bbvf);
    cout.max_stdVarfond	= max(bbvf);
    
    %mvt parma
    if par.dorealign
        cout.mvt_trans_max = max(max(abs(rp(:,1:3))));
        cout.mvt_rot_max = max(max(abs(rp(:,4:6))));
        cout.mvt_diff_trans_max = max(max(abs(drp(:,1:3))));
        cout.mvt_diff_rot_max = max(max(abs(drp(:,4:6))));
        cout.mvt_nb_diff_sup1mm = length(find(max(abs(drp),[],2)>1));%mvt diff sup to 1
    else
        cout.mvt_trans_max = 0;
        cout.mvt_rot_max = 0;
        cout.mvt_diff_trans_max = 0;
        cout.mvt_diff_rot_max = 0;
        cout.mvt_nb_diff_sup1mm = 0;
    end
    
    if do_covariance
        %fprintf(fid,',%d,%d',length(Uind2V),length(ind2S));
    end
    
    cout.VolArt              = length(UindartV);
    cout.SliceArt            = length(indartS);
    
    cout.V_varFond           = length(UindV_var_fond);
    cout.V_varFond_Slice     = length(indS_var_fond);
    
    cout.V_mTot              = length(UindV);
    cout.V_mTot_min          = length(UindVneg);
    cout.V_mTot_min_Slice    = length(indSneg);
    cout.V_mTot_max          = length(UindVpos);
    cout.V_mTot_max_Slice    = length(indSpos);
    
    
    [v,i]= min(slice_mean,[],1) ;
    [vv iimin]=min(v);
    [vv jjmin] = min(slice_mean(:,iimin));
    
    [v,i]= max(slice_mean,[],1) ;
    [vv iimax]=max(v);
    [vv jjmax] = max(slice_mean(:,iimax));
    
    
    cout.the_worst_Vtotmin 	= sprintf('min V%d_S%d=%.2f',num_vol(iimin),jjmin,slice_mean(jjmin,iimin));
    cout.the_worst_Vtotmax	= sprintf('max V%d_S%d=%.2f',num_vol(iimax),jjmax,slice_mean(jjmax,iimax));
    
    cc='';    for kk=1:length(indS_mean_fond_pos)
        cc =sprintf('%s V%d_S%d=%.2f ;',cc,num_vol(indV_mean_fond_pos(kk)),indS_mean_fond_pos(kk),slice_mean_fond(indS_mean_fond_pos(kk),indV_mean_fond_pos(kk)));end
    
    cout.Vol_mFond_max	    = cc;
    
    cc='';    for kk=1:length(indS_mean_fond_neg)
        cc=sprintf('%s V%d_S%d=%.2f ;',cc,num_vol(indV_mean_fond_neg(kk)),indS_mean_fond_neg(kk),slice_mean_fond(indS_mean_fond_neg(kk),indV_mean_fond_neg(kk)));end
    
    cout.Vol_mFond_min 	    =cc;
    
    
    cc=''; for kk=1:length(indSpos)
        cc = sprintf('%s V%d_S%d=%.2f ;',cc,num_vol(indVpos(kk)),indSpos(kk),slice_mean(indSpos(kk),indVpos(kk)));        end
    cout.Vol_mTot_max       = cc;
    
    cc='';    for kk=1:length(indSneg)
        cc=sprintf('%s V%d_S%d=%.2f ;',cc,num_vol(indVneg(kk)),indSneg(kk),slice_mean(indSneg(kk),indVneg(kk)));        end
    cout.Vol_mTot_min	    = cc;
    
    
    cc='';    for kk=1:length(indS_var_fond)
        cc=sprintf('%s V%d_S%d=%.2f ;',cc,num_vol(indV_var_fond(kk)),indS_var_fond(kk),slice_var_fond(indS_var_fond(kk),indV_var_fond(kk)));end
    
    cout.Vol_varFond	    =cc;
    
    cc='';    for kk=1:length(indartS)
        cc=sprintf('%s V%d_S%d=%.2f ;',cc,num_vol(indartV(kk)),indartS(kk),slice_mean_fond(indartS(kk),indartV(kk))); end
    cout.Vol_art 			=cc;
    
    
    mem.Vol_mFond_max_ind	= num_vol(indV_mean_fond_pos);
    mem.Vol_mFond_min_ind 	= num_vol(indV_mean_fond_neg);
    mem.Vol_mTot_max_ind   = num_vol(indVpos);
    mem.Vol_mTot_min_ind   = num_vol(indVneg);
    
    if do_covariance
        %         for kk=1:length(ind2S)
        %             fprintf(fid,' V%3d_S%3d=%.2f ;',num_vol(ind2V(kk)),ind2S(kk),slice_mean(ind2S(kk),ind2V(kk)));
        %         end
        %         fprintf(fid,',');
    end
    
    
    mem.indV_art   = UindartV;
    mem.indV_mFond_all   = UindV_mean_fond;
    mem.indV_var_fond = UindV_var_fond;
    mem.indV_mTot = UindV;
    mem.seuil=seuil;
    mem.mask_size = mask_size;
    mem.brain_size = brain_size;
    mem.skip = skip;
    mem.num_vol = num_vol;
    
    cout.mem = mem;
    
    if do_plot
        figure
        set(gcf,'Position',[ 779          67        1138        1057])
        
        subplot(3,1,1);            plot(slice_mean_fond);          title('mean fond'); xlabel('slice');grid on;
        subplot(3,1,2);            plot(slice_mean_fond');         title('mean fond');xlabel('volume'); grid on;
        subplot(3,1,3);            imagesc(slice_mean_fond,[1-seuil 1+seuil]);       ylabel('slice');xlabel('volume')
        hold on
        plot(num_vol(indV_mean_fond_pos),indS_mean_fond_pos,'xb');plot(num_vol(indV_mean_fond_pos),indS_mean_fond_pos,'ob')
        plot(num_vol(indV_mean_fond_neg),indS_mean_fond_neg,'xr');plot(num_vol(indV_mean_fond_neg),indS_mean_fond_neg,'or')
        
        [ee ss] = get_parent_path({outdir});
        fname = fullfile(ee{1},['fig_slice_mFond_' ss{1}])
        title(fname)
        
        if par.save_plot
            
            subplot(3,1,1);set(gca,'YLimMode','manual','YTickLabelMode','manual','YTickMode','manual');
            subplot(3,1,2);set(gca,'YLimMode','manual','YTickLabelMode','manual','YTickMode','manual');
            % subplot(3,1,3);set(gca,'YLimMode','manual','YTickLabelMode','manual','YTickMode','manual');
            %print( gcf, '-djpeg100','-r 300','-append',fname);
            print( gcf, '-djpeg100','-r 300',fname);
            
            close(gcf);
        end
        
        if do_plot>1
            figure
            set(gcf,'Position',[ 779          67        1138        1057])
            
            subplot(3,1,1);            plot(slice_mean);          title('mean tot'); xlabel('slice');grid on;
            subplot(3,1,2);            plot(slice_mean');         title('mean tot');xlabel('volume'); grid on;
            subplot(3,1,3);            imagesc(slice_mean,[1-seuil 1+seuil]);       ylabel('slice');xlabel('volume')
            hold on
            plot(num_vol(indVpos),indSpos,'xb');plot(num_vol(indVpos),indSpos,'ob')
            plot(num_vol(indVneg),indSneg,'xr');plot(num_vol(indVneg),indSneg,'or')
            
            
            [ee ss] = get_parent_path({outdir});
            fname = fullfile(ee{1},['fig_slice_mTot_' ss{1}])
            title(fname)
            
            if par.save_plot
                
                subplot(3,1,1);set(gca,'YLimMode','manual','YTickLabelMode','manual','YTickMode','manual');
                subplot(3,1,2);set(gca,'YLimMode','manual','YTickLabelMode','manual','YTickMode','manual');
                % subplot(3,1,3);set(gca,'YLimMode','manual','YTickLabelMode','manual','YTickMode','manual');
                %print( gcf, '-djpeg100','-r 300','-append',fname);
                print( gcf, '-djpeg100','-r 300',fname);
                
                close(gcf);
            end
            
            if do_plot>2
                figure
                set(gcf,'Position',[ 779          67        1138        1057])
                
                subplot_tight(3,1,1,[0.03 0.03]);        hold on
                plot(num_vol(indartV),indartS,'.g');
                plot(num_vol(indVpos),indSpos,'ob');            plot(num_vol(indVneg),indSneg,'or')
                plot(num_vol(indV_mean_fond_pos),indS_mean_fond_pos,'*b');        plot(num_vol(indV_mean_fond_neg),indS_mean_fond_neg,'*r');
                grid on;legend({'art','MtP','MtN','MfP','MfN'},'Location','WestOutside')
                
                subplot_tight(3,1,2,[0.03 0.03]);
                %plot(num_vol,rp(:,1:3))
                plotyy(num_vol,rp(:,1:3),num_vol,rp(:,4:6))
                grid on; legend({'tx','ty','tz','a1','a2','a3'},'Location','WestOutside')
                %title('translation rotation')
                hold on
                yy = get(gca,'ylim');
                for kv=1:length(indV_meandiff)
                    plot([indV_meandiff(kv) indV_meandiff(kv)],yy,'--')
                end
                
                subplot_tight(3,1,3,[0.1 0.03]);            imagesc(slice_mean,[1-seuil 1+seuil]);       ylabel('slice');xlabel('volume')
                
                if par.save_plot
                    [ee ss] = get_parent_path({outdir});
                    fname = fullfile(ee{1},['fig_slice_mvt_' ss{1}])
                    title(fname)
                    
                    %subplot(3,1,1);set(gca,'YLimMode','manual','YTickLabelMode','manual','YTickMode','manual');
                    %subplot(3,1,2);set(gca,'YLimMode','manual','YTickLabelMode','manual','YTickMode','manual');
                    % subplot(3,1,3);set(gca,'YLimMode','manual','YTickLabelMode','manual','YTickMode','manual');
                    print( gcf, '-djpeg100','-r 300','-append',fname);
                    
                    close(gcf);
                end
                
            end
            
        end
        
    end
    
    
    save(save_qc_struct,'cout');
    coutAll(nbdir) = cout;
end


