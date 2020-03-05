function ind = find_colonne_ind(d,str)

ind = 0;

for k =1:size(d,2)
  if strcmpi(d{1,k},str)
    ind=k; 
    break
  end
end

if ind==0
  warning('can not find column %s\n',str);
end
