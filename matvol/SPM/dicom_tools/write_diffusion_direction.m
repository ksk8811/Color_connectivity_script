function write_diffusion_direction(hdrname,Filenames)

fid = fopen(hdrname,'w');

[p,f]=fileparts(hdrname);
fid_fsl_val = fopen(fullfile(p,[f,'.bvals']),'w');
fid_fsl_vec = fopen(fullfile(p,[f,'.bvecs']),'w');
fid_track_vis = fopen(fullfile(p,[f,'.trackvis']),'w');

%fprintf(fid,'ImageNum \t B0 \t Direction\n');

if isstruct(Filenames{1})
    % this is already the spm_dicom_headers structure
    hhh = Filenames;
else
    hhh = spm_dicom_headers(char(Filenames));
end

%sort the header by Image number
for k =1:length(Filenames)
    Inum(k) = hhh{k}.InstanceNumber;
end

[v,ind]=sort(Inum)  ;
hhh = hhh(ind);


%remove file of different Slice locations (if not mosaic )
Slocref = hhh{1}.SliceLocation;
Inum = hhh{1}.InstanceNumber;
for k =2:length(Filenames)
    Sloc = hhh{k}.SliceLocation;    
    if Sloc == Slocref %it is a new volume
       Inum(end+1) = hhh{k}.InstanceNumber;       
    end
    
end
[v,ind]=sort(Inum)  ;
hhh = hhh(ind);


for k=1:length(hhh)
    hh = hhh{k};
    
    bval(k) = hh.Private_0019_100c;
    if isfield(hh,'Private_0019_100e')
        ddir(k,:) = hh.Private_0019_100e;
        ddir(k,:) = ddir(k,:) ./ norm(ddir(k,:));
    else
        ddir(k,:) = [0 0 0];
    end
end

orient =  reshape(hh.ImageOrientationPatient,[3 2]);;
orient(:,3) = null(orient');
if det(orient)<0, orient(:,3) = -orient(:,3); warning('arrg negative orient not sure on the direction (rrr)'); end;
analyze_to_dicom = diag([1 -1 1]);
orient=orient*analyze_to_dicom;

ddir = ddir * orient;

fprintf(fid_fsl_val,'%d ',bval);
fprintf(fid_fsl_val,'\n');
fclose(fid_fsl_val);

for kd=1:3
    fprintf(fid_fsl_vec,'%f ',ddir(:,kd));
    fprintf(fid_fsl_vec,'\n');
end
fclose(fid_fsl_vec);

fprintf(fid_track_vis,'%f, %f, %f\n',ddir');
fclose(fid_track_vis);

fprintf(fid,'%d %f %f %f\n',[bval;ddir']);
fclose(fid);


