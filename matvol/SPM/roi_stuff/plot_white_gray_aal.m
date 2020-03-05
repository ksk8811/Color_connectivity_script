
nbv = size(P,1);
kk=1
for ka=1:length(Yaal_w);

  if length(Yaal_g(ka).nbpts==nbv) &length(Yaal_w(ka).nbpts==nbv)
    if  all(Yaal_g(ka).nbpts) & all(Yaal_w(ka).nbpts) 
    
      Yaal_m_g(kk,:) = Yaal_g(ka).Y' ;
      Yaal_v_g(kk,:) = Yaal_g(ka).Yvar' ;
      
      Yaal_m_w(kk,:) = Yaal_w(ka).Y' ;
      Yaal_v_w(kk,:) = Yaal_w(ka).Yvar' ;
      kk=kk+1;
    end
  end

end

Yaalm_g.Y = mean(Yaal_m_g);
Yaalm_g.Yvar = mean(sqrt(Yaal_v_g));
Yaalm_w.Y = mean(Yaal_m_w);
Yaalm_w.Yvar = mean(sqrt(Yaal_v_w));





if(0==2) %version 2

  figure
  
  for kv=1:length(Yaal_w);

    ind=find(Yaal_w(kv).nbpts<5)
    if ~isempty(ind)
      Yaal_w(kv).Y(ind)=[];
      Yaal_w(kv).Yvar(ind)=[];
      Yaal_w(kv).nbpts(ind)=[];
      Yaal_w(kv).Yvarnorm(ind)=[];
    end
    
    ind=find(Yaal_g(kv).nbpts<5)
    if ~isempty(ind)
      Yaal_g(kv).Y(ind)=[];
      Yaal_g(kv).Yvar(ind)=[];
      Yaal_g(kv).nbpts(ind)=[];
      Yaal_g(kv).Yvarnorm(ind)=[];
    end
    
  end
  
  for kv=1:length(Yaal_w);
    Yaalm_g.Y(kv)     =mean( Yaal_g(kv).Y) ;
    Yaalm_g.Yvar(kv)  =mean(sqrt( Yaal_g(kv).Yvar) ) ;
    Yaalm_g.Yvarn(kv) =mean(sqrt( Yaal_g(kv).Yvarnorm) ) ;

    Yaalm_w.Y(kv)     =mean( Yaal_w(kv).Y) ;
    Yaalm_w.Yvar(kv)  =mean(sqrt( Yaal_w(kv).Yvar) ) ;
    Yaalm_w.Yvarn(kv) =mean(sqrt( Yaal_w(kv).Yvarnorm) ) ;
   
  end
  figure
  subplot(3,2,1)
  plot(Yaalm_g.Y)
  
  subplot(3,2,2)
  plot(Yaalm_w.Y)
  
  subplot(3,2,3)
  plot(Yaalm_g.Yvar)

  subplot(3,2,4)
  plot(Yaalm_w.Yvar)

  subplot(3,2,5)
  plot(Yaalm_g.Yvarn)
    
  subplot(3,2,6)
  plot(Yaalm_w.Yvarn)

end


plot_white_gray_signal_aal(Yw,Yg,Yn,P)

