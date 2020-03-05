


function [res] = is_struct_equal(a,b,skip,strict);
%compare field value in a and b
%return a struct e of identical field value
%       a struct da of different field value (with value from a)
%       a struct db of different field value (with value from b)
verbose=0;

if ~exist('strict','var'), strict=0; end

if exist('skip','var')
  a = mars_struct('strip',a,skip);
  b = mars_struct('strip',b,skip);
end

[onlya] = mars_struct('strip',a,b);
[onlyb] = mars_struct('strip',b,a);

if  ~isempty(fieldnames(onlya))  | ~isempty(fieldnames(onlyb))
  
    if strict
        if verbose
        fprintf('diff unique field   %s  | %s \n',char(fieldnames(onlya)),char(fieldnames(onlyb)));
        end
        
        res=0; return
    end
    
    a = mars_struct('strip',a,onlya);
    b = mars_struct('strip',b,onlyb);
  
end

af = fieldnames(a);

e = {};da = {};db = {};

res=1;
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
  elseif iscell(fa)
      if length(fa)==length(fb)
          equals=1;
          for aaa=1:length(fa)
              if all(size(fa{aaa})==size(fb{aaa}))
              equals = equals & all(fa{aaa}==fb{aaa});
              else
                  equals=0;
              end
          end
      else
        equals=0;
      end
  end
    
 if numel(equals)>1 ,  equals = prod(double(equals)); end%for multi dimentional array
  
 if equals==0
     if verbose
         fprintf('field %s differ   %s  |  %s \n',af{f},num2str(fa),num2str(fb))
     end
     res=0;
     break
 end
    
end
