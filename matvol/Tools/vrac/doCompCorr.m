function [V] = doCompCorr(rsfmri_list,opt)

thres_var = opt.thres_var;
numcomp = opt.numcomp;
components_file = opt.tmp_file;

vol=spm_vol(opt.brainmask);
brainmask = spm_read_vols(vol);

if ~isfield(opt,'z_fov')
    z_fov = 1:size(brainmask,3);
else
    z_fov = opt.z_fov;
end

V = spm_vol(rsfmri_list);
data = spm_read_vols(V);
stdev = std(data(:,:,z_fov,:),[],4);


%calculate stdev threshold
stdev_m = sort(stdev(brainmask(:,:,z_fov)>0));
index = floor((1. - thres_var) * length(stdev_m));
thres = stdev_m(index);

%thresholding
stdev(brainmask(:,:,z_fov)==0)=0;

mask_stdev = stdev>thres;
%mask_to_write = zeros(size(mask));
%mask_to_write(mask_stdev>0) = 1;
vol.fname = addprefixtofilenames(vol.fname,'stdev_')
spm_write_vol(vol,mask_stdev);


%nimask_stdev = nibabel.Nifti1Image(mask_to_write,nimask.get_affine())
%nimask_stdev.to_filename(os.path.join(inputfolder,'mask_noise.nii.gz'))

[nx,ny,nz,nt] = size(data(:,:,z_fov,:));
data_v = reshape(data(:,:,z_fov,:),[nx*ny*nz nt]);
sigs = data_v(stdev(:)>thres,:);

clear data data_v

%PCA
%use svd
covarianceMatrix = cov(st_normalise(sigs',2)', 1);
[E, D] = eig(covarianceMatrix);
[eigenval,index] = sort(diag(D));
index=rot90(rot90(index));
eigenvalues=rot90(rot90(eigenval))';
eigenvectors=E(:,index);
comps = eigenvectors(:,1:numcomp);

%[coeff, comps] = pca(sigs','NumComponents',numcomp);



%regfilt FSL
dlmwrite(components_file,comps, 'delimiter',' ');
filter_comp='';
for tt=1:numcomp
	if length(filter_comp)==0
			filter_comp=[filter_comp num2str(tt)];
    else
 			filter_comp = [filter_comp ',' num2str(tt)];
    end
end
[path,fname,ext]=fileparts(V(1).fname);
%cmd = ['fsl5.0-fslmerge -t ' fullfile(path,'compcorr_tmp.nii')]
cmd = ['fslmerge -t ' fullfile(path,'compcorr_tmp')];
for ii=1:nt
    cmd = [cmd ' ' V(ii).fname];
end
%system('FSLOUTPUTTYPE=NIFTI')
%system('export FSLOUTPUTTYPE')
system(cmd);

outff = fullfile(path,'corr_compcorr_tmp');

%cmd = ['fsl5.0-fsl_regfilt  -i ' fullfile(path,'compcorr_tmp.nii') ' -d ' components_file ' -o ' outff ' -f ' filter_comp];
cmd = ['export FSLOUTPUTTYPE=NIFTI;fsl_regfilt  -i ' fullfile(path,'compcorr_tmp') ' -d ' components_file ' -o ' outff ' -f ' filter_comp ' --vn'];
disp(cmd)
system(cmd);

if exist(fullfile(path,'compcorr_tmp.nii.gz'))
    delete(fullfile(path,'compcorr_tmp.nii.gz'))
% elseif exist(fullfile(path,'compcorr_tmp.nii'))
%     delete(fullfile(path,'compcorr_tmp.nii'))
end
delete(components_file)
% if exist(fullfile(path,'corr_compcorr_tmp.nii.gz'))
%     gunzip(fullfile(path,'corr_compcorr_tmp.nii.gz'))
% end
%delete(fullfile(path,'corr_compcorr_tmp.nii.gz'))

Vcorr = spm_vol(fullfile(path,'corr_compcorr_tmp.nii'));
data_corr = spm_read_vols(Vcorr);

files = '';
for i=1:length(V)
    [pname,fname,ext]=fileparts(V(i).fname);
    fname = strcat('c',fname,ext);
    files = strvcat(files,fullfile(pname,fname)); 
    V(i).fname = fullfile(pname,fname);
    V(i).dt = [16 0];
end

list_files = st_write_analyze(data_corr,V(1),files);

delete(fullfile(path,'corr_compcorr_tmp.nii'))




