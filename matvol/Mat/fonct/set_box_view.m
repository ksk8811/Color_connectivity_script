%function Vr = set_box_view(Volume,box_view)

Vi = Volume(NumVol).Vol(1);

s = size(Vi.dim);
if s(1)>s(2)
Vi.dim = Vi.dim'
fprintf('WRRRANING');
end

dim =Vi.dim(1:3);  

switch lower(box_view)

  case 'box'

    mat = Vi.mat;
    vox = sqrt(sum(Vi.mat(1:3,1:3).^2));
    Vr.num = 1;

  case 'space'

    vox=[];h=1;

    % space for new image          
      [dim mat vox] = mars_new_space(dim,Vi.mat, vox);
    % get data for image

    Vr.num = 2;

  case 'new'

    vox = sqrt(sum(Vi.mat(1:3,1:3).^2));

    [Choise ok] = listdlg('ListSize',[160 100],'PromptString',...
              'choose','SelectionMode','single','ListString',...
              {'user definied vox size',...
               'user definied dim size',... 
               'from other volume',...
               'param from spat norm'} );

  switch Choise
  case 1 %'user definied vox size'

      a = inputdlg({'Voxel size (3 vector)'},['dim :',num2str(dim)],1,{num2str(vox)});

       if ~isempty(a),
         vox = str2num(a{1});
         [dim mat vox] = mars_new_space(dim,Vi.mat, vox);
       end

       Vr.num = 3;

  case 2 %'user definied dim size'
      a = inputdlg({'Matirix Dimemtion  (3 vector)'},'bloups',1,{num2str(dim)});
       if ~isempty(a),
         dim_new = str2num(a{1});
         vox = vox ./ (dim_new./dim);
         [dim mat vox] = mars_new_space(dim,Vi.mat, vox);
       end

       Vr.num = 3;
     

  case 3 %'from other volume'

     lihdl = get(hdl.vol_list,'string');
     [chdl ok] = listdlg('ListString',lihdl);

     Vnew = Volume(chdl).Vol;
     mat = Vnew.mat;
     dim = Vnew.dim(1:3); vox= sqrt(sum(Vnew.mat(1:3,1:3).^2));

     Vr.num = 3;

  case 4 %'param from spat norm'

     matname = spm_get(1,'_sn3d.mat','un point mat',Volume(NumVol).data_path);

     l = load(matname);
     mm = spm_matrix(l.p1);
     mat = mm*mat; 

     vox = sqrt(sum(mat(1:3,1:3).^2));
     Vr.num = 3;

  end   %  switch Choise
end     %  switch lower(box_view)


    Vr.dim = dim;
    Vr.vox = vox;
    Vr.mat = mat;

    Vr.box_space = mars_space ( struct('dim',dim,'mat',mat) );

    Vr.hold = 1;    

save=0;
if (save)

    Vi.dim = dim;
    Vi.vox = vox;
    Vi.mat = mat;
    Volume(NumVol).Vol=Vi;
    Vr.num = 1;
end


  hdla.Vr = Vr;
  Axeshdl{hdla_num} = hdla; AxeshdlChanged
