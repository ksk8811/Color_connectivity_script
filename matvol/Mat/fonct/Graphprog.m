%*************** Fonctions Graphique ***************
 
if strcmp(action,'Plus')
  coupe = coupe+1;
  Vr.coupe = coupe; 
  hdla.Vr = Vr; Axeshdl{hdla_num} = hdla;  AxeshdlChanged
     
elseif strcmp(action,'Moins'),
  coupe = coupe-1;
  Vr.coupe = coupe; hdla.Vr = Vr; Axeshdl{hdla_num} = hdla; AxeshdlChanged
      
elseif strcmp(action,'go2coupe'),
    coupe = str2num(get(hdl.space.txt_editcoupe,'string'));
    Vr.coupe = coupe; hdla.Vr = Vr; Axeshdl{hdla_num} = hdla; AxeshdlChanged


elseif strcmp(action,'start_cine')

    set(hdl.space.start,'visible','off','UserData',1);
    set(hdl.space.stop ,'visible','on');
    
    set(gca, 'visible','off');
    
    tmpP = str2num(get(hdl.space.pause,'string'));
    nr_vol = Volume(NumVol).nr_time_vol;
    
    exams = plotmoy('get_exams');
    series = exams.Series;
    t_vol=[];
    for nser=1:length(series)
      tt = 1:series(nser).nbvol;
      tt(series(nser).Paradigm.skip) = [];
      t_vol = [t_vol, tt];
      vol_by_ser(nser) = length(tt);
    end

    nb_time = length(t_vol);nser=1;
    max = vol_by_ser(1);

    set(hdl.space.txt_nbvol,'string',num2str(nb_time),...
	'userdata',{t_vol,vol_by_ser,series});
    set(hdl.space.time_slider,'Min',1,'Max',nb_time,'SliderStep',[1/(nb_time-1) 10/(nb_time-1)],'value',nr_vol)

    hdl_p = hdl.hdl_p;
%onset for temporal mean
    oo = get(hdl_p.scale,'userdata');
    if ~isempty(oo)
      [chdl ok] = listdlg('ListString',oo{2});
      if ok
	ons=[];
	for kk=1:length(chdl)
	  ons = [ons oo{1}{chdl(kk)}];
	end
	ons = fix( (ons+1)/series(1).TR);
	fprintf('moy over %d position',length(ons))
	a  = inputdlg('dur in volume')
	dur = str2num(a{1});
	set(hdl.space.txt_nbvol,'string',dur)
      end
    end
    
    while (get(hdl.space.start,'UserData')==1 )

       nr_vol = nr_vol+1; 
       if exist('ons')
	 if nr_vol>dur,	   nr_vol=1;end
	 for kko = 1:length(ons)
	   vol_name = series(nser).vol_list(ons(kko)+nr_vol,:);
	    P = fullfile(series(nser).name,vol_name);
	    Volume(NumVol).Volmoy(kko) = spm_vol(P);
	 end
       else
	 if (nr_vol> max), 
	   if nser == length(series)
	     nser=1; nr_vol = 1 ; max = vol_by_ser(1);
	   else
	     nser = nser+1; max = max + vol_by_ser(nser);
	   end	 
	 end

	 vol_name = series(nser).vol_list(t_vol(nr_vol),:);
	 P = fullfile(series(nser).name,vol_name);
	 Volume(NumVol).Vol(1) =  spm_vol(P);
       end

       set(hdl.space.txt_edit_nbvol,'string',num2str(nr_vol));

       Volume(NumVol).nr_time_vol = nr_vol;
       %if the coupe number has been changed -> reload
         hdl = get(FigNum,'UserData');
         Axeshdl = hdl.Axeshdl;
         hdla = Axeshdl{hdla_num}; Vr = hdla.Vr; 
       Coupeprog   
       pause(0.005);
       pause(tmpP);
    end;    
    
    set(hdl.space.txt_edit_nbvol,'TooltipString', Volume(NumVol).Vol(1).fname)
    set(hdl.space.time_slider,'value',nr_vol);

    set(hdl.space.start,'visible','on');
    set(hdl.space.stop ,'visible','off');

elseif strcmp(action,'time_slider')

  aa= round(get(hdl.space.time_slider,'value'));
  set(hdl.space.txt_edit_nbvol,'string',num2str(aa))
  affichevol(1,'go2nbvol')

  
elseif strncmp(action,'start',5)

     if strcmp(action,'startmoins'), incr=-1;
     else incr=1;
     end

    dim = Vr.dim * Vr.M_rot(1:3,1:3);

    set(hdl.space.start,'visible','off','UserData',1);
    set(hdl.space.stop ,'visible','on');
    
%    set(gca, 'visible','off');
    
    tmpP = str2num(get(hdl.space.pause,'string'));

    while (get(hdl.space.start,'UserData')==1 )

      Vr.coupe = Vr.coupe + incr;
      if Vr.coupe>dim(3) ,Vr.coupe=1;end
      if Vr.coupe<=0 ,Vr.coupe=dim(3);end
      Coupeprog   
       pause(0.05);
    end;    

    hdla.Vr = Vr; Axeshdl{hdla_num} = hdla; AxeshdlChanged

    set(hdl.space.start,'visible','on');
    set(hdl.space.stop ,'visible','off');

elseif strcmp(action,'go2nbvol')

  nr_vol =  str2num(get(hdl.space.txt_edit_nbvol,'string'));

  aa = get(hdl.space.txt_nbvol,'userdata');
  t_vol = aa{1}; vol_by_ser = aa{2}; series = aa{3};

  nser = 1;max = vol_by_ser(1);
  while nr_vol>max
    nser = nser + 1; max = max +  vol_by_ser(nser);
  end

  vol_name = series(nser).vol_list(t_vol(nr_vol),:);
  P = fullfile(series(nser).name,vol_name);
  Volume(NumVol).Vol(1) =  spm_vol(P);
  Volume(NumVol).nr_time_vol = nr_vol;

  set(hdl.space.txt_edit_nbvol,'TooltipString', Volume(NumVol).Vol(1).fname)
  set(hdl.space.time_slider,'value',nr_vol);


elseif strcmp(action,'set_project_scale')
  if get(hdl.space.project ,'value')==0
    set(hdl.space.project,'userdata',1)
  end

elseif strcmp(action,'3D view')

   mat = Volume(NumVol).Vol.mat;
   ori = round(inv(mat) * [0 0 0 1]');
   

   for  kk = [4 3 1];
      axes(hdl.axe(kk))
      hdla = Axeshdl{kk};      Vr = hdla.Vr; 
      if kk==4,    
         Vr.M_rot  = SagitalMat; Vr.numrot = 2;
         Vr.coupe = ori(1);
      elseif kk==3, 
  	 Vr.M_rot  = CoronalMat; Vr.numrot = 3;
         Vr.coupe = ori(2);
      elseif kk==1, 
	 Vr.M_rot  = AxialMat;   Vr.numrot = 1;
         Vr.coupe = ori(3);
      end
      hdla.Vr = Vr;
      Axeshdl{kk} = hdla;
      AxeshdlChanged     
      affichevol(NumVol)

      hdl = get(FigNum,'UserData');
      Axeshdl = hdl.Axeshdl;
      hdla = Axeshdl{hdla_num}; Vr = hdla.Vr;

  end

elseif strncmp(action,'navigate',6)

[x,y,buton] = ginput(1);

  while buton==1

     AxeNum = gca; hdla_num = find(hdl.axe==AxeNum);
     hdla = Axeshdl{hdla_num};
     Vr = hdla.Vr;

     M_rot_for_Pos = inv(Vr.M_rot(1:3,1:3)); 
     pa = [x y 0]*M_rot_for_Pos;

     for  kk = [4 3 1]
        if ~(kk==hdla_num)
           axes(hdl.axe(kk))
           hdla = Axeshdl{kk};      Vr = hdla.Vr; 

           pr = pa * Vr.M_rot(1:3,1:3);
           Vr.coupe = round(pr(3));  

           hdla.Vr = Vr;  Axeshdl{kk} = hdla;
           Coupeprog
        end
     end

     AxeshdlChanged

     [x,y,buton] = ginput(1);

   end


elseif strncmp(action,'orient',6)

M_rot_for_Pos = inv(Vr.M_rot(1:3,1:3)); %bizarre 
%strange only for sagital M_rot differ from inv(M_rot)

  [x,y] = ginput(1);
  pa = [x y 0]*M_rot_for_Pos;

action  = get(hdl.space.orient,'value');
Vr.numrot = action;
  switch action

    case 1 %'orient_axial'
      Vr.M_rot  = AxialMat;
      
    case 2 %'orient_sagittal'
      Vr.M_rot  = SagitalMat;

    case 3 %'orient_coronal'
      Vr.M_rot  = CoronalMat;
      
  end

  M_rot = Vr.M_rot(1:3,1:3);
  pr = pa * M_rot;
  coupe = fix(pr(3));  

  Vr.coupe = coupe;
  hdla.Vr = Vr;  Axeshdl{hdla_num} = hdla; AxeshdlChanged
  set_axis = 'true';
      
elseif strcmp(action,'change_space');

  Volume(NumVol).Pos_space = Vr.box_space;

  num  = get(hdl.space.space,'value');
  name  = get(hdl.space.space,'string');
  box_view = name{num};
  set_box_view

  set_axis='ouaip';

  affichevol(3,'Change_roi_space');
  refreshbug=1;


elseif strcmp(action,'print_orient_info');

  if isfield(hdla,'hdl_info_str')
       delete(hdla.hdl_info_str)
  end

  Vi = Volume(NumVol).Vol(1)

  idim = Vi.dim(1:3); imat = Vi.mat;
  ivox = sqrt(sum(imat(1:3,1:3).^2));
  ifov = ivox.* idim;  ivol = prod(ifov/100);

  dim = Vr.dim;  vox = Vr.vox; mat = Vr.mat;
  fov = vox.* dim;
  vol = prod(fov/100);

  if spm_type(Vi.dim(4),'swapped'), swap='swapped';
  else swap='noswap'; end
  isize = prod(idim)*spm_type(Vi.dim(4),'bits')/8/1E6;
  rsize = prod(dim)*spm_type(Vi.dim(4),'bits')/8/1E6;

  stri = sprintf('%s Values [%3.1f M] scale=%3.1f (%s)',spm_type(Vi.dim(4)),isize,Vi.pinfo(1),swap);

     str = sprintf('Initial Volume %3.2f (litre)\n %s \ndim = [%d %d %d] \nVox = [%3.3f %3.3f %3.3f]\nFov = [%3.1f %3.1f %3.1f]\nMat = \n   %3.2f  %3.2f  %3.2f  %3.2f\n   %3.2f  %3.2f  %3.2f  %3.2f\n   %3.2f  %3.2f  %3.2f  %3.2f\n   %3.2f  %3.2f  %3.2f  %3.2f \nRepresented Volume',ivol,stri,idim,ivox,ifov,imat');


  if any(dim-idim(1:3)) | any(vox-ivox),
  str2 = sprintf(' %3.2f litre %3.1f M\ndim = [%d %d %d] \nVox = [%3.3f %3.3f %3.3f]\nFov = [%3.1f %3.1f %3.1f]\nMat = \n   %3.2f  %3.2f  %3.2f  %3.2f\n   %3.2f  %3.2f  %3.2f  %3.2f\n   %3.2f  %3.2f  %3.2f  %3.2f\n   %3.2f  %3.2f  %3.2f  %3.2f \n',vol,rsize,dim,vox,fov,mat');

  elseif any(any(mat-imat)),
  str2 = sprintf(' Mat = \n   %3.2f  %3.2f  %3.2f  %3.2f\n   %3.2f  %3.2f  %3.2f  %3.2f\n   %3.2f  %3.2f  %3.2f  %3.2f\n   %3.2f  %3.2f  %3.2f  %3.2f \n',mat');
  else
   str2  = sprintf(' identique');
  
end

  str = strcat(str,str2)

  pos = get(gca,'xlim');
  posx = pos(1)+diff(pos)/10;  posy = diff(get(gca,'ylim'))/2;

  hdla.hdl_info_str = text(posx,posy,str,'color',[0 1 1],'FontSize',12,'FontWeight','bold');

  Axeshdl{hdla_num} = hdla; AxeshdlChanged

elseif strcmp(action,'grille');
    if ~isfield(hdl,'grill');        hdl.grill=0;end
    
    if hdl.grill(1) == 0
      scale = 1;
      dim = Vr.dim * Vr.M_rot(1:3,1:3);

      x = [1:scale:dim(1)]-0.5 ; x = [x;x];
      y = [1 dim(2)-1]' ;
      hold on
      hh(:,1) = plot(x,y,'g:','markersize',1);
      hh(:,2) = plot(y,x,'g:','markersize',1);
%      hdl.grill = hh; set(gcf,'UserData',hdl);
   else
      delete(hdl.grill)
      hdl.grill = 0;
%      set(gcf,'UserData',hdl);
   end
   
   %set(gca,'xtick',[1:4:256]-0.5);
   %set(gca,'ytick',[1:4:256]-0.5);
   %grid;
   
elseif strcmp(action,'pixval');
   pixval

elseif strcmp(action,'colorbar');
	mycolorbar;

elseif strcmp(action,'colorlim_init');
  
       slice = get(hdla.Im,'CData');
       slice =slice(:);
       slice(isnan(slice))=[];
       if isempty(slice),  mi=0;ma=1; 
       else 
 	ma = max(slice); 	mi = min(slice);
       end
	  if mi==ma, ma=1;mi=0; end

 	set(hdl.color.edit_min,'string',num2str(mi))
 	set(hdl.color.edit_max,'string',num2str(ma))

 	maa = ma+(ma-mi)/4;	mii = mi-(ma-mi)/4;

	Sst = 0.01;
 	set(hdl.color.slide_max,'value',ma,'Min',mii,'Max',maa,'SliderStep',[Sst Sst*10]);
 	set(hdl.color.slide_mean,'value',(ma+mi)/2,'Min',mii,'Max',maa,'SliderStep',[Sst Sst*10]);
 	set(hdl.color.slide_min,'value',mi,'Min',mii,'Max',maa,'SliderStep',[Sst Sst*10]);


   set(AxeNum,'visible','on')
if isnumeric([mi ma])
       set(AxeNum,'clim',[mi ma])
else
	  fprintf('%s\n','hmm I thougth it was ok ...what s wrong ??');
	  keyboard
end
   set_axis='true';

if get(hdl.space.syn_coupe,'value')
   for na = 1:length(hdl.axe)
      if (hdl.axe(na)~=AxeNum),	set(hdl.axe(na),'clim',[mi ma]);      end
   end
end

elseif strcmp(action,'slide');   

   ma = get(hdl.color.slide_max,'value'); 
   mi = get(hdl.color.slide_min,'value'); 
 	
   set(hdl.color.slide_mean,'value',(ma+mi)/2);

   set(hdl.color.edit_min,'string',num2str(mi))
   set(hdl.color.edit_max,'string',num2str(ma))

if get(hdl.space.syn_coupe,'value')
   for na = 1:length(hdl.axe),	set(hdl.axe(na),'clim',[mi ma]);   end
else 
   set(AxeNum,'visible','on','clim',[mi ma])
end




elseif strcmp(action,'slide_mean');   

   ma = get(hdl.color.slide_max,'value'); 
   mi = get(hdl.color.slide_min,'value');
   me = (ma + mi)/2; 
   diff = get(hdl.color.slide_mean,'value') - me;
   mama = get(hdl.color.slide_max,'Max');
   mimi = get(hdl.color.slide_max,'Min');   
   ma = ma + diff;
   mi = mi + diff;   
   if ma > mama
   	ma = mama;
   	mi = 2*me - ma;
   end   
   if mi < mimi
   	mi = mimi;
   	ma = 2*me-mi;
   end

   set(hdl.color.slide_max,'value',ma);
   set(hdl.color.slide_min,'value',mi);

   set(hdl.color.edit_min,'string',num2str(mi))
   set(hdl.color.edit_max,'string',num2str(ma))

if get(hdl.space.syn_coupe,'value')
   for na = 1:length(hdl.axe),	set(hdl.axe(na),'clim',[mi ma]);   end
else 
   set(AxeNum,'visible','on','clim',[mi ma])
end

   
elseif strcmp(action,'Autolim');   
   set(AxeNum,'clim',[10 30]); %il faut tricher un peu avec matlab mais bon c'est du d�tail
   set(AxeNum,'CLimMode','auto');
   

elseif strcmp(action,'print')

   col_gui = 0 ; tmp_gui = 0;

   name = fieldnames(hdl.tpos_hdl);
   for kk=1:length(name),set(getfield(hdl.tpos_hdl,name{kk}),'visible','off');
   end
   name = fieldnames(hdl.Roi);
   for kk=1:length(name),set(getfield(hdl.Roi,name{kk}),'visible','off');
   end
   name = fieldnames(hdl.space);
   for kk=1:length(name),set(getfield(hdl.space,name{kk}),'visible','off');
   end

   name = fieldnames(hdl.color);
   if strcmp(get(getfield(hdl.color,name{1}),'visible'),'on')
	  col_gui = 1;
   end
   for kk=1:length(name),set(getfield(hdl.color,name{kk}),'visible','off');
   end

if isfield(hdl,'hdl_p')
   name = fieldnames(hdl.hdl_p);
   if strcmp(get(getfield(hdl.hdl_p,name{1}),'visible'),'on')
	  tmp_gui = 1;
   end
   for kk=1:length(name)
      set(getfield(hdl.hdl_p,name{kk}),'visible','off');
   end
end

   set(hdl.vol_list,'visible','off');
   set(hdl.view.close,'visible','off');

   uuu=get(gca,'unit');
   set(gca,'unit','normalized')

   cur=pwd;
   try 
	  cd(hdl.print_path)
   catch
   end
	  
   [Fname, Pname] = uiputfile('*.jpeg', 'where'); Fname = cat(2,Pname,Fname);
   print(gcf,'-dtiff',Fname);
   cd(cur);

   set(gca,'unit',uuu)

   name = fieldnames(hdl.Roi);
   for kk=1:length(name),set(getfield(hdl.Roi,name{kk}),'visible','on');
   end
   name = fieldnames(hdl.space);
   for kk=1:length(name),set(getfield(hdl.space,name{kk}),'visible','on');
   end
%	  set(hdl.space.time_slider,'visible','off')
%	  set(hdl.space.txt_nbvol,'visible','off')  
%	  set(hdl.space.txt_edit_nbvol,'visible','off')
%   set(hdl.space.axes,'visible','off')

   if tmp_gui
     name = fieldnames(hdl.hdl_p);
     for kk=1:length(name)
        set(getfield(hdl.hdl_p,name{kk}),'visible','on');
     end
   end

   if col_gui
     name = fieldnames(hdl.color);
     for kk=1:length(name),set(getfield(hdl.color,name{kk}),'visible','on');
     end
   end

   set(hdl.vol_list,'visible','on');
   set(hdl.view.close,'visible','on');
  

elseif strcmp(action,'fermer'),

   close(gcf);   

   hh = findobj('tag','affichevol');
   if isempty(hh)
%      clear affichevol
   else
      figure(hh(1))
   end
    
   byby =1;
   return
   
elseif strcmp(action,'remember'),
   Volume(NumVol).stackofmaps = [colormap; Volume(NumVol).stackofmaps];
   
elseif strcmp(action,'restore'),
   
   stac = Volume(NumVol).stackofmaps;
   lenm = Volume(NumVol).lengthofmap;

   colormap(stac(1:lenm,:));
   
   if size(stac,1)>lenm,
      stac(1:lenm,:)=[]; 
   end
   
elseif strcmp(action,'Voyons'),
    keyboard;
    return
    
elseif strcmp(action,'saveall'),
   save('volsave');
   plotmoy('saveall')

elseif strcmp(action,'loadall'),
   load('volsave');
   plotmoy('loadall');

   
elseif strcmp(action,'invertY'),
   aaa = get(gca,'ydir');
   
   switch lower(aaa)
   case 'reverse'
   	set(gca,'ydir','normal')
   case 'normal'
   	set(gca,'ydir','reverse')
   end
   
   

elseif strcmp(action,'load_free_s'),

%Res_dir = spm_get(-1,'*','Select a directory',[result_path filesep '..'])

%Arno Res_dir ='/home/romain/data/acquisition/frees_mri/brain';

list_f = dir(Res_dir);
list_f(1:3) = [];
for nnn = 1:length(list_f)
   ImgName = fullfile(Res_dir,list_f(nnn).name);
   fid = fopen(ImgName,'rb','n');
   Data(:,:,nnn) = fread(fid,[256 256],'uint8');
end

  Num_vol = length(Volume)+1;
  Volume(Num_vol).data  = Data;

  [rep sub]=rrr_cd_up(Res_dir);
  titre = get(hdl.vol_list,'string');
  titre{Num_vol} =   ['freesurfer ' sub];
  Volume(Num_vol).titre = titre{Num_vol};
  set(hdl.vol_list,'string',titre)


  Volume(Num_vol).Pos ={[]};
%rrr
ca_marche_plus
%  Vr.numrot = 1 ;  Vr.num = 1;
%  Vr.dim = [256 256 256];
%  Vr.vox = [1 1 1];
%  Volume(Num_vol).Vr = Vr;

elseif strcmp(action,'splatch'),
%very quick and badly done (just to test)


if isempty (Volume(NumVol).data)
   for cc = 1:Vr.dim(3)
       coupe = cc;
       get_slice;
       data(:,:,cc) = slice;
   end
else
   data = Volume(NumVol).data;
end
   fff = gcf;

   [img, vol] = splatchVol(data);


  Num_vol = length(Volume)+1;
  Volume(Num_vol).data  = vol;

  titre = get(hdl.vol_list,'string');
  titre{Num_vol} =   ['Splatch'];
  Volume(Num_vol).titre = titre{Num_vol};
  set(hdl.vol_list,'string',titre)

  Volume(Num_vol).coupe = 1;
  Volume(Num_vol).Pos ={[]};
%rrr
ca_marche_plus

%  Vr.numrot = 1 ;  Vr.num = 1;
%  Vr.dim = size(vol);
%  Vr.vox = [1 1 1];
%  Volume(Num_vol).Vr = Vr;

keyboard


elseif strcmp(action,'project')
%very quick and badly done (just to test) like splatch

   max_c = coupe;
   img = zeros(Vr.dim(1:2));

   for coupe=42:80 %max_c;
      get_slice;
      max_sli = max(max(slice));
      t = slice./max_sli;
      t(t<0.3) = 0;
      t = (t+0.00001).^6;

      img = (img.*(1-t) + t.*slice ) ;%* (1+coupe/max_c)/2 ;
      img = img+slice * (7 + coupe/max_c)/8 ;  
   end

  Num_vol = length(Volume)+1;
  Volume(Num_vol).data  = img;

  titre = get(hdl.vol_list,'string');  titre{Num_vol} =   ['proj'];
  Volume(Num_vol).titre = titre{Num_vol};  set(hdl.vol_list,'string',titre)

  Volume(Num_vol).coupe = 1;  Volume(Num_vol).Pos ={[]};

%rrr
ca_marche_plus
%  Vr.numrot = 1 ;  Vr.num = 1;  Vr.dim = [ size(img) 1];
%  Vr.vox = [1 1 1];  Volume(Num_vol).Vr = Vr;


keyboard

elseif strcmp(action,'singleV'),

   for na = 1:length(hdl.axe)
     set(hdl.axe(na),'Position',[1 1 1 1],'visible','off');
   end

   hdl.view.max=hdl.view.max_ini;
   hdl.view.mode = 1;  
   set_axis='true';
   mmm=hdl.view.max;

   % Modif VP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %set(gca,'Position',[29  80  mmm(1) mmm(2)],'visible','on');   

   set(gca,'Position',[0.0350    0.1129    0.3825    0.3657],'visible','on');
   % Fin Modif VP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   set(FigNum,'userdata',hdl);


elseif strcmp(action,'multiV4'),

   mmm=hdl.view.max_ini /2;
   hdl.view.max=mmm;
   hdl.view.mode = 2;  

   for na = 1:length(hdl.axe)
     hddl = Axeshdl{na};

     a_pos = hddl.cur_pos;
     set(hdl.axe(na),'Position',a_pos,'visible','on')

   end

   set(FigNum,'userdata',hdl);
   set_axis='true';

elseif strcmp(action,'chooseVol'),
  lihdl = get(hdl.vol_list,'string');
  [chdl ok] = listdlg('ListString',lihdl,'ListSize',[840 600]);
  if ~ok, return;end

  for kk=1:length(chdl)
     axes(hdl.axe(kk))
     affichevol(chdl(kk))
  end

elseif strcmp(action,'check_reg'),

  lihdl = get(hdl.vol_list,'string');
  [chdl ok] = listdlg('ListString',lihdl,'ListSize',[840 600]);

  for kk=1:length(chdl)
      %Vol{kk} = Volume(chdl(kk)).Vol.fname;
      Vol(kk) = Volume(chdl(kk)).Vol;
  end


%  spm_check_registration(char(Vol))
  spm_check_registration(Vol)
  spm_orthviews('MaxBB')    


elseif strcmp(action,'SaveData'),

  [Fname, Pname] = uiputfile('*', 'where');
  if Fname
    Fname = cat(2,Pname,[Fname '.img'])
    Vi = Volume(NumVol).Vol(1);

    new_img =  deal(struct(...
		      'fname',	Fname,...
		      'dim',	[Vr.dim Vi.dim(4)],...
		      'mat',	 Vr.mat,...
		      'pinfo',	[1 0 0]',...
		      'descrip', [Vi.descrip, ' resampled'] )); 

   end

   new_img = spm_create_image(new_img);

   for k=1:Vr.dim(3)
     slice(:,:,k) = my_get_slice(Vi,Vr,k);
  end
     new_img = spm_write_vol(new_img,slice);


elseif strcmp(action,'visu'),
   
  lihdl = {'Pos','P64','Tpos','Cont','Clus'};
  [chdl ok] = listdlg('ListString',lihdl,'ListSize',[840 600]);
  if ok
    switch chdl
      case 1
	hdlP = hdl.Pos;
      case 2
	hdlP = hdl.Pos64;
      case 3
	Ser_in = str2num(get(hdl.tpos_hdl.Series_in,'string'));
	hdlP = hdl.Tpos(Ser_in) ;  
      case 4
	hdlP = hdl.Cont ;   
      case 4
	hdlP = hdl.Clus ;   
    end
    
    choix = questdlg('une chose a la fois', ...
                     'the choice', ...
                     'color','size','size');
    %keyboard;
                        
    switch choix
      case 'color'
	uisetcolor(hdlP,'choose a nice color');
      case 'size'
	
	tmp1 = get(hdlP,'MarkerSize');
	tmp2 = get(hdlP,'Marker');
	
	a = inputdlg({'size','type'},'bloups',1,{num2str(tmp1),tmp2});
	
	set(hdlP,'MarkerSize',str2num(a{1}))
	set(hdlP,'Marker',a{2})
    end

  end

end;





