function Y = get_roi_data(o,VY,Y,k)


if length(o)==1
  y = y_struct(get_marsy(o, VY, 'mean', 'v'));

  Y.Y(k,1) = y.Y;  Y.Yvar(k,1) = y.Yvar;

  Y.nbpts(k) = size(y.regions{1}.Y,2);
  
  [h,val]=hist(y.regions{1}.Y,500);  ind=find(h~=0);
  Y.hist(k).h1 = h(ind);Y.hist(k).v1 = val(ind);
  
%  [h,val]=hist(y.regions{1}.Y,500);  ind=find(h~=0);
%  Y.hist(k).h2 = h(ind);Y.hist(k).v2 = val(ind);
  
%  [h,val]=hist(y.regions{1}.Y,50);  ind=find(h~=0);
%  Y.hist(k).h3 = h(ind);Y.hist(k).v3 = val(ind);

else
 
  s='get_marsy(';
 
  for ka=1:length(o)
    if ~is_empty_roi(o(ka))
      s=sprintf('%so(%d),',s,ka);
    end
  end
  s=sprintf('mary=%sVY(1),''mean'',''v'');',s);
  eval(s);

  y=y_struct( mary);
  
  Y.Y = y.Y;
  Y.Yvar = y.Yvar;

  for kl=1:length(y.regions)
    Y.nbpts(kl) = length(y.regions{kl}.Y);
    Y.Yvarnorm(kl) = var(y.regions{kl}.Y./mean(y.regions{kl}.Y) );
  end
end
