function ons = get_spm_ons(SPM)

Sess=SPM.Sess;
nscan = SPM.nscan;
TR = SPM.xY.RT;

if strcmp(SPM.xBF.UNITS,'scans')
fprintf('\nconvertion to second\n')

    for ks=1:length(Sess)
        for nr = 1:length(Sess(ks).U)
            Sess(ks).U(nr).ons = Sess(ks).U(nr).ons * TR;
            Sess(ks).U(nr).dur = Sess(ks).U(nr).dur * TR;
        end
    end
end
        
ons = Sess(1).U;

for k=1:length(ons)
  tv = nscan(1)*TR;
  name= ons(k).name{1};
  
  for ns=2:length(Sess)
    
    oo=Sess(ns).U;
    
    for ko = 1:length(oo)
      if strcmp(name,oo(ko).name{1})
	ons(k).ons = [ons(k).ons;oo(ko).ons+tv];
	break
      end      
    end
    tv = tv + nscan(ns)*TR;
    
  end
end

    
%add regresseur from other session which have different name than in the first_session

tv = nscan(1)*TR;

for ns=2:length(Sess)
  
  oo=Sess(ns).U;
  
  for nr=1:length(oo)
    name = oo(nr).name{1};
    new=1;
    for ko=1:length(ons)
      if strcmp(ons(ko).name{1},name)
	new=0;
      end
    end
    
    if new
      ons(end+1) = oo(nr);
      ons(end).ons = ons(end).ons + tv;
    end
    
  end

  tv = tv + nscan(ns)*TR;
  
end