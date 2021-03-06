function write_res_to_csv(conc,resname,field_list,std_abs)

if ~exist('field_list')
    field_list = fieldnames(conc);
    for kk=1:length(field_list)
        if strcmp(field_list{kk},'pool'),      ind(1)=kk;    end
        if strcmp(field_list{kk},'suj'),      ind(2)=kk;    end
        arg=getfield(conc(1),field_list{kk});
        if iscell(arg)
            ind(end+1)=kk;
        end        
        
        if length(arg)~=length(conc(1).suj)
            ind(end+1)=kk;  %skip incomplete field
        end

    end
    
    field_list(ind)=[];
end

if ~exist('std_abs')
    std_abs=0;
end



fid = fopen(resname,'a+');

write_res_summary_to_csv(conc,fid,field_list,std_abs);

%if even number of pool
if mod(length(conc),2)==0
    write_res_summary_stat(conc,fid,field_list)
end


for npool = 1:length(conc)
    
    if isfield(conc(1),'suj_age')
        fprintf(fid,'%s,Age',conc(npool).pool);
    else
        fprintf(fid,'%s',conc(npool).pool);
    end
    
    for kf = 1:length(field_list)
        if ~strcmp(field_list{kf},'suj_age')
            fprintf(fid,',%s',field_list{kf});
        end
    end
    
    for k=1:length(conc(npool).suj)
        fprintf(fid,'\n%s',conc(npool).suj{k});
        if isfield(conc(1),'suj_age')
            fprintf(fid,',%s',conc(npool).suj_age{k});
        end
        
        for kf = 1:length(field_list)
            if ~strcmp(field_list{kf},'suj_age')
                aa = getfield(conc(npool),field_list{kf});
%                 if length(aa)~=length(conc(npool).suj)
%                     continue %skip incomplete field
%                 end
                
                if isnan(aa(k))
                    fprintf(fid,',');
                else
                    fprintf(fid,',%f',aa(k) );
                end
            end
        end
    end
    
    %print the mean
    fprintf(fid,'\nmean');
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
    
    %print the std
    
    if std_abs
        fprintf(fid,'\nstd');
    else
        fprintf(fid,'\nstd/mean');
    end
    
    if isfield(conc(1),'suj_age')
        if std_abs
            fprintf(fid,',%f',std(sa));
        else
            fprintf(fid,',%f',std(sa)./mean(sa));
        end
    end
    
    for kf = 1:length(field_list)
        if ~strcmp(field_list{kf},'suj_age')
            aa = getfield(conc(npool),field_list{kf});
            aa(isnan(aa))=[];
            if std_abs
                fprintf(fid,',%f',std(aa));
            else
                fprintf(fid,',%f',std(aa)./mean(aa));
            end
        end
    end
    
    
    fprintf(fid,'\n\n\n');
    
end


fclose(fid);
