function y=extract_roi_data

P = spm_select([1 Inf],'image','select images','',pwd);
roi_p = spm_select([1 Inf],'*','select roi','',pwd);

vol = spm_vol(P);

for nr=1:size(roi_p,1)
  roi= maroi('load', roi_p(nr,:));
  Y= get_marsy(roi, vol, 'mean');
  sy=struct(Y)  ;
  y{nr} = sy.y_struct.regions{1}.Y;

end
