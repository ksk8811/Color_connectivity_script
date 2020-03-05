function res = concat_struct(s1,s2)

name = fieldnames(s2);

for k=1:length(name)
  val = getfield(s2,name{k});
  s1 = setfield(s1,name{k},val);
end
res=s1;