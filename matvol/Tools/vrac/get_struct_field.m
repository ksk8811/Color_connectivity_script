function [ff ffr] = get_struct_field(s,str)

fall = fieldnames(s);
ff={};ffr={};

for k=1:length(fall)
  ind = findstr(fall{k},str);
  
  if ind
    ff(end+1) = fall(k); 
    reduc_name = fall{k};
    reduc_name(ind:(ind+length(str)-1))='';

    if isempty(reduc_name) 
        reduc_name = fall{k};
    end

    if strcmp(reduc_name(end),'_')
      reduc_name(end)='';
    end
    
    ffr{end+1} = reduc_name;
  end
end
