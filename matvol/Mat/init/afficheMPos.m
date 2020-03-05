
Mark = ['.r';'.g';'.b';'.m';...
           'xr';'xg';'xb';'xm';...
	   'vr';'vg';'vb';'vm';...
	   '^r';'^g';'^b';'^m';...
	   '<r';'<g';'<b';'<m';...
	   '>r';'>g';'>b';'>m';...
	   'hr';'hg';'hb';'hm'];
 
Pdec = [3 2 1 0 -1 -2 -3 3 2 1 0 -1 -2 -3 3 2 1 0 -1 -2 -3 3 2 1 0 -1 -2 -3 ...
	  3 2 1 0 -1 -2 -3 3 2 1 0 -1 -2 -3 3 2 1 0 -1 -2 -3 ;... 
        3 3 3 3 3 3 3 2 2 2 2 2 2 2 1 1 1 1 1 1 1 0 0 0 0 0 0 0 -1 -1 -1 ...
        -1 -1 -1 -1 -2 -2 -2 -2 -2 -2 -2 -3 -3 -3 -3 -3 -3 -3].*1/12;

maxPos = 28;

 try
   set(hdla.MPoshdl(1),'Xdata',0,'Ydata',0,'visible','on' );
 catch
   %loose the roi_plot_handel .
   fprintf('new ROI plot')
   for k =1:maxPos
     MPoshdl(k) = plot(-1,-1,Mark(k,:),'erasemode','none','markersize',4);
   end
   hdla.MPoshdl = MPoshdl;

   Axeshdl{hdla_num} = hdla; AxeshdlChanged


end

if exist('sur_plot_pos')
  try 
    set(hdla.track_pos,'visible','off')
    set(hdla.track_pos,'Xdata',sur_plot_pos(1),'Ydata',sur_plot_pos(2),...
	'visible','on')
  catch
    fprintf('yooop')
    hdla.track_pos = plot(sur_plot_pos(1),sur_plot_pos(2),'og');
    Axeshdl{hdla_num} = hdla; AxeshdlChanged

  end
end



	for kk=1:maxPos
   	set(hdla.MPoshdl(kk),'Xdata',0,'Ydata',0,'visible','on' );
	end


M_rot = Vr.M_rot;
M_rot = M_rot(1:3,1:3);

for kk = Ser
  if kk>length(Pos)
  else
   pp = Pos{kk}*(M_rot);
   ind_pp = (round(pp(:,3)) == coupe);

   set(hdla.MPoshdl(kk),'Xdata',pp(ind_pp,1)-Pdec(1,kk),'Ydata',pp(ind_pp,2)-Pdec(2,kk),'visible','on' );
 end
end





