function fo=get_all_images_files(fi)

pp.verbose=0;

for k=1:length(fi)

  [p,f,e] = fileparts(fi{k});
  
  fo(k) = get_subdir_regex_files(p,['^',f,'\.'],pp);

end

fo=cellstr(char(fo));
