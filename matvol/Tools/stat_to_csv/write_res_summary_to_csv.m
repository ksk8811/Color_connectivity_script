function write_res_summary_to_csv(conc,fid,field_list,std_abs)

if ~exist('std_abs')
  std_abs=0;
end


fprintf(fid,'\n\n')

npool=1;
if isfield(conc(1),'suj_age')
  fprintf(fid,'%s (n=%d),Age',conc(npool).pool,length(conc(npool).suj));
else
  fprintf(fid,'%s (n=%d)',conc(npool).pool,length(conc(npool).suj));
end
  
for kf = 1:length(field_list)
  if ~strcmp(field_list{kf},'suj_age')
    fprintf(fid,',%s',field_list{kf});
  end
end

for npool = 1:length(conc)
  if npool>1
    fprintf(fid,'%s (n=%d)',conc(npool).pool,length(conc(npool).suj));
  end
 
  %print the mean
  fprintf(fid,'\nmean');
%  if isfield(conc(1),'suj_age'),fprintf(fid,',');end
  if isfield(conc(1),'suj_age'),
    aa = conc(npool).suj_age;
    sa=str2num(cell2mat(aa'));

    fprintf(fid,',%f',mean(sa));
  end

  for kf = 1:length(field_list)
    if ~strcmp(field_list{kf},'suj_age')
      aa = getfield(conc(npool),field_list{kf});
      aa(isnan(aa))=[];
      fprintf(fid,',%f',mean(aa));
    end
  end

  if std_abs
    %print the std
    fprintf(fid,'\nstd');
    
    %  if isfield(conc(1),'suj_age'),fprintf(fid,',');end
    if isfield(conc(1),'suj_age')
      fprintf(fid,',%f',std(sa));
    end


    for kf = 1:length(field_list)
      if ~strcmp(field_list{kf},'suj_age')
	aa = getfield(conc(npool),field_list{kf});
	aa(isnan(aa))=[];
	fprintf(fid,',%f',std(aa));
      end
    end
  end
  

%print the std/mean
  fprintf(fid,'\nstd/mean');
 
%  if isfield(conc(1),'suj_age'),fprintf(fid,',');end
  if isfield(conc(1),'suj_age')
        fprintf(fid,',%f',std(sa)./mean(sa));
  end


  for kf = 1:length(field_list)
    if ~strcmp(field_list{kf},'suj_age')
      aa = getfield(conc(npool),field_list{kf});
      aa(isnan(aa))=[];
      fprintf(fid,',%f',std(aa)./mean(aa));
    end
  end

  
  fprintf(fid,'\n');
  
end

fprintf(fid,'\n\n\n');
 