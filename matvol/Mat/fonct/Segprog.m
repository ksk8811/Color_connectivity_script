%*************** Fonctions Segmentation ***************

if strcmp(action,'Hist'),  

 % hh=findobj(FigNum,'label','Hist');
 % set(hh,'label','no more Hist ','callback','affichevol(2,''Hist_none'')');
%  hdla.histo = 0;
%  set(AxeNum,'userdata',hdla)
nb_bins = 128;
ci=0;

if isempty(Bw) 
  info = sprintf('loading volume data \n');
  fprintf(info)
  Bw.minval = -inf;Bw.maxval=inf;
  Bw.dim = Vr.dim(3);
  Bw.nbpts = prod(Bw.dim);
end

  for coupe = 1:Vr.dim(3)

    if exist('info')
      get_slice;
      Bw.data(:,:,coupe) = slice;
    else
      slice = Bw.data(:,:,coupe);
    end
    slice(slice==0) = NaN;
    ind=find(~isnan(slice));
    Bw.nbpts = Bw.nbpts - length(ind);
    if ~isempty(ind)
      ci = ci+1;
      [ his(ci,:),xhis(ci,:)] = hist(slice(ind),nb_bins);
    end
  end

  roi_data(1).tempo = his;
  roi_data(1).xtempo = xhis;
  roi_data(1).pos = [];

  ind=find(~(isnan(Bw.data)|(Bw.data==0)));
%  [ Tempo,Xtempo] = hist(Bw.data(ind),nb_bins);
  Tempo = his;
  Xtempo = xhis;

  Sess = {};
  glob_name = 'histogram';
  sub_name{1}='his_c';

  axes(hdl.axe(2));
 % hdla.Num = NumVol;
  Axeshdl{2} = hdla; AxeshdlChanged

  hdlv = hdl;  hdl = hdl.hdl_p;

  add_more_data;

  hdl = hdlv;   axes(AxeNum)

elseif strcmp(action,'Seg'),

%  if isempty(Bw)
    axes(hdl.axe(2));
    hh2 = get(hdl.axe(2),'userdata');

    [x,y,b] = ginput(1)
    yval = get(gca,'ylim'); yval(2) = yval(2)*0.8;
    b
    if b==1 |b==3
      minval = x; maxval = inf;
      hold on 
      hdla.sep_line = plot([x x],yval,'r--');
    end  
    if b==3
      [x,y,b] = ginput(1);
      maxval = x;
    end

  if (Bw.minval < minval)|(Bw.maxval > maxval)
    Bw.data = []
    for coupe = 1:Vr.dim(3)
      get_slice;
      ind = find( (slice(:) < minval)|(slice(:) > maxval) );
      slice(ind) = NaN;
      Bw.data(:,:,coupe) = slice;
    end
  else
    for coupe = 1:Vr.dim(3)
      slice = Bw.data(:,:,coupe);
      ind = find( (slice(:) < minval)|(slice(:) > maxval) );
      slice(ind) = NaN;
      Bw.data(:,:,coupe) = slice;
    end

  end
  ind=find(~isnan(Bw.data));
  Bw.nbpts = length(ind);
  Bw.maxval = maxval;  Bw.minval = minval;
      
elseif strcmp(action,'LoadMask'),
    [Bw,DESCRIP,M,ORIGIN,dim] = readvol({Result_SPM},'un peu complique');
nx=dim(1);
   Bw(1:nx,:,:) = Bw(nx:-1:1,:,:);
   Bw(find(~Bw)) = NaN;

   if hdl.Bw==0
   	titreBw = strcat('masque :',num2str(size(Bw)));
   	hdl.Bw = NewFigure(titreBw);
	set(hdl.Bw,'Position',[576 364 421 360]);
      	set(FigNum,'UserData',hdl);
        figure(FigNum);         
   end
  
elseif strcmp(action,'LoadBw'),
   cd ([repDataLog,'volume',filesep,'Bw'])
      [Fname, Pname] = uigetfile('*.mat', 'where');
   cd (workdir)
   
   if Fname
      Fname = cat(2,Pname,Fname);
      Fname = cat(2,'load ',Fname);
      eval(Fname); %charge une variable Bw
      
	   if hdl.Bw==0
   		titreBw = strcat('masque :',num2str(size(Bw)));
   		hdl.Bw = NewFigure(titreBw);
		set(hdl.Bw,'Position',[576 364 421 360]);
      		set(FigNum,'UserData',hdl);
        	figure(FigNum);         
  	   end
   end
   
   
elseif strcmp(action,'Bw2Pos')
   kp = size(Pos,1)+1;
   for c = 1:NbCoupe
   	[indl indc] = find (Bw(:,:,c));
	   dimc = length(indl)
   	for k = 1:dimc
      	Pos(kp,:) = [indl(k) indc(k) c ];
      	kp = kp+1;
   	end
   end
   Volume(hdl.Num).Pos =Pos;

   
elseif strcmp(action,'Bw2Cont'),
   if ~isempty(Bw)
      if size(Bw,1)==64 & NbLigne == 256
         display('expand BW 64->256');
         
         Bw = expand64to256(Bw);
      end      
      
      if size(Bw,1)==128 & NbLigne == 256
         display('expand BW 128->256');
         
         Bw = expand128to256(Bw);
      end    
      
Cont = contourc(Bw(:,:,coupe),1);  Cont(:,1)=[];
Volume(hdl.Num).Cont = Cont;

   end
   
   

elseif strcmp(action,'Hist_none'),  

  hh=findobj(FigNum,'label','no more Hist');
  set(hh,'label','Hist ','callback','affichevol(2,''Hist'')');

  hdla = rmfield(hdla,'histo');
  set(AxeNum,'userdata',hdla)

   
 
elseif strcmp(action,'Segone'),
   answer = inputdlg({'min','max'},'seuil de segmentation',1,{'150','300'});
   smin = str2num(answer{1})
   smax = str2num(answer{2})

   CoupeVol = Volume(hdl.Num).data(:,:,coupe);
   Bw(:,:,coupe) = (smin<CoupeVol) & (Volcoupe<smax);
elseif strcmp(action,'choose'),
   if hdl.Bw
      figure(hdl.Bw);
      Bw(:,:,coupe) = bwselect(4);
   end
elseif strcmp(action,'rempli'),
   bruit = ~Bw(:,:,coupe);  
   rien  = bwselect(bruit,1,1,4);
   Bw(:,:,coupe) = ~rien;      

elseif strcmp(action,'CleanCoupeBw');
   
   a = inputdlg({'c1','c2','c3','c4','c5','c6','c7','c8','c9','c10'},'bloups',1,num2cell(['0' '0' '0' '1' '1' '1' '1' '0' '0' '0']));
   for c = 1:10
      bol = str2num(a{c});
      if(bol==0)
         Bw(:,:,c) = 0;
      end
   end

        
elseif strcmp(action,'SaveBw'),   
   cd ([repDataLog,'volume',filesep,'Bw'])
   [Fname, Pname] = uiputfile('*.mat', 'where');
   if Fname
	   Fname = cat(2,Pname,Fname)
	   Fname = cat(2,'save ',Fname,' Bw');
   	eval(Fname);
   end
   cd (workdir)


elseif strcmp(action,'CloseBw'),
    delete(hdl.Bw);  hdl.Bw=0;
    %Bw=[];on le laisse pour le contour
    set(gcf,'UserData',hdl);

   
elseif strcmp(action,'CleanCont&Bw'),
   delete(hdl.Cont);
   delete(hdl.Bw);  hdl.Bw=0;
    
   Bw=[];Cont=[];
   set(gcf,'UserData',hdl);
   Volume(hdl.Num).Cont = Cont;
   
   
end;
