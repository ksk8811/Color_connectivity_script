function Y = get_roi_data_split(og,ow,VY,Y,kvol)

%  og = transform_sn_roi(roigris,VY);

yg = y_struct(get_marsy(og, VY, 'mean', 'v'));
yg_v =  yg.regions{1}.Y;
yw = y_struct(get_marsy(ow, VY, 'mean', 'v'));
yw_v =  yw.regions{1}.Y;

%sog=struct(og);
%dim_o = size(sog.dat); mat_o = sog.mat;
%dog = sog.dat;
%bizare il ya une petite diff dans l origin des des mat .?.
dim_v = VY.dim; mat_v = VY.mat;

box_space = mars_space ( struct('dim',dim_v,'mat',mat_v) );

pos_g =  voxpts(og,box_space)'; %idem a 10-13 pres main entier ...
pos_w =  voxpts(ow,box_space)'; %idem a 10-13 pres main entier ...

%opos=y.regions{1}.vXYZ';
%ind=find(dog);
%[xi,xj,xk] = ind2sub(dim_v,ind);
bmin = min(pos_g);
bmax = max(pos_g);


kk=1;
sub_pts=8;skipp=1;
box_vec_i = bmin(1):sub_pts*skipp:bmax(1);
box_vec_j = bmin(2):sub_pts*skipp:bmax(2);
box_vec_k = bmin(3):sub_pts*skipp:bmax(3);

fprintf('Subdivising volume %s\n in %d box (%d,%d,%d) of %d points ... ',...
    VY.fname,...
    length(box_vec_i)*length(box_vec_j)*length(box_vec_k),...
    length(box_vec_i),length(box_vec_j),length(box_vec_k),...
    sub_pts*sub_pts*sub_pts);

start=clock;

for i=box_vec_i
  for j=box_vec_j
    for k=box_vec_k
            
      %g=zeros(dim_v);
      %g( i:(i+sub_pts-1),j:(j+sub_pts-1),k:(k+sub_pts-1) ) = 1;
      %nb_gris(kk)=length(find(g&dog));

      %gray
      pbgi = zeros(size(pos_g,1),1);
      for bi= i:(i+sub_pts-1),  pbgi = pbgi| ( pos_g(:,1) == bi );end
      pbgj = zeros(size(pos_g,1),1);
      for bj= j:(j+sub_pts-1),  pbgj = pbgj| ( pos_g(:,2) == bj );end
      pbgk = zeros(size(pos_g,1),1);
      for bk= k:(k+sub_pts-1),  pbgk = pbgk| ( pos_g(:,3) == bk );end
      
      pbg=pbgi&pbgj&pbgk;
      
      if length(find(pbg))>10 
	%white
	pbwi = zeros(size(pos_w,1),1);
	for bi= i:(i+sub_pts-1),  pbwi = pbwi| ( pos_w(:,1) == bi );end
	pbwj = zeros(size(pos_w,1),1);
	for bj= j:(j+sub_pts-1),  pbwj = pbwj| ( pos_w(:,2) == bj );end
	pbwk = zeros(size(pos_w,1),1);
	for bk= k:(k+sub_pts-1),  pbwk = pbwk| ( pos_w(:,3) == bk );end

	pbw=pbwi&pbwj&pbwk;

	if length(find(pbw))>10 
	  nb_gris(kk) = length(find(pbg));
	  nb_whit(kk) = length(find(pbw));
	  
	  ygm(kk) = mean(yg_v(pbg));
	  ygv(kk) = sqrt(var(yg_v(pbg)));
	  ygvn(kk) = sqrt(var( yg_v(pbg)./mean(yg_v(pbg)) ));
	  ygvn2(kk) = sqrt(var( yg_v(pbg) - mean(yg_v(pbg)) ));
	  
	  ywm(kk) = mean(yw_v(pbw));
	  ywv(kk) = sqrt(var(yw_v(pbw)));
	  ywvn(kk) = sqrt(var( yw_v(pbw)./mean(yw_v(pbw)) ));
	  ywvn2(kk) = sqrt(var( yw_v(pbw) - mean(yw_v(pbw)) ));	  
	
	  regions(kk,:) = [bi,bj,bk];
	  
	  kk=kk+1;
	end
      end
    
    end
  end
end

stopp=clock;
ct=datevec(datenum(stopp)-datenum(start));
fprintf('    compute in %d h %d m %2.0f s\n',ct(4),ct(5),ct(6));


Y.Yg(kvol,1) = mean(ygm);
Y.Yw(kvol,1) = mean(ywm);
Y.Yc(kvol,1) = mean(ywm-ygm);

Y.Ygmvar(kvol,1) = sqrt(var(ygm));
Y.Ywmvar(kvol,1) = sqrt(var(ywm));
Y.Ygvar(kvol,1) = mean(ygv);
Y.Ywvar(kvol,1) = mean(ywv);
Y.Ygvarn(kvol,1) = mean(ygvn);
Y.Ywvarn(kvol,1) = mean(ywvn);
Y.Ygvarn2(kvol,1) = mean(ygvn2);
Y.Ywvarn2(kvol,1) = mean(ywvn2);

Y.regions(kvol).ygm = ygm;
Y.regions(kvol).ygv = ygv;
Y.regions(kvol).ygvn = ygvn;
Y.regions(kvol).ywm = ywm;
Y.regions(kvol).ywv = ywv;
Y.regions(kvol).ywvn = ywvn;
Y.regions(kvol).nb_gris = nb_gris ;
Y.regions(kvol).nb_whit = nb_whit ;
Y.regions(kvol).regions = regions;



if 0%length(o)==1
  y = y_struct(get_marsy(o, VY, 'mean', 'v'));

  Y.Y(k,1) = y.Y;  Y.Yvar(k,1) = y.Yvar;

  Y.nbpts(k) = size(y.regions{1}.Y,2);
  
  [h,val]=hist(y.regions{1}.Y,500);  ind=find(h~=0);
  Y.hist(k).h1 = h(ind);Y.hist(k).v1 = val(ind);
  

%else
 
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
