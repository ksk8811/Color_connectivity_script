function write_res_summary_stat_2G(r,r0,resfile,seuil)

if ~exist('mancovan')
  aa=fileparts(which('write_res_summary_stat_3G'))
  addpath(fullfile(aa,'ancovan'))
end
  


if ~exist('seuil')
  seuil=0.05;
end

do_logit=1; do_logit_all=0;
print_ano=1;
print_ttest=0;
print_wil=1;
print_diff=0;
print_class=0;
print_std=0;

grp_cmp=[1,2];

data=r.dat;   group=r.group; 
nbcolumn = length(r.hdr);
 
do_plot=0;

for k = 1:size(r.dat,2)
  [Pa(k,:),Ta,statsa(k)] =  anovan(r0.dat(:,k),{r.group,r.age-mean(r.age)},'continuous',2,'model','full','varnames',{'group','age'},'display','off','alpha',seuil);
  
  [Pa2(k,:),Ta,statsa2(k)] =  anovan(r.dat(:,k),r.group,'model','full','display','off','alpha',seuil);  

  [Pk(k),ano,statk(k)] = kruskalwallis(r.dat(:,k),r.group,'off');

end
Pa = Pa(:,1);

[tt pp ff Pam ss] = mancovan(r.dat,r.group);
Pam=Pam';

%write_res_summary_stat_3G(cr,resfile);

fid = fopen(resfile,'a+');

gg=unique(r.group);

fprintf(fid,'\n\n%s',r.title);
for kf = 1:length(r.hdr)
  fprintf(fid,',%s',r.hdr{kf});
end

%print the mean
for ng =1:length(gg)
  fprintf(fid,'\n%s (n=%d) Mean',r.group_name{ng}, length(find(r.group==ng)));  
  for kf = 1:length(r.hdr)
    fprintf(fid,',%f',mean(r.dat(r.group==ng,kf)));
  end
end
fprintf(fid,'\n');

if print_std
  %print the std/mean
  for ng =1:length(gg)
    fprintf(fid,'\n%s  Std/Mean',r.group_name{ng} );  
    for kf = 1:length(r.hdr)
      fprintf(fid,',%f',std(r.dat(r.group==ng,kf))./mean(r.dat(r.group==ng,kf)));
    end
  end
  fprintf(fid,'\n');
end

if print_ttest
  fprintf(fid,'\nanova P<%f ',seuil);
  for k=1:nbcolumn
    if Pa(k)<seuil,    fprintf(fid,',%f',Pa(k));  else,    fprintf(fid,',');  end
  end

  fprintf(fid,'\nanova noage P<%f ',seuil);
  for k=1:nbcolumn
    if Pa2(k)<seuil,    fprintf(fid,',%f',Pa2(k));  else,    fprintf(fid,',');  end
  end
end

if print_ano
  fprintf(fid,'\nManovan P<%f ',seuil);
  for k=1:nbcolumn
    if Pam(k)<seuil,    fprintf(fid,',%f',Pam(k));  else,    fprintf(fid,',');  end
  end

end

if print_wil
  fprintf(fid,'\nkruskalwallis P<%f ',seuil);
  for k=1:nbcolumn
    if Pk(k)<seuil,   fprintf(fid,',%f',Pk(k));  else,    fprintf(fid,',');  end
  end
end

if print_diff
  cmp=multcompare(statsa2(1),'display','off');
  for k=1: size(grp_cmp,1) %only the first 2 instead of size(cmp,1)
    fprintf(fid,'\nDiff Grp %d - Grp %d',cmp(k,1),cmp(k,2));
    for kk=1:nbcolumn
      [cmp m] = multcompare(statsa2(kk),'display','off');
      if (cmp(k,3)*cmp(k,5)>0)
	
	diffG(k,kk) = cmp(k,4)./(m(cmp(k,1),2)+m(cmp(k,2),2))*2;
	
	fprintf(fid,',%f',cmp(k,4)./(m(cmp(k,1),2)+m(cmp(k,2),2))*2); %DIVISE
	%par la moyene des std indice de cohen 
      else,  
	fprintf(fid,',');  
	diffG(k,kk)=0;
      end
    end
  end
fprintf(fid,'\n');
end


if print_wil & print_class
  %2 by 2 Wilcoxon test
  for k=1:size(grp_cmp,1)
    fprintf(fid,'\nWilcoxon Grp %d - Grp %d',grp_cmp(k,1),grp_cmp(k,2));
    for kc=1:nbcolumn
      y1 = r.dat(r.group==grp_cmp(k,1),kc) ;
      y2 = r.dat(r.group==grp_cmp(k,2),kc) ;
      y1(isnan(y1))='';      y2(isnan(y2))='';
      
      if isempty(y1)|isempty(y2)
	h=0;
      else
	[p,h]=ranksum(y1,y2,'alpha',seuil);
	if isnan(h),  h=0;p=0;	end      
      end
      
      if Pk(kc)>seuil, h=0;end
      
      if h, Pw(k,kc) = p;	  fprintf(fid,',%f',p);	else, Pw(k,kc) =1;	  fprintf(fid,',');	end
    end
  end
end


if print_wil & print_class
  for k=1:size(grp_cmp,1)
    fprintf(fid,'\nWilcoxon Classement Grp %d - Grp %d',grp_cmp(k,1),grp_cmp(k,2));
    ind=find(Pw(k,:)<seuil);
    [vv,ii]=sort(Pw(k,ind));
    aa = ind(ii);
    for k=1:nbcolumn
      if ~isempty(find(aa==k)),   fprintf(fid,',%d',find(aa==k));  else,    fprintf(fid,',');  end
    end
  end
end

 
if print_ano    & print_class 
%  fprintf(fid,'\n');
  for k=1:size(grp_cmp,1)
    fprintf(fid,'\nManovan Classement Grp %d - Grp %d',grp_cmp(k,1),grp_cmp(k,2));
    ind=find(Pam(k,:)<seuil);
    [vv,ii]=sort(Pam(k,ind));
    aa = ind(ii);
    for kc=1:nbcolumn
      if ~isempty(find(aa==kc)),   fprintf(fid,',%d',find(aa==kc));  else,    fprintf(fid,',');  end
    end
  end
  
end


ind=find(Pa2<seuil);[vv,ii]=sort(Pa2(ind));
aa = ind(ii);

ind=find(Pam<seuil);[vv,ii]=sort(Pam(ind));
aam = ind(ii);

if print_ttest

  fprintf(fid,'\nClassement anova noage ');
  for k=1:nbcolumn
    if ~isempty(find(aa==k)),   fprintf(fid,',%d',find(aa==k));  else,    fprintf(fid,',');  end
  end
end

%if print_ano    
%  fprintf(fid,'\nManavoan 3 group Classement ');
%  for k=1:nbcolumn
%    if ~isempty(find(aam==k)),   fprintf(fid,',%d',find(aam==k));  else,    fprintf(fid,',');  end
%  end
%end

if do_logit

  if do_logit_all
    %compoute the stat
    [indSel,h,sorder] = stepwisemultinomiallogistic(r.dat,r.group,0,seuil);
    
    aa=1:length(r.hdr);classement3group=[];

    while size(h.In,1)>1
      classement3group(end+1) = aa(h.In(2,:));
      data(:,h.In(2,:))='';  aa(h.In(2,:))='';
    
      [indSel2,h] = stepwisemultinomiallogistic(data,group,0,seuil);
    end

    %print the results
  
    fprintf(fid,'\n\nlogit test 3 groupe');
    for k=1:nbcolumn
      if indSel(k),   fprintf(fid,',1');  else,    fprintf(fid,',');  end
    end
    
  end
  

end %do_logit


%figure
%for k=1:nbcolumn
%  subplot(2,nbcolumn,k)
%    boxplot(r.dat(:,k),r.group,'notch','on')
%  subplot(2,nbcolumn,nbcolumn+k)
%    boxplot(r.dat(:,k),r.group,'notch','on')
%end
 

fclose(fid)


if do_plot
  diffG(diffG==0)=NaN;
  
  plot_summary_stat_3G(r,r0,seuil)    
  
  subplot(4,1,4)
  hold on 
  plot(diffG(2,:),'x','markersize',10);
  plot(diffG(1,:),'ro','markersize',10);
  grid on 

  set(gca,'XTick',1:10)
  set(gcf,'PaperOrientation','landscape','PaperType','A4')

saveas(gcf,[r.title 'jpg'],'jpg')

end
