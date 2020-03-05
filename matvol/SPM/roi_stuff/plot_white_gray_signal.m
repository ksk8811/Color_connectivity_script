function plot_white_gray_signal(Yw,Yg,Yn,P,vlines)

cw={'r','r:','r-.','r--'};
cg={'g','g:','g-.','g--'};
cn={'b','b:','b-.','b--'};

hf = figure('Position',[1291 90 1116 854]);

for kg=1:length(Yw)

subplot(4,3,1);hold on 
p=plot(Yw(kg).Y,cw{kg}); set(p,'Marker','o');
title('white Sw')

subplot(4,3,2);hold on 
p=plot(sqrt(Yw(kg).Yvar),cw{kg}); set(p,'Marker','o');
title('white std')

for kn=1:length(Yn)
  subplot(4,3,3);  hold on

  p=plot(Yw(kg).Y./sqrt(Yn(kn).Yvar),cw{kn});
  if kn==1, set(p,'Marker','o');  end

  title('white gray SNR')
  
  %subplot(4,3,6); hold on
  p=plot(Yg(kg).Y./sqrt(Yn(kn).Yvar),cg{kn});
  if kn==1, set(p,'Marker','o');  end

  %  title('gray SNR')
  
  subplot(4,3,7); hold on
  p=plot(Yn(kn).Y,cn{kn});
  if kn==1,   set(p,'Marker','o'); end
  title('noise S')

  subplot(4,3,8); hold on
  p=plot(sqrt(Yn(kn).Yvar),cn{kn})
  if kn==1,   set(p,'Marker','o'); end
  title('noise std')
  
  subplot(4,3,11); hold on
  p=plot((Yw(kg).Y-Yg(kg).Y)./sqrt(Yn(kn).Yvar),cn{kn});
  if kn==1,  set(p,'Marker','o');  end
  title('CNR')


end

subplot(4,3,4);hold on 
p=plot(Yg(kg).Y,cg{kg}); set(p,'Marker','o');
title('gray Sg')

subplot(4,3,5);hold on 
p=plot(sqrt(Yg(kg).Yvar),cg{kg}); set(p,'Marker','o');
title('gray std')

subplot(4,3,10);hold on 
p=plot(Yw(kg).Y-Yg(kg).Y);  set(p,'Marker','o');
title('contrast Sw-Sg')

subplot(4,3,6); hold on
%p=plot(Yw(kg).nbpts./Yw(kg).nbpts(1),cw{kg});set(p,'Marker','o');
%p=plot(Yg(kg).nbpts./Yg(kg).nbpts(1),cg{kg}); set(p,'Marker','o');
p=plot(Yw(kg).nbpts,cw{kg});set(p,'Marker','o');
p=plot(Yg(kg).nbpts,cg{kg}); set(p,'Marker','o');
title('nb pts white & gray')


subplot(4,3,9);hold on 
p=plot(Yn(1).nbpts);  set(p,'Marker','o');
title('nb pts noise 1')

subplot(4,3,12);hold on 
p=plot( (Yw(kg).Y-Yg(kg).Y)./(Yw(kg).Y+Yg(kg).Y) );  set(p,'Marker','o');
title('contrast (Sw-Sg)/(Sw+Sg)')

end

if kg==1
nv=length(Yw.Y);

%first pass to find the max of x val
maxx=0;
for kk=1:nv
  if max(Yg.hist(kk).v1) > maxx; maxx = max(Yg.hist(kk).v1); end
  if max(Yw.hist(kk).v1) > maxx; maxx = max(Yw.hist(kk).v1); end
end
  

pbf = 6; %plot by figure
nf = (nv - mod(nv,pbf))/pbf;
if (mod(nv,pbf)), nf=nf+1;end

for kf =1:nf
  figure('Position',[360 162 628 786])

  for ks=1:pbf
    k = ks+(kf-1)*pbf;
    if (nv >= k)
      subplot(pbf,1,ks);    hold on
      
      val = Yg.hist(k).v1;
      h   = Yg.hist(k).h1./max(Yg.hist(k).h1);
      plot(val,h,'g')

      val = Yw.hist(k).v1;
      h   = Yw.hist(k).h1./max(Yw.hist(k).h1);
      plot(val,h,'r')

      for kn=1:length(Yn)
	val = Yn(kn).hist(k).v1;
	h   = Yn(kn).hist(k).h1./max(Yn(kn).hist(k).h1);
	plot(val,h,cn{kn})
      end
      xlim([0 maxx])
      title(sprintf ('Volumme %s',P(k,:)))
    end
  end
end

%for k=1:nv
%  subplot(nv,1,k)
%  axis([min(minx) max(maxx) 0 max(maxy)])
%end

end


if exist('vlines')
  figure(hf)

  for ki=1:12
    subplot(4,3,ki)
    yl=ylim;
    hold on
    for kk=1:length(vlines)
      plot([vlines(kk),vlines(kk)],yl,'k')
    end
    
  end
  
end
