
%dir = spm_select([inf],'dir','Sele')
%dir=cellstr(dir);

%dir = get_subdir_regex('/servernas/images3/romain/images/nucleipark','pilote0[12345678]',{'T2W','T2_FLAIR','T2_SPC'})

dir = get_subdir_regex('/home/romain/images3/images/nucleipark/T2anat','.*','.*')


pp.wanted_number_of_file = 1;
pp.verbose=0;

for k=1:length(dir)
  [p f] = fileparts(dir{k});
  [p f] = fileparts(p);   
  
  T2suj  =get_subdir_regex(p,'T2');
  
  roi1 = get_subdir_regex_files(T2suj,'ROI_roi');
  if length(roi1)~=1,    error('azer');  end
  
  roi2 = get_subdir_regex_files(T2suj,'RedNu_roi');
  if length(roi2)~=1,    error('azer');  end
  
  roi3 = get_subdir_regex_files(T2suj,{'SN_roi'});
  if length(roi3)~=1,    error('azer');  end
  
  roi4 = get_subdir_regex_files(T2suj,'STN_roi');
  if length(roi4)~=1,    error('azer');  end

  roi_ROI{k} = roi1{1};
  roi_RED{k} = roi2{1}; 
  roi_SN{k}  = roi3{1};
  roi_STN{k} = roi4{1};
  
  [p f] = fileparts(roi1{1});
  
  T2ref(k) = get_subdir_regex_files(p,'^s.*img*',pp)
end

%do the coregister
if 0
  jobs='';

  for k=1:length(dir)

    T2vol =  get_subdir_regex_files(dir(k),'^s.*img*',pp);
    
    if ~strcmp(char(T2vol),T2ref{k})
      jobs=do_coregister(T2vol{1},T2ref{k},'','',jobs);
    end
  
  end
  spm_jobman('run',jobs)
  
  
  for k=1:length(dir)
    if is_hdr_realign(t2f{k})==0
      fprintf('%s is not realign\n',t2f{k})
    end
  end

end


t2f=get_subdir_regex_files(dir,'^s.*img$')

for k=1:length(dir)
  roi(1) = maroi('load', roi_ROI{k});
  roi(2) = maroi('load', roi_RED{k});
  roi(3) = maroi('load', roi_SN{k});
  roi(4) = maroi('load', roi_STN{k});
  
  for kk=1:4
    Y  = get_marsy(roi(kk), spm_vol(t2f{k}), 'mean');
    sy =struct(Y);
    y  = sy.y_struct.regions{1}.Y;
    
    Sm(k,kk) = mean(y);
    Sv(k,kk) = var(y)./mean(y);
    Snbpt(k,kk) = length(y);
    
  end
  
end

figure; hold on 
plot(Sm)
plot(Sm,'x');

figure; hold on 
plot(Sv)
plot(Sv,'x');
plot(mean(Sv(:,[2 4]),2),'k')

legend({'ROI','RED','SN','STN'})
 grid on

 figure; hold on 
plot(Sv(ind,:))
plot(Sv(ind,:),'x');


figure; hold on 
plot(Snbpt)
plot(Snbpt,'x');
plot(mean(Snbpt,2),'k')

legend({'ROI','RED','SN','STN'})
 grid on

 
 aa=mean(Sv(:,[2 4]),2);
[v ind] = sort(aa);

char(dir(ind))

figure; hold on
plot(v,'k');plot(v,'kx')
grid on

figure;hold on
plot(1./Sv(:,2)-1./Sv(:,1),'r')
plot(1./Sv(:,3)-1./Sv(:,1),'g')
plot(1./Sv(:,4)-1./Sv(:,1),'k')

figure;hold on
plot(abs(1./Sv(ind,2)-1./Sv(ind,1)),'r');
plot(abs(1./Sv(ind,3)-1./Sv(ind,1)),'g');
plot(abs(1./Sv(ind,4)-1./Sv(ind,1)),'k');
plot(abs(1./Sv(ind,2)-1./Sv(ind,1)),'rx');
plot(abs(1./Sv(ind,3)-1./Sv(ind,1)),'gx');
plot(abs(1./Sv(ind,4)-1./Sv(ind,1)),'kx');


figure;hold on
plot(abs(Sm(ind,2)-Sm(ind,1))./(Sm(ind,2)+Sm(ind,1)),'r')
plot(abs(Sm(ind,3)-Sm(ind,1))./(Sm(ind,3)+Sm(ind,1)),'g')
plot(abs(Sm(ind,4)-Sm(ind,1))./(Sm(ind,4)+Sm(ind,1)),'k')

plot(abs(Sm(ind,2)-Sm(ind,1))./(Sm(ind,2)+Sm(ind,1)),'rx')
plot(abs(Sm(ind,3)-Sm(ind,1))./(Sm(ind,3)+Sm(ind,1)),'gx')
plot(abs(Sm(ind,4)-Sm(ind,1))./(Sm(ind,4)+Sm(ind,1)),'kx')

aa = 1/3.*(abs(1./Sv(ind,2)-1./Sv(ind,1)) + abs(1./Sv(ind,3)-1./Sv(ind,1))+abs(1./Sv(ind,4)-1./Sv(ind,1)))
plot(aa)
bb = 1/2.*(abs(1./Sv(ind,3)-1./Sv(ind,1))+abs(1./Sv(ind,4)-1./Sv(ind,1)))



p1='/servernas/images3/romain/images/nucleipark/'
p2='/nasDicom/dicom_raw/PROTO_NUCLEIPARK/'

for k=1:length(dir)
  dicdir{k} = [p2 dir{k}(length(p1)+1:end)];
end
P=char(dicdir(ind));
ff = get_first_files_recursif(P);

for k=1:length(ff)
  if ~findstr(dicdir{ind(k)},ff{k})
    fprintf ('AAA %s \n',dicdir{ind(k)})
  end
end

write_dicom_info_to_csv(ff)


if 0 %copy T2
  
  dir = get_subdir_regex('/servernas/images3/romain/images/nucleipark','pilote0[12345678]',{'T2W','T2_FLAIR','T2_SPC'})

  outdir='/home/romain/images3/images/nucleipark/T2anat';
pp.wanted_number_of_file = 2;
pp.verbose=0;

  for k=1:length(dir)
    [p f] = fileparts(dir{k});
    [p sername] = fileparts(p);   
    [p sujname] = fileparts(p);   
    odir = fullfile(outdir,sujname,sername);
    mkdir(odir);
    
    ff =  get_subdir_regex_files(dir(k),'.*');
    ff=char(ff);
    for kk=1:size(ff,1)
      copyfile(deblank(ff(kk,:)),odir)
    end
    
  end
  

end
