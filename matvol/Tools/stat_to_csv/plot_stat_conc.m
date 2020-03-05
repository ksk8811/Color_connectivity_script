function plot_stat_conc(c,quantif_todo)


%concstruct a X matrix
if ~exist('quantif_todo') 
  quantif_todo = find_numeric_fields(c);
end
 
%quantif_todo = {'BigSvolseg','ncSseg','ncScon','BigGFA'};
quantif_todo = {'seed_vol'};

grouplength = [length(c(1).seed_vol),length(c(2).seed_vol),length(c(3).seed_vol)];
maxlength=max(grouplength);

Xnan = ones(maxlength,1)*NaN;

for nr=1%:3:length(c)
    
  for kq=1:length(quantif_todo)

    [field_list,field_r] = get_struct_field(c(1),quantif_todo{kq});
    Xall = [];
      
    for numf=1:length(field_list)
      for kgr=1:3
	npool = (nr-1)+kgr;
	
	poolname =c(npool).pool;
	inndd=findstr(poolname,'_'); poolname(inndd)=' '; poolname(inndd(end):end)='';
	poolname =[quantif_todo{kq} ' ' poolname];
	conc = c(npool);

	avec = getfield(conc,field_list{numf});
	Xnew = Xnan;
	Xnew(1:grouplength(kgr),1) = avec;
	Xall = [Xall , Xnew];
	
      end
      
    end
    

    col=repmat(['b','g','r'],1,10);
    
    figure
    %boxplot(Xall,'colors',col,'labels',aa,'notch','on')
    %boxplot(Xall,'colors',col,'labels',aa,'notch','marker')
    boxplot(Xall,'colors',col,'notch','marker')
    
    %boxplot(Xall,'colors',col,'labels',aa,'symbol','ro')
    title(poolname)
    
  end

end


if 0

  c=OUT;
  
  for nr = 1:length(c)
    fas = OUT(nr).gfa_val;

%    for kk=1:5%length(fas)
%      figure      ;      hist(fas{kk},100)
%    end
    
    
    xx = cell2mat_nan(fas);
    
    figure
    boxplot(xx)
    
    xx(xx>0.5) = NaN;
    xx(xx<0.1) = NaN;
    
    figure
    boxplot(xx)
     
  end
  
end
