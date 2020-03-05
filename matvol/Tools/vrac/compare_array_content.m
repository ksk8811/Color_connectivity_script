function [ind_found,ind_notfound] = compare_array_content(A,B)
%function [ind_found,ind_notfound] = compare_array_content(A,B)
%ind_found is indice of B where value are in A
%ind_notfound is indice of A where value were not in B

ind_found=[];ind_notfound=[];

if iscell(A(1))
    
    for kk=1:length(A)
        
        found=0;
        
        for jj=1:length(B)
            if strcmp(A{kk},B{jj})
                ind_found(end+1) = jj;
                found=1;
            end
        end
        
        if found==0
            ind_notfound(end+1) = kk;
        end
    end
    
else
    
    for kk=1:length(A)
        
        found=0;
        
        for jj=1:length(B)
            if A(kk)==B(jj)
                ind_found(end+1) = jj;
                found=1;
                %break
            end
        end
        
        if found==0
            ind_notfound(end+1) = kk;
        end
    end
    
end