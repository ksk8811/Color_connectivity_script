function c = add_res_to_struct(c,name,Y)

for k=1:length(name)
	if isfield(c,name{k})
		yy = getfield(c,name{k});
		yy(end+1) = Y{k};
		c = setfield(c,name{k},yy);
	else
		c = setfield(c,name{k},Y{k});
	end

end


