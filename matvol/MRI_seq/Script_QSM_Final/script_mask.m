
%% Loading T1


[filename pathname] = uigetfile('*.img','Open T1 dataset');
t1=[pathname filename];

% Create SPM job
job=job_vbm8(t1);
% pour accelerer un peu: je ne crois pas que ca change beaucopu le résultat
job{1}.spm.tools.vbm8.estwrite.extopts.mrf=0;
job{1}.spm.tools.vbm8.estwrite.extopts.sanlm=0;

% send job
spm_jobman('run',job); % 'interactive' to check options


% vbm8: add prefixes to the files
[path name ext]=fileparts(t1);
ext='.nii';
gmfile =fullfile(path,['p1' name ext]);
wmfile =fullfile(path,['p2' name ext]);
csffile=fullfile(path,['p3' name ext]);

% open files
hdr_gm=spm_vol(gmfile);
gm    =spm_read_vols(hdr_gm);

hdr_wm=spm_vol(wmfile);
wm    =spm_read_vols(hdr_wm);

hdr_csf=spm_vol(csffile);
csf    =spm_read_vols(hdr_csf);

% Now erosions and all that stuff
tissue=gm>0.05|wm>0.05|csf>0.05;

% To end
hdr_final=hdr_gm;
hdr_final.fname='Mask.nii';
spm_write_vol(hdr_final,tissue);

