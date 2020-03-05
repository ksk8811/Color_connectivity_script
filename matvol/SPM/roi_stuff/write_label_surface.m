function fo = write_label_surface(surfin,labelin,label,outname,outdir,output_vol)
%function fo = write_label_surface(surfin,labelin,label,outname,outdir,output_vol)

if ~exist('output_vol')
    output_vol='';
else
    if length(surfin) ~= length(output_vol)
        error('length of reference to reslice volume should be the same as the input volume')
    end
end


if ~iscell(surfin)
    surfin = cellstr(surfin)';
end
if ~iscell(outdir)
    outdir = cellstr(outdir)';
end

if length(surfin) ~= length(outdir)
    error('length outdir should be the same as the input volume')
end
if length(surfin) ~= length(labelin)
    error('length labelfile should be the same as the input volume')
end


for num_in = 1:length(surfin)
    surf = gifti(surfin{num_in});
    lab = gifti(labelin{num_in});
    
    vf.faces=surf.faces;
    vf.vertices=surf.vertices;
    
    for k=1:length(label)
        
        foasc{k} = fullfile(outdir{num_in},[outname{k},'.asc']);
        fogii{k} = fullfile(outdir{num_in},[outname{k},'.gii']);
        
        ll = label{k};
        vv=zeros(size(lab.cdata));
        
        for kk=1:length(ll)
            vv = vv + double(lab.cdata==ll(kk));
        end
        
        if length(find(vv))==0
            error('No label %s found in %s',outname{k},labelin{num_in})
        end
        
        vf.FaceVertexCData = vv;
        surfwrite(vf,foasc{k});
        
        cmd = sprintf('surf2surf -i %s -o %s',foasc{k},fogii{k});
        unix(cmd)
        delete(foasc{k});
        
    end
    
    
    if ~isempty(output_vol)
        
        voname = change_file_extension(fogii,'.nii');
        for kk=1:length(fogii)
            cmd = sprintf('surf2volume %s %s %s caret',fogii{kk},output_vol{num_in},voname{kk});
            unix(cmd)
        end
        
    end
    
end


