function [do subdir varargout] = get_parent_path(di,level)
%level if level


if exist('level')
    concat=0;
    if level<0,        level=abs(level);        concat=1;    end
    
    do=di;
    for k=1:level
        [do subdir] = get_parent_path(do);
        if (nargout-1>k)
            varargout{nargout-1-k} = subdir;
        end
        if concat
            if k>1
                for nbs=1:length(subdir)
                    %subdir{nbs} = [subdir{nbs} '_' sbdirmem{nbs}];
                    subdir{nbs} = cat(2,subdir{nbs},sbdirmem{nbs});
                end
            end
            sbdirmem = subdir;
        end
    end
    
    return
end

makeitchar=0;
if ischar(di)
    di = cellstr(di);
    makeitchar=1;
end

for k=1:length(di)
    
    for kf=1:size(di{k},1)
        [p,f,e] = fileparts(di{k}(kf,:));
        
        if isempty(f) %when the path end with \
            [p,f] = fileparts(p);
        end
        
       % do{k} = p ;
        doo{kf} = p;
        %i need it for process mrtrix
        if ~isempty(e)
            f=[f e];
        end
        
        %     subdir{k}(kf,:) = f;
        argg{kf} = f;
    end
    
    do{k} = char(doo);
    
    subdir{k} = char(argg);
    
    argg = {}; doo = {};
    
end

if makeitchar
    subdir = char(subdir);
    do = char(do);
end

