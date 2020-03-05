%function get_white_volume

data_path='/data1/rom/';

if ~exist('P')
  P = spm_select([1 Inf],'image','select images','',data_path);
end


VY = spm_vol(P);


for k=1:length(VY)
  [p,f,e]=fileparts(VY(k).fname);
  
  Pgris  = fullfile(p,['c1',f,e]);
  Pwhite = fullfile(p,['c2',f,e]);
  Pcbf   = fullfile(p,['c3',f,e]);
  Pall   = fullfile(p,['c123',f,e]);
  %  Pnobias = fullfile(p,['m',f,e]);
  
  if ~exist(Pall)
    load('write_img_calc.mat')
    jobs{1}.util{1}.imcalc.input = {Pgris;Pwhite;Pcbf};
    jobs{1}.util{1}.imcalc.output = Pall;
    jobs{1}.util{1}.imcalc.expression = 'i1+i2+i3';

    spm_jobman('run',jobs);
  end
  
  seuil = '0.1';
    
  
  func=['img>' seuil];
  %compute gray roi
  omask = maroi_image(struct('vol', spm_vol(Pall), 'binarize',1,...
			 'func', func'));
  omask = maroi_matrix(omask);
  
  d = ['c1',f]; l = d;  d = [d ' func: ' func];  l = [l '_f_' func];
  omask = descrip(omask,d);  omask = label(omask,l);
   
%  do_write_image(omask,Pgris_mask);
   
  %extract signal
  yWg = y_struct(get_marsyW(omask,VY(k), spm_vol(Pgris), 'wtmean', 'v'));
  yWw = y_struct(get_marsyW(omask,VY(k), spm_vol(Pwhite), 'wtmean', 'v'));
  
  yg = y_struct(get_marsy(omask, spm_vol(Pgris), 'mean', 'v'));
  yw = y_struct(get_marsy(omask, spm_vol(Pwhite), 'mean', 'v'));
  yc = y_struct(get_marsy(omask, spm_vol(Pcbf), 'mean', 'v'));

%  ygnobias(k) = y_struct(get_marsy(og, spm_vol(Pnobias), 'mean', 'v'));
%  ywnobias(k) = y_struct(get_marsy(ow, spm_vol(Pnobias), 'mean', 'v'));

  Yg.Y(k,1) = yg.Y;  
  Yg.Ym(k,1) = yWg.Y;  
  Yg.Yv(k,1) = yWg.Yvar;
  
  Yw.Y(k,1) = yw.Y;  
  Yw.Ym(k,1) = yWw.Y;  
  Yw.Yv(k,1) = yWw.Yvar;

  Yc.Y(k,1) = yc.Y;  

  nbpts(k) = size(yg.regions{1}.Y,2);
%  nbpts_w(k) = size(yw.regions{1}.Y,2);
%  nbpts_c(k) = size(yc.regions{1}.Y,2);
  m = yg.regions{1}.mat;
  vol(k) = prod(sqrt(sum(m(1:3,1:3).^2)));
end


figure
subplot(5,1,1)
  plot(Yg.Y,'b')
subplot(5,1,2)
  plot(Yw.Y,'r')
subplot(5,1,3)
  plot(Yc.Y,'g')
subplot(5,1,4)
  plot(nbpts.*vol/1000)
subplot(5,1,5)
plot(Yg.Y+Yw.Y+Yc.Y)

figure
subplot(5,1,1)
  plot(Yg.Y'.*nbpts.*vol/1000,'b')
subplot(5,1,2)
  plot(Yw.Y'.*nbpts.*vol/1000,'r')
subplot(5,1,3)
  plot(Yc.Y'.*nbpts.*vol/1000,'g')
subplot(5,1,4)
 plot(nbpts/1000,'g')

Yg.Y'.*nbpts/1000
Yw.Y'.*nbpts/1000
Yc.Y'.*nbpts/1000

if exist('vlines')
  figure(2)

  for ki=1:5
    subplot(5,1,ki)
    yl=ylim;
    hold on
    for kk=1:length(vlines)
      plot([vlines(kk),vlines(kk)],yl,'k')
    end
    
  end
  
end
