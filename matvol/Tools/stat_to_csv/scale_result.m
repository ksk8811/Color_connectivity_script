function  co = scale_result(ci,field_ref,field_change,scale_fac)


if ~exist('scale_fac'),  scale_fac=1;end
if ~exist('field_change'),  field_change='';end

if isempty(field_change)
  field_change = fieldnames(ci(1));
end

for npool = 1:length(ci)
  cpool = ci(npool);

  cref = getfield(cpool,field_ref);

  for k=1:length(field_change)
    cc = getfield(cpool,field_change{k});
    if isnumeric(cc)
        cc = cc./cref * scale_fac;
        cpool = setfield(cpool,field_change{k},cc);
    end
  end
  co(npool) = cpool;
end

