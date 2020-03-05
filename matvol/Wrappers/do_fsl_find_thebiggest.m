function fo = do_fsl_find_thebiggest(f)



for k=1:length(f)

  ff = cellstr(char(f(k)));
  [p aa] = fileparts(ff{1})
  fo{k} = fullfile(p,'the_biggest');

  cmd = sprintf('find_the_biggest ');
  for kk =1:length(ff)
     cmd = sprintf('%s %s',cmd,ff{kk});
  end
  cmd = sprintf('%s %s',cmd,fo{k});

  unix(cmd);

end
