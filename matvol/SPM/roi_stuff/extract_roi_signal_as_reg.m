function extract_roi_signal_as_reg(statdir,roi_imgs,out_dir)

if ~exist('out_dir')
  out_dir = statdir;
end

%if same normalized roi for all subject
if length(roi_imgs)==1 
  roi_imgs = repmat(roi_imgs,size(statdir))
end

if length(out_dir)~=length(statdir)
  error('in and out must have the same lenght')
end
if length(roi_imgs)~=length(statdir)
  error('in and out must have the same lenght')
end


%check if stats exist
for nsuj=1:length(statdir)

  if ~exist(fullfile(statdir{nsuj},'SPM.mat')),     
    warning('you must run the firstlevel first for %s \n',statdir);  
  end

end

warning_txt='';log_txt='';

for nsuj=1:length(statdir)
  roi_img = cellstr(roi_imgs{nsuj});
  
  for nbroi=1:length(roi_img)
  
    %roi= maroi('load', roi_path(nroi,:))
  
    roi = maroi_image(struct('vol', spm_vol(deblank(roi_img{nbroi})), 'binarize',1,'func', 'img>0'));
        
    load (fullfile(statdir{nsuj},'SPM.mat'));
    D=mardo_5(SPM);
    
    %P = image_names(D);%    P = strvcat(P{:});

    Y= get_marsy(roi, D, 'eigen1');
    %fY = apply_filter(D, Y);
    fYnw = apply_filter(D, Y, {'no_whitening'});

    sY = y_struct(fYnw);
    R = detrend(sY.Y);

    [pp,ff] = fileparts(roi_img{nbroi});
    
    save_file = fullfile(out_dir{nsuj},[ff '_user_reg']);
    
    if exist(save_file)
      warning_txt=sprintf('%s WARNING SKIP file %s because exist\n',warning_txt,save_file)
    else
      save(save_file,'R')
      log_txt=sprintf('%s saving  file %s\n',log_txt,save_file);
    end
    
  end
  
end

if ~isempty(log_txt)
  display(log_txt)
end
if ~isempty(warning_txt)
  display(warning_txt)
end
