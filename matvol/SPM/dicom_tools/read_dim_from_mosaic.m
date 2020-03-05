function dim=read_dim_from_mosaic(hdr)

np  = read_AcquisitionMatrixText(hdr);
dim = [np read_NumberOfImagesInMosaic(hdr)];

if size(dim,2)<3
    dim(3)=1;
end
%_______________________________________________________________________

%_______________________________________________________________________
function n = read_NumberOfImagesInMosaic(hdr)
str = hdr.CSAImageHeaderInfo;
val = get_numaris4_val(str,'NumberOfImagesInMosaic');
n   = sscanf(val','%d');
if isempty(n), n=[]; end;
return;
%_______________________________________________________________________

%_______________________________________________________________________
function dim = read_AcquisitionMatrixText(hdr)
str = hdr.CSAImageHeaderInfo;
val = get_numaris4_val(str,'AcquisitionMatrixText');
dim = sscanf(val','%d*%d')';
if length(dim)==1,
	dim = sscanf(val','%dp*%d')';
end;
if isempty(dim), dim=[]; end;
return;
%_______________________________________________________________________

%_______________________________________________________________________
function val = get_numaris4_val(str,name)
name = deblank(name);
val  = {};
for i=1:length(str),
	if strcmp(deblank(str(i).name),name),
		for j=1:str(i).nitems,
			if  str(i).item(j).xx(1),
				val = {val{:} str(i).item(j).val};
			end;
		end;
		break;
	end;
end;
val = strvcat(val{:});
return;
%_______________________________________________________________________
