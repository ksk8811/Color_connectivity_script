function [da,db] = concat_struct_same_fields(a,b);
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

da = a;db = b;
