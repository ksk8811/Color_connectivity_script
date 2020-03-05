function write_cell_to_csv(c,resname)




fid = fopen(resname,'w+');

for i=1:size(c,1)
    for j=1:size(c,2)
        aa=c{i,j};
        if isnumeric(aa)
            fprintf(fid,'%f',aa);
        else
            fprintf(fid,'%s',aa);
        end
        if j<size(c,2)
            fprintf(fid,',');
        end
    end
    fprintf(fid,'\n');
    
end

fclose(fid);
