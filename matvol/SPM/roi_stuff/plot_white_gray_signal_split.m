function plot_white_gray_signal_split(Y,Yn,vlines)


if 1
  for k=1:length(Y.regions) 
    ywm = Y.regions(k).ywm;
    ygm = Y.regions(k).ygm;
    ywv = Y.regions(k).ywv;
    ygv = Y.regions(k).ygv;
    nb_gris = Y.regions(k).nb_gris;
    nb_whit = Y.regions(k).nb_whit;    
    
    Y.Ygvarmed(k,1) = median(ygv);
    Y.Ywvarmed(k,1) = median(ywv) ;   
    
%    ywv2 = Y.regions(k).ywv.*Y.regions(k).ywv;
%    Y.Ywvar2(k,1) = sqrt(mean(ywv2));
  end
  
end


cw={'r','r:','r-.','r--'};
cg={'g','g:','g-.','g--'};
cn={'b','b:','b-.','b--'};

hf = figure('Position',[1291 90 1116 854]);

subplot(4,3,1);hold on 
plot(Y.Yw,'r');  plot(Y.Yw,'hr');
title('white mean of mean')

subplot(4,3,2);hold on 
plot(Y.Ywvar,'r'); plot(Y.Ywvar,'hr')
plot(Y.Ywvarmed,'r--'); plot(Y.Ywvarmed,'hr')

title('white mean of std')

subplot(4,3,3);  hold on
plot(Y.Ywmvar,'r'); plot(Y.Ywmvar,'hr')

title('white std of means')


subplot(4,3,4);hold on 
plot(Y.Yg,'g');  plot(Y.Yg,'hg');
title('gray mean of mean')

subplot(4,3,5);hold on 
plot(Y.Ygvar,'g'); plot(Y.Ygvar,'hg')
plot(Y.Ygvarmed,'r--'); plot(Y.Ygvarmed,'hr')

title('gray mean of std')

subplot(4,3,6);  hold on
plot(Y.Ygmvar,'g'); plot(Y.Ygmvar,'hg')

title('gray std of means')

subplot(4,3,9);  hold on
plot(Y.Ywvarn,'r'); plot(Y.Ywvarn,'hr')
plot(Y.Ygvarn,'g'); plot(Y.Ygvarn,'hg')

title('mean of norm 1 std')

if isfield(Y,'Ywvarn2')
  subplot(4,3,12);  hold on
  plot(Y.Ywvarn2,'r'); plot(Y.Ywvarn2,'hr')
  plot(Y.Ygvarn2,'g'); plot(Y.Ygvarn2,'hg')

  title('mean of norm 0 std')
end


subplot(4,3,10);hold on 
plot(Y.Yc); plot(Y.Yc,'h')
title('contrast S')


for kn=1:length(Yn)

  subplot(4,3,7); hold on
  plot(Yn(kn).Y,cn{kn});
  if kn==1,   plot(Yn(kn).Y,['h' cn{kn}]); end
  title('noise S')

  subplot(4,3,8); hold on
  plot(sqrt(Yn(kn).Yvar),cn{kn})
  if kn==1,   plot(sqrt(Yn(kn).Yvar),['h',cn{kn}]); end
  title('noise std')
  
%  subplot(4,3,11); hold on
%  plot((Yw.Y-Yg.Y)./sqrt(Yn(kn).Yvar),cn{kn})
%  if kn==1,   plot((Yw.Y-Yg.Y)./sqrt(Yn(kn).Yvar),['h',cn{kn}]); end
%  title('CNR')

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
