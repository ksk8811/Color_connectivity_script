%*************** FONCTION Tpos ****************

if strcmp(action,'loadRes'),

  affichevol(11,'show_Tpos');

  Res_dir = result_path;

  if exist(fullfile(Res_dir,'SPM.mat'))

    [result_path, res_name,value] = rrr_cd_up(Res_dir);
    Volume(NumVol).result_path = result_path;

    dc = struct2cell(dir(result_path));dc(:,1)=[];

    load (fullfile(Res_dir,'SPM.mat'));
    xCon = SPM.xCon;
    Volume(NumVol).Con_dir = Res_dir;
    str= {['(',xCon(1).STAT,') ',xCon(1).name ]};
    for k = 2:length(xCon)
      str = {str{:},['(',xCon(k).STAT,') ',xCon(k).name ]};
    end
    set(hdl.tpos_hdl.listCon,'string',str,'value',1);

  else
    dc = struct2cell(dir(Res_dir));dc(:,1)=[];
    if (size(dc,2)==1),  value=1;
    else,  value=2 ;end 
  end
  set(hdl.tpos_hdl.result,'string',dc(1,:),'value',value)

elseif strcmp(action,'changeRes'),

  list_name = get(hdl.tpos_hdl.result,'string');
  name_select = list_name{get(hdl.tpos_hdl.result,'value')};
  rep = fullfile(result_path,name_select);

  Volume(NumVol).result_path = rep;
  result_path = rep;
  action = 'loadRes';Tposprog
   
   
elseif strcmp(action,'New_Con'),

   resss =  Volume(NumVol).Con_dir;

   if exist(fullfile(resss,'SPM.mat')) ~=2
      fprintf('%s\n ',' Sorry -- empty result dir --');
      return
   end

   if exist(fullfile(resss,'xCon.mat'),'file')
	load(fullfile(resss,'xCon.mat'))
   else
	xCon = [];
   end

   l = load(fullfile(resss,'SPM.mat'),'xX')

   [Ic,xCon] = spm_conman(l.xX,xCon,'T|F',Inf,...
	'	Select contrasts...',' for conjunction',1);

   save(fullfile(resss,'xCon.mat'),'xCon')
   curdir = pwd; cd(resss);
   spm_bch_DoCont
   cd(curdir)

elseif strcmp(action,'SPM2Tpos'),

   Ser_in = str2num(get(hdl.tpos_hdl.Series_in,'string'));
   Ser_disp = str2num(get(hdl.tpos_hdl.Series_disp,'string'));
  
   Ic = get(hdl.tpos_hdl.listCon,'value');
   Con_Dir = Volume(NumVol).Con_dir;

   Im=[];   pm=[];   Ex=[];
   corrected= get(hdl.tpos_hdl.corected,'value');
   p_thres =  str2num(get(hdl.tpos_hdl.u_Seuil,'string'));
   k_thres =  str2num(get(hdl.tpos_hdl.k_Seuil,'string'));
   
   job.spmmat = cellstr(fullfile(Con_Dir,'SPM.mat'));
   job.print  = 0;
   job.conspec.titlestr = ''; % determined automatically if empty
   job.conspec.contrasts = Ic;
   if corrected
     job.conspec.threshdesc = 'FWE'; % 'FWE' | 'FDR' | 'none'
   else
     job.conspec.threshdesc = 'none'; 
   end
   
   job.conspec.thresh =p_thres ;
   job.conspec.extent = k_thres;
   job.conspec.mask = struct([]);
   
   [SPM,xSPM] = spm_getSPMfromVBM5(job);

%old way   [SPM VOL Tall oSPM]= rrr_getSPM(...
%          Ic,p_thres,k_thres,corrected,Im,pm,Ex,Volume(NumVol).Con_dir);

   hdr.p_thre = p_thres;
   hdr.correc =  corrected;
   hdr.k_thre = k_thres;
   hdr.name =  get(hdl.tpos_hdl.listCon,'string');hdr.name = hdr.name{Ic};
   hdr.Con_dir = Volume(NumVol).Con_dir;
 
   %get the value
   val = xSPM.Z;  [vall ind] = sort(-val);
   min(val)
   max(val)
   s = struct('XYZ',xSPM.XYZ(:,ind),'mat',SPM.xVol.M,'vals',val(ind));
   s.binarize=0; 
   roi_o = maroi_pointlist(s,'vox');
   roi_o = label(roi_o,hdr.name);

   Tpos{Ser_in} = roi_o; 

   if ~hdla.Tpos
     hold on
     %vvv = Volume(NumVol).Vol;
     vvv = Vr.box_space;

     hdla.Tpos = afficheTPos(Tpos,coupe,vvv,Vr.M_rot,0,Ser_disp);
     set(AxeNum,'UserData',hdla);
   end

   %sp = mars_space ( struct('dim',VOL.DIM,'mat', VOL.M) );
   %mmm = voxpts(roi_o,sp)

   %SPM = rmfield(SPM,'XYZ');SPM = rmfield(SPM,'XYZmm');hdr.SPM=SPM;
   Tpos_hdr{Ser_in} =hdr;

   Volume(NumVol).Tpos  = Tpos;
   Volume(NumVol).Tpos_hdr = Tpos_hdr;

   %need to have the all spmT volume     
   %TposPlot
 
elseif strcmp(action,'Cluster_ini'),

   Ser  = str2num(get(hdl.tpos_hdl.Series_disp,'string'));
   pp = [];vals=[];

   sp=mars_space(Volume(NumVol).Vol);
   srct='';
   for k = Ser ;
       [ppoint val] = voxpts(Tpos{k},sp);
 	pp = cat(2,pp,ppoint);
	vals = cat(2,vals,val);
	srct = [srct label(Tpos{k})];
   end
   
   Cluster = spm_clusters(pp);

   for i = 1:max(Cluster)
   	ind_c = find(Cluster == i);
    	Clus_Pos{i} = pp([1 2 3],ind_c)';
	val = vals(ind_c);
	Clus_size(i)  = length(ind_c);

   	
	s = struct('XYZ',Clus_Pos{i}','mat',sp.mat,'vals',val,'binarize',0,...
		   'label',['roi_' num2str(Clus_size(i))] ,'source',srct); 

	roi_o{i} = maroi_pointlist(s,'vox');
   end

   		%sort in decreasing cluster size
   [tt ind] = sort(-Clus_size);
   Clus_Pos = Clus_Pos(ind);
   roi_o = roi_o(ind);

     nbroi = size(Clus_Pos,2);
     str = sprintf('%s\n/ %s','Roi ', num2str(nbroi) );
     set (hdl.Roi.txt,'string',str);

   Volume(NumVol).Pos = Clus_Pos ;
%   Volume(NumVol).roi_Pos = roi_o;

   if length(Clus_Pos)<28, size =num2str(length(Clus_Pos));
     else size = '28';
   end
   set(hdl.Roi.disp ,'string', ['1:' , size])

   realy_refresh = 1;

elseif strcmp(action,'find_clus'),
rrr
	Ser  = str2num(get(hdl.tpos_hdl.Roi.disp,'string'));
	if ~isempty(Ser) & length(Ser)==1
		coupe = Clus_Pos{Ser}(1,3);
		Volume(NumVol).coupe = coupe;
	end
		

   
elseif strcmp(action,'Tpos2Pos'),
   sp = mars_space(Volume(NumVol).Vol);
   
   if isempty(Volume(NumVol).Pos{1})
     Volume(NumVol).Pos{1} =  voxpts(Tpos{1},sp)';
   else
      Volume(NumVol).Pos{end+1} =  voxpts(Tpos{1},sp)';
    end

      
elseif strcmp(action,'SaveTpos'),
   create_rep({repDataLog},{repDataLog,'volume/','TPos/'})

   workdir=pwd;
   cd ([repDataLog,'volume',filesep,'TPos'])
   [Fname, Pname] = uiputfile('*.mat', 'where');
   if Fname
	   Fname = cat(2,Pname,Fname)
   	Fname = cat(2,'save ',Fname,' Tpos Tpos_hdr ');
   	eval(Fname);
   end
   cd (workdir)


elseif strcmp(action,'ClearTpos'),

  try
    delete(hdla.Tpos)
  catch
    fprintf('hmmmm\n')
  end

   hdla.Tpos = 0;
   set(AxeNum,'UserData',hdla);

   Tpos = []
   Volume(NumVol).Tpos  = Tpos;
   
   
elseif strcmp(action,'inter_T'),


Clus_Pos={};

nbT = size(Tpos,2);
res = Tpos(1,1);
name{1} = ['T1'];
T = [];

for i = 2:nbT
	T1 = Tpos{1,i};
	for j = 1:length(res)
	   if ~isempty(res{j})
		T2 = res{j};
		nbval = size(T2,2);
		c = 1;
		for k = 1:size(T1,1)
			aa = T2(:,3)==T1(k,3) & T2(:,2)==T1(k,2) &  T2(:,1)==T1(k,1) ;
			ind(k) = any(aa);			
			if( ind(k) )
				T(c,1:nbval) = T2(find(aa),:);
				T(c,nbval+1) = T1(k,4);
				T2(find(aa),:) = [];
				c=c+1;
			end
		end	
		res{j} = T2;
		T1 = T1(~ind,:);	clear ind
	  end
		if ~isempty(T)
		res(length(res)+1) = {T};  T=[]; 
		name(length(name)+1) = {[name{j},'T',num2str(i)]};
		end

	end
	if ~isempty(T1)
	res(length(res)+1) = {T1};
	name(length(name)+1) = {['T',num2str(i)]};
	end
end

   set(hdl.tpos_hdl.nb_clust,'string',num2str(size(Clus_Pos,2)))

   Clus_Pos = res ;

   for k = 1:length(Clus_Pos)
     nb(k,:) = size(Clus_Pos{k});
   end

   [tt ind] = sort(-nb(:,1));
   Clus_Pos = Clus_Pos(ind);
   name =  name(ind);
   nb = nb(ind,:);

   [tt ind] = sort(-nb(:,2));
   Clus_Pos = Clus_Pos(ind);
   name =  name(ind);
   nb = nb(ind,:);

   Volume(NumVol).Pos =Clus_Pos ;
   Volume(NumVol).Clus_name = name

end;

   
	
return

p_thres = logspace(-1,-5,20);
k_thres=4;

 for k=1:20
   [SPM VOL Tall ]= rrr_getSPM(Ic,p_thres(k),k_thres,corrected,Im,pm,Ex,Volume(NumVol).Con_dir);
   Cluster = spm_clusters(SPM.XYZ);
   c_pos='';c_size='';c_Z='';z_max=[];

   for i = unique(Cluster)
     ind_c = find(Cluster == i);
     ppp = SPM.XYZ(:,ind_c); pppz = SPM.Z(ind_c);
     [tt ind] = sort(-pppz);
     c_pos{i} = ppp(:,ind);
     c_size{i} = length(ind);
     c_Z{i} = pppz(ind);
     z_max(i) = pppz(ind(1));
   end
   [tt ind] = sort(-z_max);
   Clus(k).pos = c_pos(ind);
   Clus(k).size = c_size(ind);
   Clus(k).Z = c_Z(ind);
 end



%elseif strcmp(action,'LoadTpos')

   Ser = str2num(get(hdl.tpos_hdl.Series_disp,'string'));

   if ~exist([repDataLog,'volume',filesep,'TPos']), return; end;
   workdir=pwd;
   cd ([repDataLog,'volume',filesep,'TPos'])
   [Fname, Pname] = uigetfile('*.mat', 'where');
   cd (workdir)
   
   if Fname
      load(fullfile(Pname,Fname));



      Volume(NumVol).Tpos  = Tpos;
      Volume(NumVol).Tpos_hdr = Tpos_hdr;

	for i = 1:length(Tpos_hdr)
		str{i} = Tpos_hdr{i}.name;
	end

      set(hdl.tpos_hdl.listCon,'string', str);

      if ~hdla.Tpos
         hold on   
     	 	hdla.Tpos = afficheTPos(Tpos,coupe,Volume(NumVol).Vol,...
				       Vr.M_rot,0,Ser_disp);
     
      	set(AxeNum,'UserData',hdla);
      end      
   end
   
