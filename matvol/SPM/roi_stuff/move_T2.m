
rootdir = '/images2/christine/HD_Track_2008/PROTO_HD_TRACK';
sujet_re = {'2008'};
fonc_re  = {'T2_star'};

subjects=get_subdir_regex(rootdir,sujet_re);
wd=pwd;


for nsuj =1:length(subjects)
  funcdirs=get_subdir_regex(subjects(nsuj),fonc_re);
  
  newp = fullfile(subjects{nsuj},'T2StarMap');
  if ~exist(newp)
    if length(funcdirs)
      mkdir(newp)

      cd(newp)
  
      sel_img ='^f.*.img';
      sel_hdr ='^f.*.hdr';
      %  sel_mat ='^f.*.mat';
      for nser = 1:length(funcdirs)
	f = spm_select('List',funcdirs{nser},sel_hdr);
	copyfile(fullfile(funcdirs{nser},f),newp);
	f = spm_select('List',funcdirs{nser},sel_img);
	copyfile(fullfile(funcdirs{nser},f),newp);
	%    f = spm_select('List',funcdirs{nser},sel_mat)
	%    copyfile(fullfile(funcdirs{nser},f),newp)
	
	indd=findstr(funcdirs{nser},'TE_');
	indms=findstr(funcdirs{nser},'ms');
	TE(nser) = str2num(funcdirs{nser}(indd+3:indms-1));
	P(nser,:) = fullfile(newp,f);
      end
      
      TE
      [p,f] = fileparts(   subjects{nsuj});
      [p,f] = fileparts(p)

      compute_T2_auto(P,[f,'_T2Map.img'],TE);
    end
  end
  clear P TE
end



if 0 to find T2Map
for nsuj =1:length(subjects)
  funcdirs=get_subdir_regex(subjects(nsuj),fonc_re);
%  ff{nsuj} = fullfile(funcdirs{1},'wT2Map_seuil100.img');
  ff{nsuj} = fullfile(funcdirs{1},'wT2Map.img');
end
end

if 0 to find T2Map
for nsuj =1:length(subjects)
  funcdirs=get_subdir_regex(subjects(nsuj),fonc_re);
%  ff{nsuj} = fullfile(funcdirs{1},'wT2Map_seuil100.img');
  ff = fullfile(funcdirs{1},'wT2Map.img');
  [p,f]=fileparts(ff);
  ffhdr=fullfile(p,[f,'.hdr']);
  ffmat=fullfile(p,[f,'.mat']);
  [p,f]=fileparts(p);
  [p,f]=fileparts(p) ;
  
  copyfile(ff,[f,'_T2.img']);
  copyfile(ffhdr,[f,'_T2.hdr']);
  copyfile(ffmat,[f,'_T2.mat']);

end
end

if 0 %to compute T2
fonc_re  = {'T2map'};
select_img = '^wf.*.img'; 

for nsuj =1:length(subjects)
  funcdirs=get_subdir_regex(subjects(nsuj),fonc_re);
  cd(funcdirs{1})
  f = spm_select('List',funcdirs{1},select_img);

  cd(funcdirs{1})
  compute_T2(f,'wT2Map_seuil100.img',[14 28 42 56 70 90 115]);

end
end

if 0

  old_dir = '/images/christine/PROTO_HD_TRACK/matrice';
  
for nsuj =1:length(subjects)
  funcdirs=get_subdir_regex(subjects(nsuj),fonc_re);
  
  for nser = 1:length(funcdirs)
    f = spm_select('List',funcdirs{nser},select_img);

    [pp ff]=fileparts(f);
    
    fseg = [ff,'_seg_sn.mat']
     
    if ~exist(fullfile(funcdirs{nser},fseg))
keyboard
      dd=[old_dir,'/*',ff,'*'];
      ddd=dir(dd)
      if isempty(dd)
	keyboard
      end
    
      if length(ddd)>10
	keyboard
      end
    
      for nf=1:length(ddd)
	if ddd(nf).isdir
	  keyboard
	end
      
	copyfile(fullfile(old_dir,ddd(nf).name),funcdirs{1})
      end
    end  
  end
end

end

if  0

for nsuj =1:length(subjects)
  funcdirs=get_subdir_regex(subjects(nsuj),fonc_re);
  
  newp = fullfile(subjects{nsuj},'T2map');
  mkdir(newp)
  sel_img ='.*00001-01.img';
  sel_hdr ='.*00001-01.hdr';
  for nser = 1:length(funcdirs)
    f = spm_select('List',funcdirs{nser},sel_img)
    copyfile(fullfile(funcdirs{nser},f),newp)
    f = spm_select('List',funcdirs{nser},sel_hdr)
    copyfile(fullfile(funcdirs{nser},f),newp)
    
  end
end

end