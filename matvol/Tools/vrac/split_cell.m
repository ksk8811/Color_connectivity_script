function [co1 co2]=split_cell(c1,strkey,keyind)

kl = length(strkey);

for k=1:length(c1)
    
    aa=c1{k};
    ind=strfind(aa,strkey);
    if isempty(ind)
        co1{k} = aa;
        co2{k} = '';
        
    else
        if ischar(keyind)
            co1{k} = aa(1:ind(end)-1);
            co2{k} = aa(ind(end)+kl:end);
            
        else
            
            co1{k} = aa(1:ind(keyind)-1);
            co2{k} = aa(ind(keyind)+kl:end);
        end
    end
end
