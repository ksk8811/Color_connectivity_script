
if ~isempty(Volume(NumVol).Vol)


  Vi = Volume(NumVol).Vol;

  expr = Volume(NumVol).expr;

  if ~( isfield(Vr,'mat') )
     box_view = 'box';
    set_box_view;
    set_axis='true';
  end


%--------------------------------------------------------------
  if ~isempty(expr)  %for calcule
    if ischar(expr)  
      for kk=1:length(Vi)
        slice = my_get_slice(Vi(kk),Vr,coupe);
	eval(['i',num2str(kk),'=slice;']);
      end

      if isfield(Volume(NumVol),'Volmoy')
	vmoy = Volume(NumVol).Volmoy;
	if ~isempty(vmoy)
          dim = Vr.dim * Vr.M_rot(1:3,1:3);
	  i1=zeros(dim(1:2));
	  for kk=1:length(vmoy)
             i1 =i1 + my_get_slice(vmoy(kk),Vr,coupe);
	  end
	  i1 = i1./length(vmoy);
	end	  
      end

      eval(['slice = ' expr ';'])

%--------------------------------------------------------------
  elseif isstruct(expr)
      t_nr = Volume(NumVol).nr_time_vol;
      x = expr.X(t_nr,:);
      c = expr.c;
      estim=0;

      for n_con=1:length(c)
	v_b = expr.Vbeta(n_con); 
	bet = my_get_slice(v_b,Vr,coupe);
	estim = estim + c(n_con)*bet*x(n_con);
      end

      if isfield(Volume(NumVol),'Volmoy')
	vmoy = Volume(NumVol).Volmoy;
	if ~isempty(vmoy)
          dim = Vr.dim * Vr.M_rot(1:3,1:3);
	  i1=zeros(dim(1:2));
	  for kk=1:length(vmoy)
             i1 =i1 + my_get_slice(vmoy(kk),Vr,coupe);
	  end
	  slice = i1./length(vmoy);
	end	  
      else
	slice = my_get_slice(Vi,Vr,coupe);
      end

     slice = slice - estim;
      %slice = slice ./estim;

    end

%--------------------------------------------------------------
  else
    slice = my_get_slice(Vi,Vr,coupe);
  end

else   %isempty(Volume(NumVol).Vol)
  dim = size(Volume(NumVol).data);
  slice =  Volume(NumVol).data(:,:,coupe);

end


if (exist('Bw')),if (isstruct(Bw))
  ind = find( (slice(:) < Bw.minval)|...
	      (slice(:) > Bw.maxval) );
  slice(ind) = NaN;

end;end


