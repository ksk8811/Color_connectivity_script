function oname = find_free_label_name(label)

[fcode, fname, rgbv] = my_read_fscolorlut();

for k=1:length(label)
  
  ll = label{k};
  na = '';

  if length(ll) <= 3
    for kk=1:length(ll)
      ind = find(fcode==ll(kk));
      if isempty(ind)
	error('%d is not a freesurfer label',ll(kk))
      end
    
      na = [na fname{ind},'_AND_'];
    end
    na(end-4:end) = '';
    oname{k} = na;
    
  else
    
    ind = find(fcode==ll(1));
    if isempty(ind)
      error('%d is not a freesurfer label',ll(kk))
    end
    
    na = [ fname{ind} '_AND_'];
    for kk=1:length(ll)
      ind = find(fcode==ll(kk));
      if isempty(ind)
	error('%d is not a freesurfer label',ll(kk))
      end
    
      na = [na num2str(ll(kk)),'_AND_'];
    end
    
    na(end-4:end) = '';
    oname{k} = na;
  
    
  end
  
end
