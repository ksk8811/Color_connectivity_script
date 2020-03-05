

if ~exist('param_file');
    param_file='';
    get_user_param;parameters.logfile='';
end
p=parameters;

t_resamp = 16;
duration = 32;
do_plot=1;
plot_all=0;

if ~exist('roi_path')
    roi_path=spm_select(inf,'mat','select a roi');
end

for nroi=1:size(roi_path,1)
    
    roi= maroi('load', roi_path(nroi,:))
    
    
    for nsuj=1:length(parameters.subjects)
        params = parameters;
        
        %- Change varialbles that are subject specific
        %----------------------------------------------------------------------
        %params.subjectdir = fullfile(parameters.rootdir,parameters.subjects{nsuj});
        params.subjectdir = parameters.subjects{nsuj};
        %params.funcdirs = parameters.funcdirs{nsuj};
        %if iscell(parameters.anatdir)
        %  params.anatdir = parameters.anatdir{nsuj};
        %end
        
        wd = fullfile(params.subjectdir,'stats');
        statdir = fullfile(wd,params.modelname);
        if ~exist(statdir,'dir'),     error('you must run the firstlevel first');    end
        
        load (fullfile(statdir,'SPM.mat'));
        D=mardo_5(SPM);
        
        %P = image_names(D);%    P = strvcat(P{:});
        
        Y= get_marsy(roi, D, 'mean');
        fY = apply_filter(D, Y);
        fYnw = apply_filter(D, Y, {'no_whitening'});
        
        sY = summary_data(fYnw);
        %sY = summary_data(Y);
        %sY = sY./mean(sY);
        
        TR=SPM.xY.RT;
        tons = ( 0:1/t_resamp:(duration) )*TR;
        
        onss = get_spm_ons(SPM); %onss(end)=[];onss(end)=[];
        
        % s2=resample(s1,t_resamp,1);
        % perfer a more linear interpolation
        s2=interp(sY,t_resamp,1,0.01);
        
        if plot_all
        xx=SPM.xX.X;
        for k = 1:4
            figure 
            hold on 
            plot(sY((1+(k-1)*160) : k*160)./sY((1+(k-1))*160));
            plot(1+xx((1+(k-1)*160) : k*160,k)./mean(xx((1+(k-1)*160) : k*160,k)) ./1000,'r')
        end
        end
        % nscan = SPM.nscan;
        % t2=1:1/t_resamp:(sum(nscan)+(t_resamp-1)/t_resamp);
        
        for nreg=1:length(onss)
            
            ons=onss(nreg).ons / TR * t_resamp;
            ons = round(ons);
            
            clear tt;
            ssreg = SPM.xX.X(:,nreg)';
            sreg=interp(ssreg,t_resamp,1,0.01);
            %remove the last onset il duration is too high
            while (ons(end)+duration*t_resamp>sum(SPM.nscan*t_resamp))
                ons(end)=[];
            end
            
            for k=1:length(ons)
                tt(k,:) = s2(ons(k):(ons(k)+duration*t_resamp));
                tt_reg(k,:) = sreg(ons(k):(ons(k)+duration*t_resamp));
            end
            
            legend_str{nreg} = onss(nreg).name{1};
            
            mean_sig(nreg,:) = mean(tt,1);
            %mean_sig(nreg,:) = mean_sig(nreg,:) ./ mean(mean_sig(nreg,:));%moyen a 1            
            mean_sig(nreg,:) = mean_sig(nreg,:) ./(mean_sig(nreg,1));
            mean_reg(nreg,:) = mean(tt_reg,1); %mean_reg(nreg,:) = mean_reg(nreg,:) ./mean(mean_reg(nreg,:) );
            
        end
        
        roi_suj_mean_sig(nroi,nsuj,:,:) = mean_sig;
        roi_suj_mean_name(nroi,nsuj).suj_name = parameters.subjects{nsuj};
        roi_suj_mean_name(nroi,nsuj).roi_name = label(roi);
        roi_suj_mean_name(nroi,nsuj).reg_name = legend_str;
        roi_suj_mean_name(nroi,nsuj).tons = tons;

        if do_plot
            
            figure
            hold on
            
            num_plot=size(mean_sig,1);
            if num_plot<=3,  all_color=[0 0 1;0 1 0;1 0 0];else  all_color=jet(num_plot);end
            
            for np=1:num_plot
                h = plot(tons,mean_sig(np,:));
                
                set(h,'color',all_color(np,:))
            end
            
            title(parameters.subjects{nsuj})
            legend(legend_str)
            
%             figure
%             for np=1:num_plot
%                 h = plot(tons,mean_reg(np,:));
%                 set(h,'color',all_color(np,:))
%             end
%             
%             title(parameters.subjects{nsuj})
%             legend(legend_str)
           
        end
        
    end
    
end

if 1
    for nbroi=1:size(roi_suj_mean_name,1)
        for nsuj=1:size(roi_suj_mean_name,2)
            figure
            hold on
            num_plot=size(roi_suj_mean_sig,3);
            if num_plot<=3,  all_color=[0 0 1;0 1 0;1 0 0];else  all_color=jet(num_plot);end
            for np=1:num_plot
                h = plot(tons,squeeze(roi_suj_mean_sig(nbroi,nsuj,np,:)));
                set(h,'color',all_color(np,:))
            end
            title([roi_suj_mean_name(nbroi,nsuj).suj_name ,' ',roi_suj_mean_name(nbroi,nsuj).roi_name ] );
            legend(roi_suj_mean_name(nbroi,nsuj).reg_name)
            
            
        end
    end
    
end
