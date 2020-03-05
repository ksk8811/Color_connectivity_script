
if strcmp(action,'init')

if ~isfield(hdl,'hdl_p')

  affichevol(11,'hide_color')

%  axes(hdl.axe(2));
     hddla = Axeshdl{2};

  initfigtmp

  hddla.NumVol = 0; hddla.Im = 0; NumVol=0;
  
  hdl.hdl_p = hdl_p ;

  Axeshdl{2} = hddla; AxeshdlChanged



end
plotmoy;

elseif strcmp(action,'charge_roi')

  if isempty(Pos{1})
    if ~isempty(Tpos)
      fprintf('trying to find cluster from Tpos')
      affichevol(4,'Cluster_ini');
      if isempty(Pos{1})
	fprintf('meme pas de carte T (I can not do anything)')
	return
      end
    else
      return
    end

    %  end
%  if isfield(Volume(NumVol),'roi_Pos')
%    roi_list = Volume(NumVol).roi_Pos;

  else %if draw by hand or roi load

%    Pos_mat = Volume(NumVol).Pos_space.mat;

    for k = 1:length(Pos)
       s = struct('XYZ',Pos{k}','mat',Vr.mat );
       roi_list{k} =  maroi_pointlist(s,'vox');
       roi_list{k} = label(roi_list{k},['roi',num2str(k)]);
     end
   end


%  if isfield(Volume(NumVol),'Roi')
%    Roi = Volume(NumVol).Roi;
%    roi_list(end+1:(end+length(Roi))) = Roi;
%  end

  axes(hdl.axe(2));

  plotmoy('chargeRoi',roi_list)

return
elseif strcmp(action,'init_old')

   P = spm_get([Inf],'SPM*.mat',{['select SPM struct']},Result_SPM);

   load(P{1},'VY')

   if exist('Clus_Pos')
	Pos=[];
	for k = 1:length(Clus_Pos)
		Pos = cat(1,Pos,Clus_Pos{k}(:,1:3));
		Clus_size(k) = size(Clus_Pos{k},1);
	end
	%Pos(:,2) = DimFonc+1 - Pos(:,2) ;
   else
	tmp = Pos;
	Pos(:,1) = tmp(:,2);
	Pos(:,2) = DimFonc+1 -tmp(:,1);   
   end

         %si on veux afficher les xyz utilisees dans spm_sample_vol
		%Pos(:,2) = xyz(:,1);   
         	%Pos(:,1) = 65-xyz(:,2);

   for t=1:size(VY,1)
   	Tempo(:,t) = spm_sample_vol(VY(t),Pos(:,1),Pos(:,2),Pos(:,3),0);
   end

if(0)
   load(P{1},'VY','Vbeta','xX')
   cwd = pwd;
   cd(Result_SPM)
   nb_beta = length(Vbeta);
   for b=1:nb_beta
	Vbeta_s(b) = spm_vol(Vbeta{b});
   end

   for b=1:nb_beta
      beta = spm_sample_vol(Vbeta_s(b),Pos(:,1),Pos(:,2),Pos(:,3),0);
      Beta(:,:,b) = beta* xX.X(:,b)';
   end
   cd(cwd)
end

%   plotmoy(Tempo,Clus_size, Volume.Clus_name)
plotmoy(Tempo)
   
elseif strcmp(action,'cinema')

   set(hdl.space.start,'BackgroundColor',[0 1 0],'visible','on')
   set(hdl.space.start,'Callback','affichevol(1,''start_cine'')');
   set(hdl.space.stop,'visible','off')

set(hdl.space.txt_nbvol,'visible','on');
set(hdl.space.txt_edit_nbvol,'visible','on');
set(hdl.space.time_slider,'visible','on');

 hh=findobj('label','start : cine');
 set(hh,'label','start : volume','callback','affichevol(5,''volume'')')


elseif strcmp(action,'volume');

 hh=findobj('label','start : volume');
 set(hh,'label','start : cine','callback','affichevol(5,''cinema'')')

   set(hdl.space.start,'BackgroundColor',[1 1 1],'visible','on')
   set(hdl.space.start,'CallBack','affichevol(1,''start'')');
   set(hdl.space.stop,'visible','off')
%   set(hdl.space.time_slider,'visible','off');


elseif strcmp(action,'panel');
  	Ser_disp = str2num(get(hdl.tpos_hdl.Series_disp,'string'));
	C = colormap;
	tname = get(hdl.tpos_hdl.listCon,'string');
	tname = tname{get(hdl.tpos_hdl.listCon,'value')};
	name = [Volume(NumVol).titre, tname];
	panel(3,4,Volume(NumVol).data,C,Volume(NumVol),Tpos,Ser_disp,name)


elseif strcmp(action,'init_filter');
  h = gcbo;
  type = get(h,'label');

  h = findobj(FigNum,'label','filter');
  set(h,'userdata',type)

elseif strcmp(action,'saveBig');
   Big = Bigini(Pos,8);
   
   Big(2) = ordBig(Big(1),13);
   Big(3) = moyBig(Big(2));
 %  Big(4) = moyBig(Big(3));

   cd data/temporel/Big
   [Fname, Pname] = uiputfile('*.mat', 'where');
   if Fname
	   Fname = cat(2,Pname,Fname)
   	Fname = cat(2,'save ',Fname,' Big');
   	eval(Fname);
   end
   cd ../../..
   

end;
