function co = scale_conc(c,par)

if ~exist('par')
  par='';
end

if ~isfield(par,'scale')
  par.scale = 100;
end

if ~isfield(par,'field_prefix')
  par.field_prefix = '';
end

if ~isfield(par,'field_list')
  par.field_list = fieldnames(c);
end



if ~isempty(par.field_prefix)
  field_list_tochange={};
  
  for kf=1:length(par.field_list)
    if strcmp(par.field_prefix,par.field_list{kf}(1:length(par.field_prefix)))
      field_list_tochange{end+1} = par.field_list{kf};
    end
    
  end
else
  field_list_tochange=par.field_list;
end

co=c;

for npool = 1:length(co)
  for nf=1:length(field_list_tochange)

    metname = field_list_tochange{nf};

    cmet = getfield(co(npool),metname);
    cc = cmet .* par.scale;
    co(npool)  = setfield(co(npool),metname,cc);

  end
end

