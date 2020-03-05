function affichevol(action,varargin)
% main function with all callback form the interface
% the code is split in different file
% Coupeprog (always call to update the rigth display
% Graphprog  (basic graph fonction 
% setbox view  orientation info of the volume
% Posprog (handel of ROI)
% initfigvol is the gui setup
% draw remplie are subfonction for drawing roi
%
% Decoursprog and Segprog (in construction) and other home made
% fonction are curently discarded (minimun=1 in initfigvol)
% 
% romain.valabregue@snv.jussieu.fr 
% romain valabregue le 01/10/2001 and the 12/02/2003

         
persistent  Volume 
global Exams

fff = findobj('tag','affichevol');
if ~isempty(fff)
  if length(fff)==1  figure(fff);end

  FigNum = gcf;
  AxeNum = gca;

  hdl = get(FigNum,'UserData');
  Axeshdl = hdl.Axeshdl;
  hdla_num = find(hdl.axe==AxeNum);
  hdla = Axeshdl{hdla_num};

try
  NumVol = hdla.NumVol;
  Vr = hdla.Vr; 

catch
  fprintf('ARGGG init_ a new volume\n')
end
end  

nnnargin = nargin;

if nargin==1 & ischar(action)

  if strcmp(action,'all')
    action='all_anat'; if isempty(Exams),load_exam;end; tempo_also=1;
  end

    switch action
      case 'tmp'
	action ='load_exam';
	fonc_exams
      case 'all_anat'
	P={};
	global Exams

	Num_vol = length(Volume)+1;
	Last_num_vol = Num_vol;
	for nexa=1:length(Exams)
	  for deux_fois = 1:2
	    if deux_fois==1
	      Series = Exams(nexa).Series_anat;
	    else
	      Series = Exams(nexa).Series;
	    end
            for nser = 1 : length(Series)
              %P{end+1} = [Series(nser).name Series(nser).vol_list(1,:)];
	      if ~exist(Series(nser).vol_list(1,:))
		P{end+1} = spm_select('CPath',fullfile(Series(nser).name,Series(nser).vol_list(1,:)));%[Series(nser).name Series(nser).vol_list(1,:)];
	      else
		P{end+1} = Series(nser).vol_list(1,:);
	      end
	      
	      Volume(Num_vol).nr_time_vol=1;
	      Volume(Num_vol).expr = '';
              Volume(Num_vol).result_path= Exams(nexa).res_path;
              Volume(Num_vol).data_path= Exams(nexa).name;
%	      Volume(Num_vol).Exam =Exams(nexa); 

	      Num_vol = Num_vol +1;
            end
	  end
	end
	all_anat=1;

      case 'Data'
	data_path = Volume(NumVol).data_path
      case 'Result'
	data_path = Volume(NumVol).result_path
      otherwise
         data_path = action;
   end
        action='';     nnnargin=0;

end

if nargin==1 & iscell(action)
  P=char(action);
  action='';     nnnargin=0;
  all_anat=1;
end

if nnnargin == 0 
 
     if exist('hdl'),titre = get(hdl.vol_list,'string');end
     global Data_path

     if ~exist('data_path')
       if isempty(Data_path),  data_path = pwd; %'/images';
       else,   data_path = Data_path;  end
     end

     if exist('Last_num_vol'),       Num_vol = Last_num_vol;
     else,       Num_vol = length(Volume)+1;Last_num_vol = Num_vol;end

     if Num_vol>1 & ~exist('titre')
	 for nbvv = 1:Num_vol-1;
	    titre{nbvv}=Volume(nbvv).titre;
	 end
     end

     if ~exist('P'),
       P = spm_select([1 Inf],'image','select images','',data_path);
     end

   if ~isempty(P)  
     if ischar(P)
       for kp=1:size(P,1) pp{kp} = P(kp,:); end
       P = pp;
     end
     Vol = spm_vol(deblank(P));
   end
   if ~exist('Last_num_vol');Last_num_vol=1;end
%   keyboard
     for kkk = 	1:length(P)
       Num_vol=kkk+ Last_num_vol-1;
       
       Volume(Num_vol).Vol = Vol{kkk};
%bad spm_hread with nifti       Volume(Num_vol).M_base = bare_head(Volume(Num_vol).Vol.fname);
       Volume(Num_vol).data=[];
       
       titre{Num_vol} = Volume(Num_vol).Vol.descrip;  
       titre{Num_vol} = addgrandfather(titre{Num_vol},P{kkk});
       
       Volume(Num_vol).titre = titre{Num_vol};
    
       if ( isempty(gcbf) | ~strcmp(get(gcbf,'tag'),'affichevol') )& (~exist('deja_fait') )
	 M_slice = spm_matrix([0 0 1]);
	 slice = (spm_slice_vol(Volume(Num_vol).Vol,...
				M_slice,Volume(Num_vol).Vol.dim(1:2),0))';
	 FigNum = initfigvol(slice,Num_vol, Volume(Num_vol).Vol.dim(3)); 
%        FigNum=openfig('fig','reuse');
%keyboard
	 hdl = get(FigNum,'UserData');
	 hdl.print_path = getenv('HOME');
	 set(gcf,'name',titre{Num_vol},'userdata',hdl)
	 deja_fait=1;
       end

       Volume(Num_vol).Pos ={[]};
       Volume(Num_vol).Tpos  = [];
       Volume(Num_vol).Bw  = []; 
       Volume(Num_vol).Cont = [];
       Volume(Num_vol).stackofmaps = colormap;
       Volume(Num_vol).lengthofmap = size(Volume(Num_vol).stackofmaps,1);

       todo=1;
       if isfield(Volume(Num_vol),'result_path')
	 if ~isempty( Volume(Num_vol).result_path),todo=0;end
       end
       if todo

         Exam = guess_Exam(P{kkk});  
         Volume(Num_vol).result_path=  Exam(1).res_path;
         Volume(Num_vol).data_path= Exam(1).name;
%         Volume(Num_vol).result_path = Volume(1).result_path;
%         Volume(Num_vol).data_path= Volume(1).data_path
%	 Volume(Num_vol).Exam =Exam; 

	 Volume(Num_vol).nr_time_vol=1;
	 Volume(Num_vol).expr = '';
%keyboard
       end


%       Num_vol=Num_vol+1;

  end
%  Num_vol=Num_vol-1;


if ~exist('hdl')

    M_slice = spm_matrix([0 0 1]);
    slice = (spm_slice_vol(Volume(Num_vol).Vol,...
				M_slice,Volume(Num_vol).Vol.dim(1:2),0))';
    FigNum = initfigvol(slice,Num_vol, Volume(Num_vol).Vol.dim(3));
    hdl = get(FigNum,'UserData');
    Axeshdl = hdl.Axeshdl;
    hdl.print_path = fullfile(getenv('HOME'),'print_fig');
    set(gcf,'name',titre{Num_vol},'userdata',hdl)
    set(hdl.vol_list,'string',titre)
else
 set(hdl.vol_list,'string',titre)
end


end
          
if nnnargin == 3
  
     if exist('hdl'),titre = get(hdl.vol_list,'string');end

  if isempty(Num_vol), Num_vol = 1; else,  Num_vol = Num_vol+1;  end

    Volume(Num_vol).data  = varargin{1};
    titre{Num_vol} = strcat(varargin{2});
    Volume(Num_vol).titre = titre{Num_vol};

    set(hdl.vol_list,'string',titre)
   
   %  initfigvol(varargin{1},action); 

  Volume(Num_vol).Pos ={[]};
  Volume(Num_vol).Tpos  = [];
  Volume(Num_vol).Bw  = []; 
  Volume(Num_vol).Cont = [];
  Volume(Num_vol).stackofmaps = colormap;
  Volume(Num_vol).lengthofmap = size(Volume(Num_vol).stackofmaps,1);

     global Data_path Result_path ;
     if isempty(Result_path),  Volume(Num_vol).result_path=pwd;  else
       Volume(Num_vol).result_path=Result_path;     end
     if isempty(Data_path),  Volume(Num_vol).data_path = '/images'; else
       Volume(Num_vol).data_path = Data_path;     end


end


%change the volume to view from the list
if nnnargin == 1
  hdla.NumVol = action;NumVol=action;
  action=0;
  set_axis = 'true';

  set(hdl.space.orient,'value',Vr.numrot);
  set(hdl.space.space,'value',Vr.num);

  box_view = 'box';
  set_box_view


end

  
if nnnargin == 3 | nnnargin == 0,
Pos ={[]};coupe =1; Tpos=[]; Cont=[];
  AxeNum = gca; hdla_num = find(hdl.axe==AxeNum);
  Axeshdl = hdl.Axeshdl;  hdla = Axeshdl{hdla_num};
  NumVol = hdla.NumVol; Vr = hdla.Vr; 
Coupeprog

if exist('all_anat')
    affichevol(11,'hide_Tpos')
    affichevol(1,'multiV4')
      for nb = 1:length(Volume)
        if nb<=4 ,axes(hdl.axe(nb));end;
        affichevol(nb);
      end
if exist('tempo_also')
      affichevol(5,'init');
end
else
    for nb = 1:length(Volume)
      affichevol(nb);
    end

end
 
elseif  nnnargin == 2 | nnnargin == 1 |  nnnargin >= 4,
   
   if NumVol 
%     Exam = Volume(NumVol).Exam ;

     Pos     = Volume(NumVol).Pos;
     Tpos    = Volume(NumVol).Tpos;
     Bw      = Volume(NumVol).Bw;
     Cont    = Volume(NumVol).Cont;

     result_path = Volume(NumVol).result_path;
     data_path = Volume(NumVol).data_path;
     
     coupe   = Vr.coupe;
   end

   TypeAction = action;
   if nnnargin>1,   action = varargin{1}; end
   
   switch TypeAction
     case 1
       byby=0;
       Graphprog   

       if  byby
         return
       end
       
     case 11
       set_gui

     case 2      
       Segprog
       Volume(NumVol).Bw  = Bw;
       
     case 3
       workin_pos = str2num(get(hdl.Roi.disp ,'string'));
       if isempty(workin_pos)
	 workin_pos = 1;   set(hdl.Roi.disp ,'string', ['1'])
       end
       workin_pos = max(workin_pos);

       try
	 pPos = Pos{workin_pos};
       catch
	 pPos=[];
       end

       Posprog

       if ~isempty(pPos), Pos{workin_pos} = pPos; end
       Volume(NumVol).Pos = Pos;

       
     case 4             	
       if isfield(Volume(NumVol),'Tpos_hdr'), Tpos_hdr=Volume(NumVol).Tpos_hdr;end
       Tposprog             
     case 5
       Decoursprog
     case 6
       Image_Calc
   end

if NumVol
  Coupeprog   
end


if get(hdl.space.syn_coupe,'value')

  try
     str =  get(gcbo,'string');
  catch
     str='';
  end

  if strcmp(str,'+') | strcmp(str,'-')
      cur_axe = gca;

      coupemm = Vr.mat*[1 1 coupe 1]';

   for na = 1:length(hdl.axe)
    if (hdl.axe(na)~=cur_axe)
      axes(hdl.axe(na))

      hdla = Axeshdl{na};
      NumVol = hdla.NumVol;   Vr = hdla.Vr; 

      if NumVol
        coupe = inv(Vr.mat)*coupemm;
        coupe=round(coupe(3));

	Vr.coupe = coupe; 
	hdla.Vr = Vr;    Axeshdl{na} = hdla;

	Pos     = Volume(NumVol).Pos;
        Tpos    = Volume(NumVol).Tpos;
	Coupeprog
      end
    end
   end
  
  axes(cur_axe)
  AxeshdlChanged

  end
end

end        


function titre=addgrandfather(titre,p)
%get the grand father directorie from the image

GF_name='';

for i=1:3
  a=spm_str_manip(p,'t');
  p = spm_str_manip(p,['f',num2str(length(p)-length(a)-1)]);
  GF_name = ['   ' a GF_name];
end
a=spm_str_manip(p,'t');
GF_name = ['   ' a  GF_name];

titre = [GF_name titre ];

function Ex = guess_Exam(P)

  Ex.res_path = pwd;
  Ex.name     = pwd;


