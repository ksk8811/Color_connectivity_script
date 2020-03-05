
function read_brucker_method(fin,path_out)

if nargin==1
    [path_out,vv] = get_parent_path(fin);
end

for k=1:length(fin)
    fid=fopen(fin{k},'r');
    tline = fgetl(fid);
    
    while 1
        if ~ischar(tline), break, end
        
        if findstr(tline,'##$PVM_DwEffBval')
            disp(tline)
            [bval tline] = brucker_parse_numeric_lines(fid);
            
        elseif findstr(tline,'##$PVM_DwGradVec')  % ##$PVM_DwDir
            disp(tline)
            
            [val tline] = brucker_parse_numeric_lines(fid);
            numdir = length(val)/3;
            bvec = reshape(val,3,numdir);
        else
            tline = fgetl(fid);            
        end        
        
    end
    fclose(fid);

    %print bvec et bval in a file
    for kk=1:size(bvec,2)
        if norm(bvec(:,kk)) >0
            bvec(:,kk) = bvec(:,kk)./norm(bvec(:,kk));
        end
    end

    %pour DTI paravision 5.1 patch (SN_track2014 il faut en plus -y -z)
    
    f1=fopen(fullfile(path_out{k},'bvals'),'w');
    fprintf(f1,'%f ',bval);
    fprintf(f1,'\n');
    fclose(f1);
    
    f1=fopen(fullfile(path_out{k},'bvecs'),'w');
    for kd=1:3
        fprintf(f1,'%f ',bvec(kd,:));
        fprintf(f1,'\n');
    end
    fclose(f1);
        
end

end


function [val tline] = brucker_parse_numeric_lines(fid)
val=[];
while 1
    tline = fgetl(fid);
    s=regexp(tline,'\s','split');
    if isempty(str2num(s{1})), break , end
    for ii=1:length(s), if ~isempty(str2num(s{ii})), val(end+1) = str2num(s{ii});end;end
end;


end
