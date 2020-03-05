if strcmp(action,'volumes_expr')

  lihdl = get(hdl.vol_list,'string');
  [chdl ok] = listdlg('ListString',lihdl,'ListSize',[840 600]);
  if ~ok, return;end

  str=''; titre = sprintf('From Volume ');

  for kk=1:length(chdl)
     ss = sprintf('i%d  -> %s \n',kk,lihdl{chdl(kk)});
     titre = sprintf('%s No %d',titre,chdl(kk));
     str = [str ss];
     vol(kk) = Volume(chdl(kk)).Vol;
  end
  expr =inputdlg(str);
  if isempty(expr),return;end

  titre = sprintf('%s  ->compute %s',titre,expr{1});

  l = length(Volume);
  Volume(l+1) = Volume(chdl(1));
  Volume(l+1).Vol = vol;
  Volume(l+1).titre = titre;
  Volume(l+1).expr = expr{1};
  
  lihdl{end+1} = titre;
  set(hdl.vol_list,'string',lihdl);

     
elseif strcmp(action,'SPM_expr'),
  choose_con=0;
  rep_res = plotmoy('get_res_path');
  d = load (fullfile(rep_res,'SPM'));
  
  [Ic,xCon] = spm_conman(d.SPM);
  c = xCon(Ic).c;
  

%  if choose_con
%    if exist(fullfile(rep_res,'xCon.mat'),'file')
%      load(fullfile(rep_res,'xCon.mat'))
%    else
%      xCon = [];
%    end
%    [Ic,xCon] = spm_conman(d.xX,xCon,'T|F',Inf,...
%	'	Select contrasts...',' for hmmm',1);
%    c = xCon(Ic).c;
%  else
%    c = ones(size(d.Vbeta));
%  end

  expr.c = c ;
  expr.res_path = rep_res;

  for n_con=1:length(c)
    expr.Vbeta(n_con) = spm_vol(fullfile(d.SPM.swd,d.SPM.Vbeta(n_con).fname));
  end
  expr.X = d.SPM.xX.X;
  expr.X = d.SPM.xX.pKX';


  [r titre] =  rrr_cd_up(rep_res);
  [r n] =  rrr_cd_up(r);
  titre = ['Y - spm of',titre, ' _ ' ,n];

  l = length(Volume);
  Volume(l+1) = Volume(NumVol);
  Volume(l+1).Vol = Volume(NumVol).Vol;
  Volume(l+1).titre = titre;
  Volume(l+1).expr = expr;
  
  li_vol = get(hdl.vol_list,'string');
  li_vol{end+1} = titre;
  set(hdl.vol_list,'string',li_vol);


end
