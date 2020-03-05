function vi=addlevel(vi,max)

k=length(vi);

while  vi(k) == max(k)
 vi(k)=1;
 k=k-1;
 if k==0
   break
 end
 
end

if k>0
  vi(k)=vi(k)+1;
end