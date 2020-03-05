function c=replace_str_from_cell_list(c,str,strnew)


for k =1:length(c)
    aa=c{k};
    aa(strfind(aa,str)) = strnew;
    
    c{k} = aa;
    
end