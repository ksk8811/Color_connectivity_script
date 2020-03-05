function [c res]  = read_conc_from_csvR(file)

if ~exist('file')
  file=get_subdir_regex_files;
end

file=char(file);

[A rrr] = readtext(file);

V=A(2:end,1:end);
header = nettoie_dir(A(1,3:end));
group=cell2mat(V(:,2));
suj = V(:,1);

[AAA rrrrrr] = readtext(file,',','','','numeric');
Vals = AAA(2:end,3:end) ;  %cell2mat(V(:,3:end));

res.suj = suj;
res.hdr = header;
res.dat = Vals;
res.group = group;


GG=unique(group);

for k=1:length(GG)
  c(k).pool = sprintf('%s_Groupe_%d',A{1,1},GG(k));
  res.group_name{k} = c(k).pool;
  
  c(k).suj = suj(group==GG(k));
  
  for kk=1:length(header)
    if k==1
      c = setfield(c,header{kk},Vals(group==GG(k),kk));
    else
      c(k) = setfield(c(k),header{kk},Vals(group==GG(k),kk));
    end
  end

end

[p,f,e] = fileparts(file);
res.title = f;




%pour passe de r a c (si r est modifie)
%cr=c;
%for kg=1:length(unique(r.group))
%  for kh=1:length(r.hdr)
%    cr(kg) = setfield(cr(kg),r.hdr{kh}, r.dat(r.group==kg,kh) );
%  end
%end
