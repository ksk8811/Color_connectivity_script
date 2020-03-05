function plot_summary_stat_3G(r,r0,seuil)

nbcolumn = length(r.hdr);

%Compare the mean for anova
figure
title(r.title)
for k=1:nbcolumn
  subplot(4,nbcolumn,k)
  boxplot(r0.dat(:,k),r.group,'notch','off')
  
  if k==1,tt=r.title;tt(findstr(tt,'_')) = ' '; ylabel(tt);  end
  
  tt=r.hdr{k};tt(findstr(tt,'_')) = ' ';
  title(tt)    

  subplot(4,nbcolumn,nbcolumn+k);
  boxplot(r.dat(:,k),r.group,'notch','on')
  if k==1, ylabel('age removed');  end
 
end

for k = 1:size(r.dat,2)
  
  [Pa2(k),Ta,statsa2(k)] =  anovan(r.dat(:,k),r.group,'model','full','display','off','alpha',seuil);  

end

cmp=multcompare(statsa2(1),'display','off');

for kk=1:nbcolumn

  [cmp m] = multcompare(statsa2(kk),'display','off');

  if (Pa2(kk)<seuil)
    if (cmp(1,3)*cmp(1,5)>0)
   
      subplot(4,nbcolumn,2*nbcolumn+kk);
      errorbar([1 2 3],m(:,1),m(:,2),'r');
    else
      subplot(4,nbcolumn,2*nbcolumn+kk);
      errorbar([1 2 3],m(:,1),m(:,2));
    end
    
  end

  if (cmp(1,3)*cmp(1,5)>0)
%    subplot(4,nbcolumn,3*nbcolumn+kk);
  end


end

%question errorbar avec m(:,2)/2 ???