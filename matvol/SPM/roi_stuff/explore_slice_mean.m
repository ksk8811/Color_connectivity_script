rootdir = '/nasDicom/spm_raw/';


sujet_re = {'2012'};

fonc_re  = {'TR10$','TR12$','te82$','88$','64$','_6$','_2mm_p2$','shi$','dwi.*7iso$','17iso_TE92_TR14$','17iso_TE85_TR14_ip3$','36dir_2iso_Gated_ip3$','35dir_2iso_Gated_ip3$','DTI_41_directions$','hardi_b1400$'};
fonc_re  = {'.*'};

suj = get_subdir_regex(rootdir,'PROT.*',{'^2012'});
%suj = get_subdir_regex(rootdir,'.*',{'^2010'});
funcdirs=get_subdir_regex(suj,fonc_re);


%get_slice_mean(char(funcdirs),0.8,'black_slice08_2011.csv',-1,0)
get_slice_mean_cenir(funcdirs,0.3,'proto_certre.csv',-1,0)

return
file='/home/romain/tmp/PROTO_BAD_slice0.3_2012.csv'
%[A r] = readtext(file,',','','','numeric');
[A r] = readtext(file,',','','','empty2zero')

hdr = A(2,:);
ligne_vide = ~r.numberMask(:,6);
A(ligne_vide,:)='';

dateexa=char(A(:,2));
dateexa(:,[5 8])='';

clear dateexat
for k=1:size(A,1)
  dateexat(k,:) = A{k,3}(end-7:end);
  if findstr(A{k,1},'PROTO'), istrio(k)=1;else istrio(k)=0;end
end

dateexat(:,[3 6])='';

aa = [str2num(dateexa(:,1:4)) str2num(dateexa(:,5:6))  str2num(dateexa(:,7:8))  str2num(dateexat(:,1:2))  str2num(dateexat(:,3:4))  str2num(dateexat(:,5:6))  ];

dnum=datenum(aa);

% 'num of dir'    'num of slice'    'mean std'    'max sdt'    'Vol 3std'
% 'Sli 3std'    'Vol'    'Sli'  'Volmin'    'Slimin'   'Volmax'    'Slimax' 
V=cell2mat(A(:,6:17));


V = V(istrio==1,:);
dateexa = dateexa(istrio==1,:);
dnum=dnum(istrio==1);

[dd,ii,jj]=unique(str2num(dateexa));

for kk=1:length(ii)
  indd=find(jj==kk);
  Vsum(kk,:) = sum(V(indd,:),1);
  Vmean(kk,:) = mean(V(indd,:),1);
end

datejour = dnum(ii);


figure
% subplot(2,1,1)
% hold on
% plot(dnum(istrio==1),V(istrio==1,9),'xb')
% plot(dnum(istrio==1),V(istrio==1,11),'xr')
% %plot(dnum(istrio==1),V(istrio==1,7),'xg')
% title('Trio Bad volume ');datetick()

for k=1:2
subplot(2,1,k)
aa=V(istrio==1,7); amin = V(istrio==1,9); amax = V(istrio==1,11);
aa(aa>10)=10  ;amin(amin>10)=10  ;amax(amax>10)=10  ;
hold on
plot(dnum(istrio==1),amin,'xb')
plot(dnum(istrio==1),amax,'xr')

title('Trio Bad volume 2012 ');datetick()
legend({'coupes noires','spikes'})
ylabel('nb of bad volumes')
xlabel('time')
ylim([-0.5 12])
end



figure
subplot(4,1,1)
 plot(datejour,Vsum(:,7),'xr'); hold on ; plot(datejour,Vsum(:,7),'g');
title('Trio Bad volume ');datetick()

subplot(4,1,2)
 plot(datejour,Vsum(:,7)./Vsum(:,1),'xr');hold on;  plot(datejour,Vsum(:,7)./Vsum(:,1),'g');
title('Trio Bad volume / acquier volume');datetick()
subplot(4,1,2)

plot(datejour,(Vsum(:,1)-Vsum(:,7))./Vsum(:,1),'xr');hold on ;plot(datejour,(Vsum(:,1)-Vsum(:,7))./Vsum(:,1),'g')


subplot(4,1,3)
plot(datejour,Vmean(:,4),'xr');hold on  ;plot(datejour,Vmean(:,4),'g');hold on 
title('Trio max std ');datetick()

subplot(4,1,4)
[ds is]=sort(dnum);
yy=V(is,4); yy(yy<10)=0;
plot(dnum(is),yy,'xr');hold on ;plot(dnum(is),yy,'g')
title('Trio max std ');datetick()

subplot(4,1,4)
[ds is]=sort(dnum);
yy=V(is,4); yy(yy<10)=0;
plot(dnum(is),yy,'xr');hold on ;plot(dnum(is),yy,'g')
title('Trio max std ');datetick()


figure
subplot(4,1,1)
 plot(datejour,Vsum(:,7),'xr'); hold on ; plot(datejour,Vsum(:,7),'g');
title('Trio Bad volume ');datetick()
subplot(4,1,2)
 plot(datejour,Vsum(:,5),'xr'); hold on ; plot(datejour,Vsum(:,5),'g')
title('Trio Bad volume std ');datetick()

subplot(4,1,3)
 plot(datejour,Vsum(:,7)./Vsum(:,1),'xr');hold on;  plot(datejour,Vsum(:,7)./Vsum(:,1),'g');
title('Trio Bad volume / acquier volume');datetick()
subplot(4,1,4)
 plot(datejour,Vsum(:,5)./Vsum(:,1),'xr'); hold on ; plot(datejour,Vsum(:,5)./Vsum(:,1),'g')
title('Trio Bad volume std / acquier volume ');datetick()

figure
subplot(4,1,1)
 plot(datejour,Vmean(:,7),'xr'); hold on ; plot(datejour,Vmean(:,7),'g');
title('Trio Bad volume ');datetick()
subplot(4,1,2)
 plot(datejour,Vmean(:,5),'xr'); hold on ; plot(datejour,Vmean(:,5),'g')
title('Trio Bad volume std ');datetick()

subplot(4,1,3)
 plot(datejour,Vmean(:,7)./Vmean(:,1),'xr');hold on;  plot(datejour,Vmean(:,7)./Vmean(:,1),'g');
title('Trio Bad volume / acquier volume');datetick()
subplot(4,1,4)
 plot(datejour,Vmean(:,5)./Vmean(:,1),'xr'); hold on ; plot(datejour,Vmean(:,5)./Vmean(:,1),'g')
title('Trio Bad volume std / acquier volume ');datetick()

title('Trio mean std ');datetick()
