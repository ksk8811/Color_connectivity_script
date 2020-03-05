function ind =find_ind_of_str_cell1incell2(c1,c2)


for k=1:length(c1)
    for j=1:length(c2)
        if strfind(c2{j},c1{k})
            ind(k) = j;
            break
        end
    end
end

