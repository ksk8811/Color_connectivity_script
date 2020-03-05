function print_csaheader_info(fid_name,csa)

if ischar(fid_name)
  fid=fopen(fid_name,'w')
else
  fid=fid_name;
end

for k=1:length(csa)
  
  if ~isempty(csa(k).item)
    if 0%strcmp(csa(k).name,'MrPhoenixProtocol') %just skip this one is just  to big
    else
      fprintf(fid,' %s : \t\t[',csa(k).name);
      for nbit=1:csa(k).vm 
	fprintf(fid ,' %s ',csa(k).item(nbit).val)  ;
      end

      fprintf(fid,']\n');
    end    
  
  end
end
