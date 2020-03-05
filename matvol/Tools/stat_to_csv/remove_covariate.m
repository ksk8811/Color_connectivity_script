function O = remove_covariate(values,covariate)


for i=1:size(values,2)
  [pim,pam,poum] = regress(values(:,i),covariate-mean(covariate)); 
  O(:,i) = poum; 
end



