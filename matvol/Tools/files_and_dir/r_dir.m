function do = r_mkdir(d)
  
for k=1:length(d)
  %dir(d{k});  
  unix(sprintf('ls -ltra %s',d{k}))
end  
