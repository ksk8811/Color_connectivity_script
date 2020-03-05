%*************** FONCTION ROI Pos ****************

M_rot = Vr.M_rot;
M_rot_for_Pos = inv(M_rot(1:3,1:3));


if strcmp(action,'ROI_draw')

   if get(hdl.Roi.draw,'value')
	
	   set(gcf,'WindowButtonDownFcn','set(gcf,''WindowButtonMotionFcn'',''draw'')')
	   set(gcf,'WindowButtonUpFcn','affichevol(3,''ROI_draw_end'')')
   else
	   set(gcf,'WindowButtonUpFcn','')
	   set(gcf,'WindowButtonDownFcn','')
	   zoom;zoom;
   end
	realy_refresh = 1;

elseif strcmp(action,'ROI_draw_end'),

   set(gcf,'WindowButtonMotionFcn','');

   hdl_poly = draw(0);

 if ~isempty(hdl_poly)
   xp = get(hdl_poly,'XData'); yp = get(hdl_poly,'YData'); 

   delete(hdl_poly) ; clear draw;

   dim =  Vr.dim;
   dim = dim*M_rot(1:3,1:3);
   Bw1 = remplie(yp',xp',dim(1),dim(2));

   [x,y] = find(Bw1);
 
   k = size(pPos,1) ;
   l = length(x);
   for m=1:l
      pPos(k+m,:) = [ x(m) y(m) coupe] * M_rot_for_Pos;
   end

 else 
   realy_refresh = 1;
 end

elseif strcmp(action,'ChoisiPos'),

   if get(hdl.Roi.draw,'value')
	set(hdl.Roi.draw,'value',0)
	set(gcf,'WindowButtonUpFcn','');
	set(gcf,'WindowButtonDownFcn','')
	   zoom;zoom;
   end

   if strcmp( get(gcf,'WindowButtonDownFcn') , 'zoom down')
	zzz=2	;
	zoom
   end

    hold on
    k = size(pPos,1)+1;
    
    while (1==1) 
       [x,y,buton] = ginput(1);
       
       if buton==1
          l = 1; go = 1;
          while (l<k & go )
             comp = ( pPos(l,:) == [round(x) round(y) coupe]*M_rot_for_Pos );
             if ( (comp(1)==1 & comp(2)==1) & comp(3)==1)
                go = 0;
             end
             l = l+1;
          end
          if go
             pPos(k,:) = [round(x) round(y) coupe]*M_rot_for_Pos;
             k=k+1;
          end
             
       elseif buton==3
          l = 1; go = 1; 
          while (l<k & go )
             comp = ( pPos(l,:) == [round(x) round(y) coupe]*M_rot_for_Pos);
             if ( (comp(1)==1 & comp(2)==1) & comp(3)==1)
                go = 0;
             end
             l = l+1;
          end
          if go

%       Pos{workin_pos} = pPos;Volume(NumVol).Pos = Pos;

	     realy_refresh = 1;
		if exist('zzz'), zoom; end
             return
          else
             realy_refresh = 1;
	     pPos(l-1,:) = [];
             k=k-1;
          end
       end;

       Pos{workin_pos} = pPos;Volume(NumVol).Pos = Pos;     
       Coupeprog
    end
    

elseif strcmp(action,'Equerre');
otherP = size(pPos,1);

  for kk=1:2
    [xP,yP,buton] = ginput(1);
    pPos(otherP+kk,:) = [round(xP) round(yP) coupe]*M_rot_for_Pos;
    xl(kk) = xP ; yl(kk) = yP;
  end

  line(xl,yl)

  mat = Volume(NumVol).Vol.mat;

%passons en milimetre
posp = [xl' yl' [1;1]]*M_rot_for_Pos;
posp= [posp [1; 1]];
posm = posp * mat;
posm(:,4)=[];posm = posm*inv(M_rot_for_Pos);
xl =posm(:,1)';
yl = posm(:,2)';

%equation de la droite y = ax+b
  a = (yl(2)- yl(1))/(xl(2)-xl(1));
  b = yl(1) - xl(1)*(yl(2)-yl(1))/(xl(2)-xl(1));
%calcule le point a d milimetre

 hh=findobj(FigNum,'label','Equerre distance');
 d = get(hh,'userdata');

  c2 = a*a+1;
  c1 = 2*(b-yl(2))*a - 2 * xl(2);
  c0 = (b-yl(2))*(b-yl(2)) +  xl(2)* xl(2) - d*d;

  if d>0
    xl(2) = max(roots([c2 c1 c0]));
  else
    xl(2) = min(roots([c2 c1 c0]));
  end    
  yl(2) = a*xl(2)+b;

%un deuxieme poin sur la droite perpendiculaire passant par xl(2)
  x=xl(2)+20;
  y = yl(2) - (x-xl(2))*(xl(2)-xl(1))/(yl(2)-yl(1));

  xl(1) = x; yl(1)=y;
%back in pixel
%  xl = xl / Vr.vox(1);  yl = yl / Vr.vox(2);

  posm = [xl' yl' [1;1]]*M_rot_for_Pos;
  posm= [posm [1; 1]];
  posp = posm * inv(mat);
  posp(:,4)=[];posp = posp*inv(M_rot_for_Pos);

  xl =posp(:,1)';  yl = posp(:,2)';

%agrandisson la perpendiculaire  y = ax+b
  a = (yl(2)- yl(1))/(xl(2)-xl(1));
  b = yl(1) - xl(1)*(yl(2)-yl(1))/(xl(2)-xl(1));

  limx= [0 Vr.dim(1)] ;limy= [0 Vr.dim(2)] ;
  for k=1:2
    x=limx(k);
    y = a*x+b;
    if (k==1 & y <limy(k)) | (k==2 & y > limy(k))
      y = limy(k);
      x = (y-b)/a;
    end
    xp(k) = x ; yp(k)=y;
  end

  he =  line(xp,yp);

  for k = 1:limy(2)
    yp = k;
    xp = (yp-b)/a;
    pPos(k+2+otherP,:) = [round(xp) round(yp) coupe]*M_rot_for_Pos;
  end

    
elseif strcmp(action,'Equ_set_d');

  a = inputdlg({'in mm'},'distance from 2 pt',1,{'40'});
  d = str2num(a{1});
  hh=findobj(FigNum,'label','Equerre distance');
  set(hh,'userdata',d)
  

elseif strcmp(action,'expandROI');
  
  pview = pPos*M_rot(1:3,1:3);
  
  ind = pview(:,3)==coupe;
  dim = Volume(NumVol).Vol.dim(1:3);
  dim = dim*M_rot(1:3,1:3);

  for kk=[1:(coupe-1),(coupe+1):dim(3)]
    p = pview(ind,1:2);
    p(:,3) = kk;
    pPos = [pPos;p*M_rot_for_Pos];
  end
  
   
elseif strcmp(action,'ROItomask');
%no more use for the object

  M = Volume(NumVol).M;
  DIM = Volume(NumVol).Vol.dim(1:3);

  workdir=pwd;
  cd (result_path)
  
  [Fname, Pname] = uiputfile('*', 'where');
  if Fname
    Fname = cat(2,Pname,Fname)
    
    mask =  deal(struct(...
		      'fname',	[Fname '.img'],...
		      'dim',		[DIM,spm_type('uint8')],...
		      'mat',		M,...
		      'pinfo',	[1 0 0]',...
		      'descrip',	'mask from ROI')); 
  
    mask = spm_create_image(mask);

    Bw=zeros(DIM); n = 1;
    for k=1:size(Pos{n},1)
      Bw(Pos{n}(k,1),Pos{n}(k,2),Pos{n}(k,3))=1;
    end
    
    mask = spm_write_vol(mask,Bw);
  
  end
  cd (workdir)


elseif strcmp(action,'clean_SelectPos');
	
	   set(gcf,'WindowButtonDownFcn','set(gcf,''WindowButtonMotionFcn'',''draw'')')
	   set(gcf,'WindowButtonUpFcn','affichevol(3,''clean_SelectPos_end'')')
	realy_refresh = 1;

elseif strcmp(action,'clean_SelectPos_end');

	   set(gcf,'WindowButtonUpFcn','')
	   set(gcf,'WindowButtonDownFcn','')
	   zoom;zoom;
	realy_refresh = 1;


   set(gcf,'WindowButtonMotionFcn','');

   hdl_poly = draw(0);

 if ~isempty(hdl_poly)
   xp = get(hdl_poly,'XData'); yp = get(hdl_poly,'YData'); 

   delete(hdl_poly) ; clear draw;

   dim =  Vr.dim;
   dim = dim*M_rot(1:3,1:3);
   Bw = remplie(yp',xp',dim(1),dim(2));

   [x,y] = find(Bw);

   tmp_pos = pPos*(M_rot(1:3,1:3));
 
   ind = find(tmp_pos(:,3)==coupe);
   l = length(ind);
   m=1;
   for k = 1:l
      p = ind(k);
      if Bw(tmp_pos(p,1),tmp_pos(p,2))==1
         sup(m) = ind(k);
         m = m+1;
       else
      end

   end
   if exist('sup')
     tmp_pos(sup,:) = [];
     pPos = tmp_pos*inv(M_rot(1:3,1:3));
   end
end
   
   
elseif strcmp(action,'SavePos');

  Ser  = str2num(get(hdl.Roi.disp,'string'));
  l = spm_input('Label for ROI', '+1', 's', '');

  for kk = Ser
     if kk>length(Pos)
     else

        if length(Ser)>1, lab = [l '_' num2str(kk)];
        else lab = l; end

        pp = Pos{kk};
        s = struct('XYZ',pp','mat',Vr.mat);
        roi_o = maroi_pointlist(s,'vox');
        roi_o = label(roi_o,lab);

        marsbar('saveroi',roi_o,'n');
     end
  end


   realy_refresh = 1;

elseif strcmp(action,'SavePos_noise');

%  Ser  = str2num(get(hdl.Roi.disp,'string'));
  lab = 'internal noise';
  
  pp = Pos{1};
  s = struct('XYZ',pp','mat',Vr.mat);
  roi_o = maroi_pointlist(s,'vox');
  roi_o = label(roi_o,lab);

  roi_fname = [Volume(NumVol).Vol.fname(1:(end-4)),'_noise_roi.mat']
  saveroi(roi_o, roi_fname);


elseif strcmp(action,'buildROI');

  roitype = get(gcbo,'label');

   workdir=pwd;
   cd (result_path)
   %roi_o = mars_build_roi(roitype);
   roi_o = mars_build_roi;

%   roi_o=spm_hold(roi_o,0)
   
   cd (workdir)  

  if ~isempty(roi_o)
    box_space = Vr.box_space;
    if isempty(Pos{1}),num_pos=0;else num_pos=length(Pos);end
    pPos =  voxpts(roi_o,box_space)';
    Pos{num_pos+1} =  pPos;
    workin_pos = length(Pos);
    set(hdl.Roi.disp,'string',['1:',num2str(workin_pos)]);
  end

%  if isfield(Volume(NumVol),'Roi')
%    Roi = Volume(NumVol).Roi
%    Roi{end+1} = roi_o;
%  else
%    Volume(NumVol).Roi{1} = roi_o;
%  end

elseif strcmp(action,'3D merge')

  Ser  = str2num(get(hdl.Roi.disp,'string'));

  if ~(length(Ser)==3)
    fprintf('sorry but need 3 ROI\n')
    return
  end

  kkk=1;
  for kk=Ser
     pmin(kkk,:) = min(Pos{kk});
     pmax(kkk,:) = max(Pos{kk});
     kkk=kkk+1;
  end
  mmin = min(pmin);mmax = max(pmax)+1;
  Bw1 =  zeros(mmax-mmin);  Bw2 =  zeros(mmax-mmin);  Bw3 =  zeros(mmax-mmin);

  kkk=1;
  for kk=Ser
     ext = pmax(kkk,:)-pmin(kkk,:);
     ext = find(~ext);
     ppos = Pos{kkk};
     for ll=1:length(ppos)
        a = ppos(ll,:)-mmin + 1;
        switch ext
          case 1
             Bw1(:,a(2),a(3)) = 1;
          case 2
             Bw2(a(1),:,a(3)) = 1;
          case 3
             Bw3(a(1),a(2),:) = 1;
        end
     end

     kkk=kkk+1;
  end

  Bw = Bw1.*Bw2.*Bw3;
  dim=size(Bw)
  kkk=1;
  for k=1:dim(1)
    for l=1:dim(2)
      for m=1:dim(3)
        if Bw(k,l,m)
         Npos(kkk,:) = [k l m] + mmin -1;
         kkk=kkk+1;
        end
      end
    end
  end

    Pos{end+1} =  Npos;


elseif strcmp(action,'loadPos');

   workdir=pwd;
   cd (result_path)
   %[Fname, Pname] = uigetfile('*.mat,*.img', 'where'); Fname = cat(2,Pname,Fname);   
   roilist = spm_select([0 6],'mat','Select ROI(ss) to view');
   cd (workdir)  

   if ~isempty(roilist)
     box_space = Vr.box_space;

      if isempty(Pos{1}),num_pos=0;else num_pos=length(Pos);end
     for i = 1:size(roilist,1)
       roi_o = maroi('load', deblank(roilist(i,:)));
       pPos =  voxpts(roi_o,box_space)';
       Pos{num_pos+i} =  pPos;
     end
     workin_pos = length(Pos);
     set(hdl.Roi.disp,'string',['1:',num2str(workin_pos)]);
   else 
     return;
   end

%   if ~isempty(Pos)
%      choix = questdlg('keep the existing ROI', ...
%                         'the choice', ...
%                         'yes','no','no');
%      switch choix
%	case 'yes'
%   	case 'no'
%   		Pos =  []; 
%	end
%   end
%   sp = mars_space(Volume(NumVol).Vol);
%   Pos = [Pos ; voxpts(roi_o,sp)']	;
 

elseif strcmp(action,'Change_roi_space');

  box_space = Vr.box_space;
  Pos_space = Volume(NumVol).Pos_space;

  if ~isempty(Pos{1})
    for kk=1:length(Pos)
      pPos = Pos{kk};
      s = struct('XYZ',pPos','mat',Pos_space.mat);
      roi_o = maroi_pointlist(s,'vox');
      
      pPos =  voxpts(roi_o,box_space)';
      Pos{kk} = pPos ;
      set(hdla.MPoshdl(kk),'Xdata',0,'Ydata',0);
    end
    pPos = [];
  end

  Volume = rmfield(Volume,'Pos_space');
   
elseif strcmp(action,'CleanPos');

  ind = 1:(workin_pos-1); 
  if workin_pos<length(Pos),ind = [ind ,(workin_pos+1):length(Pos)];end
  Pos = Pos(ind);

  pPos=[];
  
  if isempty(Pos); Pos={[]};end

  set(hdla.MPoshdl(workin_pos),'Xdata',0,'Ydata',0);
   realy_refresh = 1;

elseif strcmp(action,'CleanAllPos');
  pPos=[];
  Pos={[]};

  set(hdla.MPoshdl(:),'Xdata',0,'Ydata',0);

elseif strcmp(action,'show_one_pos'),
  sur_plot_pos = varargin{2};
  Vr.coupe = sur_plot_pos(3);
  hdla.Vr = Vr; set(AxeNum,'UserData',hdla); 

elseif strcmp(action,'visu_Pos_size'),

   hdlP = hdla.MPoshdl(workin_pos);

   tmp1 = get(hdlP,'MarkerSize');
   tmp2 = get(hdlP,'Marker');
 
   a = inputdlg({'size','type'},'bloups',1,{num2str(tmp1),tmp2});
   set(hdlP,'MarkerSize',str2num(a{1}))
   set(hdlP,'Marker',a{2})
   realy_refresh=1;

elseif strcmp(action,'visu_Pos_color'),

   hdlP = hdla.MPoshdl(workin_pos);

   uisetcolor(hdlP,'sometimes it works ...');
   realy_refresh=1;

elseif strcmp(action,'visu_Pos_legende'),

  cur_axe=gca;

  if isfield(hdl,'col_legende')
    axes(hdl.col_legende)
  else
     hdl.col_legende = axes('Units','normalized','Position',[0.85 0.1 0.05 0.5])
   end

     hold on
   for kk =1:length(hdla.MPoshdl)
     col = get(hdla.MPoshdl(kk),'color');
     size = get(hdla.MPoshdl(kk),'markersize');
     mark = get(hdla.MPoshdl(kk),'marker');

       plot(1,kk,'marker',mark,'erasemode','none','markersize',size,'color',col);
   end
     zoom
     axes(cur_axe)

end;






if 0
%to apply the affine normalization to a roi

t=load ('fMichel-0002-00001-000001_sn.mat')
Q = t.VG(1).mat*inv(t.Affine)/VF.mat  

roilist = spm_select([0 6],'mat','Select ROI(ss) to view');
roi_o = maroi('load', deblank(roilist(i,:)));

 [ptsmm]=realpts(roi_o,Vr.box_space)
 pts=[ptsmm;ones(1,size(ptsmm,2))]  
 pstsn= Q*pts                     
 vptsn = inv(Vr.box_space.mat)*ptsn

Volume(NumVol).Pos={round(vptsn(1:3,:)')}

end





