function vo = find_colonne_content(data,str)

ind = find_colonne_ind(data,str);

vo=[];

if ind==0
  return
end

vo = data(:,ind);

for k=2:size(data,1)
  if strcmp(vo{k},'NULL')
    vo{k} = 0;
  end
end


vo(1)=[];

if isnumeric(vo{1})
  vo = cell2mat(vo);
end

