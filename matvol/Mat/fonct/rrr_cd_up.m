function [rep, sub_rep, value]= rrr_cd_up(rep)

  ind = findstr(rep,'/'); 
  %remove all last '/'
  while ind(end) == length(rep)
    rep(end)=[];
    ind(end)=[];
  end

  %remove  name
  sub_rep = rep( (ind(end)+1):end);

  rep( ind(end):end) = [];
  ind(end)=[];


if nargout==3
   dc = struct2cell(dir(rep));dc(:,1)=[];

   for kk=1:size(dc,2)
     if strcmp(dc{1,kk},sub_rep)
       value = kk;
       break
     end
   end

end