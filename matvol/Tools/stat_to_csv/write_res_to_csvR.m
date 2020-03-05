function write_res_to_csvR(conc,resname,field_list,std_abs)

if ~exist('field_list')
  field_list = fieldnames(conc);
  field_list(1:2)=[];
end

if ~exist('std_abs')
  std_abs=0;
end


for nregion = 1:3:(length(conc)-1)

  fname = [resname conc(nregion).pool '.csv'];
  fid = fopen(fname,'w+');

  
  if isfield(conc(1),'suj_age')
    fprintf(fid,'%s,group,Age',conc(nregion).pool);
  else
    fprintf(fid,'%s,group',conc(nregion).pool);
  end
  
  for kf = 1:length(field_list)
    if ~strcmp(field_list{kf},'suj_age')
      fprintf(fid,',%s',field_list{kf});
    end
  end

  for kk=1:3;
    npool = kk + nregion-1;

    for k=1:length(conc(npool).suj)
      fprintf(fid,'\n%s,%d',conc(npool).suj{k},kk);
      if isfield(conc(1),'suj_age')
	fprintf(fid,',%s',conc(npool).suj_age{k});
      end
      
      for kf = 1:length(field_list)
	if ~strcmp(field_list{kf},'suj_age')
	  aa = getfield(conc(npool),field_list{kf});
	  if isnan(aa(k))
	    fprintf(fid,',NAN');
	  else
	    fprintf(fid,',%0.3f',aa(k) );
	  end
	end
      end
    end
  
  end
end
  
  
fclose(fid);
