function c=remove_str_from_cell_list(c,str,strlength)

if ~exist('strlength')
    strlength=length(str)
end

for k =1:length(c)
    aa=c{k};
    
    if isnumeric(str)
        aa(str)='';
        c{k}=aa;
    else
        ind = strfind(aa,str);
        if ind
            aa(ind:(ind+strlength-1))='';
            
            c{k} = aa;
        end
        
    end
    
end