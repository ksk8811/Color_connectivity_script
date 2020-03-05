function write_res_summary_stat(conc,fid,field_list)


print_each_2_collumn=0;
do_ttest=1;
do_pairedttest=1;
do_annova1 = 1;
do_kruskal=1;
do_normal_test=1;

if do_ttest
    
  fprintf(fid,'Ttest');
  
  for kf = 1:length(field_list)
    fprintf(fid,',%s',field_list{kf});
    if print_each_2_collumn, fprintf(fid,',');end
  end
  
  for npool = 1:length(conc)/2
    n1 = conc(2*npool-1).pool;
    n2 = conc(2*npool).pool;
    
    fprintf(fid,'\n%s/%s',n1,n2);
    
    for kf = 1:length(field_list)
      y1 = getfield(conc(2*npool-1),field_list{kf});
      y2 = getfield(conc(2*npool),field_list{kf});
 
      y1(isnan(y1))='';      y2(isnan(y2))='';
 
      if isempty(y1)|isempty(y2)
	h=0;
      else
	
	[h,p]=ttest2(y1,y2,0.1,'right','unequal');
	
	if isnan(h)
	  h=0;
	else
	  if ~h
	    [h,p]=ttest2(y1,y2,0.1,'left','unequal');
	    if h
	      if p>0.05, str_senc='<'; else,str_senc='<<'; end;
	    end
	  else
	    if p>0.05, str_senc='>';  else, str_senc='>>'; end
	  end
	end
      end
      
      if h
	fprintf(fid,',%s %f',str_senc,p);
      else
	fprintf(fid,',');
      end
 	
      if print_each_2_collumn, fprintf(fid,',');end
     
    end
  end
  fprintf(fid,'\n\n\n');
end 

if do_pairedttest
    
  fprintf(fid,'Paired Ttest');
  
  for kf = 1:length(field_list)
    fprintf(fid,',%s',field_list{kf});
    if print_each_2_collumn, fprintf(fid,',');end
  end
  
  for npool = 1:length(conc)/2
    n1 = conc(2*npool-1).pool;
    n2 = conc(2*npool).pool;
    
    fprintf(fid,'\n%s/%s',n1,n2);
    
    for kf = 1:length(field_list)
      y1 = getfield(conc(2*npool-1),field_list{kf});
      y2 = getfield(conc(2*npool),field_list{kf});
 
      y1(isnan(y1))='';      y2(isnan(y2))='';
 
      if isempty(y1)|isempty(y2) | (length(y1)~=length(y2))
	h=-1;
	fprintf('no paired Ttest for %s\n',field_list{kf});
      else
	
	[h,p]=ttest(y1,y2,0.1,'right');
	
	if isnan(h)
	  h=0;
	else
	  if ~h
	    [h,p]=ttest(y1,y2,0.1,'left');
	    if h
	      if p>0.05, str_senc='<'; else,str_senc='<<'; end;
	    end
	  else
	    if p>0.05, str_senc='>';  else, str_senc='>>'; end
	  end
	end
      end
      
      if h>0
	fprintf(fid,',%s %f',str_senc,p);
      elseif h==-1
	fprintf(fid,',-1');	
      else
	fprintf(fid,',');
      end
 	
      if print_each_2_collumn, fprintf(fid,',');end
     
    end
  end
  fprintf(fid,'\n\n\n');
end 


if do_annova1
    
  fprintf(fid,'Annova');
  
  for kf = 1:length(field_list)
    fprintf(fid,',%s',field_list{kf});
    if print_each_2_collumn, fprintf(fid,',');end
  end
  
  for npool = 1:length(conc)/2
    n1 = conc(2*npool-1).pool;
    n2 = conc(2*npool).pool;
    
    fprintf(fid,'\n%s/%s',n1,n2);
    
    for kf = 1:length(field_list)
      y1 = getfield(conc(2*npool-1),field_list{kf});
      y2 = getfield(conc(2*npool),field_list{kf});
 
      y1(isnan(y1))='';      y2(isnan(y2))='';
 
      if isempty(y1)|isempty(y2) | length(y1)==1 |length(y2)==1
	h=0;
      else
	
	if size(y1,1)==1
	  y1=y1';y2=y2';
	end
	
	X=[ones(size(y1));ones(size(y2))*2];
	
	p = anova1([y1;y2],X,'off');
	h = p<0.05;
      end
      
      
      if h
	fprintf(fid,', %f',p);
      else
	fprintf(fid,',');
      end
 	
      if print_each_2_collumn, fprintf(fid,',');end
     
    end
   
  end

  fprintf(fid,'\n\n\n');
end 

if do_kruskal
    
  fprintf(fid,'Kruskalwallis');
  
  for kf = 1:length(field_list)
    fprintf(fid,',%s',field_list{kf});
    if print_each_2_collumn, fprintf(fid,',');end
  end
  
  for npool = 1:length(conc)/2
    n1 = conc(2*npool-1).pool;
    n2 = conc(2*npool).pool;
    
    fprintf(fid,'\n%s/%s',n1,n2);
    
    for kf = 1:length(field_list)
      y1 = getfield(conc(2*npool-1),field_list{kf});
      y2 = getfield(conc(2*npool),field_list{kf});
 
      y1(isnan(y1))='';      y2(isnan(y2))='';
 
      if isempty(y1)|isempty(y2) | length(y1)==1 |length(y2)==1
	h=0;
      else
	if size(y1,1)==1
	  y1=y1';y2=y2';
	end
	X=[ones(size(y1));ones(size(y2))*2];
	
	p = kruskalwallis([y1;y2],X,'off');
	h = p<0.05;
      end
      
      
      if h
	fprintf(fid,', %f',p);
      else
	fprintf(fid,',');
      end
 	
      if print_each_2_collumn, fprintf(fid,',');end
     
    end
   
  end

  fprintf(fid,'\n\n\n');
end 

if do_normal_test
  fprintf(fid,'Is it a normal dist (lillie test)');

  for kf = 1:length(field_list)
    fprintf(fid,',%s',field_list{kf});
    if print_each_2_collumn, fprintf(fid,',');end
  end
  
  for npool = 1:length(conc)
    n1 = conc(npool).pool;
    
    fprintf(fid,'\n%s',n1);
    
    for kf = 1:length(field_list)
      y1 = getfield(conc(npool),field_list{kf});

      if length(find(~isnan(y1)))<4
	h=1;
      else
	h=lillietest(y1);

      end
      
      
      if ~h
	fprintf(fid,', %f',~h);
      else
	fprintf(fid,',');
      end
 	
      if print_each_2_collumn, fprintf(fid,',');end
     
    end
   
  end

  fprintf(fid,'\n\n\n');

  
end
