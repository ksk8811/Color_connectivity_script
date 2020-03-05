function [list_arg_mat, nb_args] = extract_args(list_args)

k = 1;
str_tmp = '';

for i=1:size(list_args,2)
    if list_args(i) ==','
        list_arg_mat{k}=str_tmp;
        str_tmp = '';
        k=k+1;
    else
        str_tmp = sprintf('%s%s',str_tmp,list_args(i));
    end
end

nb_args = k-1;