


function [e,da,db] = compare_struct(a,b);
%compare field value in a and b
%return a struct e of identical field value
%       a struct da of different field value (with value from a)
%       a struct db of different field value (with value from b)


[onlya] = mars_struct('strip',a,b);
[onlyb] = mars_struct('strip',b,a);

if  ~isempty(fieldnames(onlya))  | ~isempty(fieldnames(onlya))
  
  fprintf('Skiping unique fieldnames  %s \n',char(fieldnames(onlya))');
  fprintf('Skiping unique fieldnames  %s \n',char(fieldnames(onlyb)));

  a = mars_struct('strip',a,onlya);
  b = mars_struct('strip',b,onlyb);
  
end

af = fieldnames(a);

e = {};da = {};db = {};


for f = 1:length(af)
  fa = getfield(a,af{f});
  fb = getfield(b,af{f});
  
  equals = -1;
  
  if isnumeric (fa)
      if all(size(fa)==size(fb))
          equals = all(fa==fb);
      else
          equals = 0;
      end
    
  elseif isstr(fa)
    equals = strcmp(fa,fb);
  end
    
 if numel(equals)>1 ,  equals = prod(double(equals)); end%for multi dimentional array
  
  switch equals
    case 1
      e = setfield(e,af{f},fa);
    case 0
      da = setfield(da,af{f},fa);
      db = setfield(db,af{f},fb);
    case -1
      %fprintf('Field < %s > is not compare\n',af{f});
  end
    
end
