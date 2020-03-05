

f = get_subdir_regex('/nasDicom/dicom_raw');
rout = {'/nasDicom/TRASH_dic'};

[pp nn]= get_parent_path(f);

for k = 1:length(f)
    
    fprintf('Removing %s \n',f{k});
    
    if nn{k}(1)=='2' %subject level
        [pp proto] = get_parent_path(f(k),2);
        fo = r_mkdir(rout,proto);
        
        r_movefile(f(k),fo,'move');
        
    elseif nn{k}(1)=='S' %serie level
        
        [pp suj] = get_parent_path(f(k),2);
        [pp proto] = get_parent_path(pp,1);
        fo = r_mkdir(rout,proto);
        fo = r_mkdir(fo,suj);

        r_movefile(f(k),fo,'move');
        
    end
    
    fprintf('done\n');
    
end
exit
