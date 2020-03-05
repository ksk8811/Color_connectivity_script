function co = reduce_cell(ci,ind_to_remove)

if isnumeric(ind_to_remove)
  ind_to_remove = {ind_to_remove};
end

for nbg=1:length(ci)
indr = ind_to_remove{nbg};
cc = ci(nbg);
cco = cc;

numsuj = length(cc.suj);

af = fieldnames(cc)
for nbf =1:length(af)
	
  fa = getfield(cc,af{nbf});
  %keyboard
  if length(fa)==numsuj;
    fa(indr)=[];
    cco = setfield(cco,af{nbf},fa);
  end

end
co(nbg) = cco;


end

