function res =find_str_cell(res,reg_ex)

if ~iscell(reg_ex), reg_ex={reg_ex};end

for k=1:length(res.hdr)
  for nb_reg=1:length(reg_ex)      
    if ~isempty(regexp(res.hdr{k},reg_ex{nb_reg}))
      ii(k)=0;
      break
    else
      ii(k)=1;
    end
  end
end

ii=logical(ii);

res.hdr(ii)='';res.dat(:,ii)='';

