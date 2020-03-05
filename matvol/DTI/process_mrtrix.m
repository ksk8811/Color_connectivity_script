function process_mrtrix(V4D,par,jobappend)
%function process_mrtrix(V4D,par,jobappend)
%warning this is no more function process_mrtrix(V4D,dti_dir,par,jobappend)


if ~exist('par')
    par='';
end
if ~exist('jobappend','var'), jobappend ='';end


if ~isfield(par,'bvals')    par.bvals = 'bvals';  end
if ~isfield(par,'bvecs')    par.bvecs = 'bvecs';  end
if ~isfield(par,'lmax')     par.lmax=8;    end
if ~isfield(par,'fsl_mask')    par.fsl_mask = 'nodif_brain_mask.nii';  end
if ~isfield(par,'grad_file')    par.grad_file = 'grad.b';  end
if ~isfield(par,'csd_name')    par.csd_name = 'CSD8.nii';  end
if ~isfield(par,'skip_if_exist')    par.skip_if_exist = 1;  end
if ~isfield(par,'fa_thr'), par.fa_thr = 0.7;end
if ~isfield(par,'mrtrix_subdir'), par.mrtrix_subdir='mrtrix';end

if ~isfield(par,'jobdir'),  par.jobdir=pwd; end
if ~isfield(par,'jobname'),  par.jobname='mrtrix_process'; end
if ~isfield(par,'sge'), par.sge=1; end

if nargin==0
    V4D = get_subdir_regex_files();
    dti_dir = get_subdir_regex;
end

cwd=pwd; job={};

for nbsuj = 1:length(V4D)
    
    [dir4D ff ex] = fileparts(V4D{nbsuj});
    dti_dir = fullfile(dir4D,par.mrtrix_subdir);
    if ~exist(dti_dir,'dir'), mkdir(dti_dir);end

    cd (dti_dir);
    
    if exist(par.csd_name,'file') && par.skip_if_exist , skip=1;else skip=0;end
    
    if ~skip
        
        fprintf('\n****************\nInitial import of in %s\n',pwd);
        
        if exist('mask.nii','file') && par.skip_if_exist , skip_import=1;else skip_import=0;end
        if ~skip_import
            
            %Convert the gradient file in mrtrix format
            bvecsf = get_file_from_same_dir(V4D(nbsuj),par.bvecs);
            bvalsf = get_file_from_same_dir(V4D(nbsuj),par.bvals);

            %copy the 4D file in new mrtrix dir (dti_dir)
                        
            aa = r_movefile(V4D(nbsuj),{dti_dir},'link');
            if strcmp(ex,'.gz'),   aa= unzip_volume(aa);  end
            V4D(nbsuj) = aa;
            
            bvec = load(bvecsf{1});
            bval = load(bvalsf{1});
            bval(bval<50) = 0;
            
            if size(bvec,1)>size(bvec,2), bvec=bvec';bval=bval';end
            
            vol = spm_vol(V4D{nbsuj});
            mat=vol(1).mat(1:3,1:3);
            vox = sqrt(diag(mat'*mat));  e=eye(3) ;e(1,1)=vox(1);e(2,2)=vox(2);e(3,3)=vox(3);
            rot=mat/e;
            fmrtrix=rot*bvec;
            fmr=[fmrtrix' bval'];
            
            fid = fopen(fullfile(dti_dir,par.grad_file),'w');
            fprintf(fid,'%f\t%f\t%f\t%f\n',fmr');
            fclose(fid);
            
            %copy  fsl mask in dti_dir
            fmask = get_subdir_regex_files(dir4D,par.fsl_mask,1);            
            aa = r_movefile(fmask,dti_dir,'link'); 
            aa = unzip_volume(aa)
            fmask = r_movefile(aa,fullfile(dti_dir,'mask.nii'),'move'); 
           
        else
            V4D(nbsuj) = get_subdir_regex_files(pwd,ff,1);
            fmask =  {fullfile(pwd,'mask.nii')};
        end
        
        %erode the mask 3 time
        % if exist('mask_erode3.nii'),  delete('mask_erode3.nii'); end
        
        cmd = sprintf('cd %s;\nerode %s - | erode - - | erode -  - | mrconvert - mask_erode3.nii -datatype UInt8 ',pwd,fmask{1});
        
        %create the tensor and fa
        cmd = sprintf('%s;\n dwi2tensor %s -grad %s  dt.nii',cmd,V4D{nbsuj}, par.grad_file);
        
        cmd = sprintf('%s;\n tensor2FA dt.nii - | mrmult - mask.nii fa.nii',cmd);
        
        cmd = sprintf('%s;\n tensor2vector dt.nii - | mrmult - fa.nii facolor.nii',cmd);
        
        %Mask of single-fibre voxels
        if exist('sf.nii'),  delete('sf.nii'); end
        
        % cmd = sprintf('%s;\n\n mrmult fa.nii mask_erode3.nii - | threshold - -abs 0.7  - |erode - - |erode - - -dilate |mrconvert - sf.nii -datatype UInt8 ',cmd);
        %    cmd = sprintf('%s;\n\n mrmult fa.nii mask_erode3.nii - | threshold - -abs 0.7 - |mrconvert - sf.nii -datatype UInt8 ',cmd);
        cmd = sprintf('%s;\n\n mrmult fa.nii mask_erode3.nii - | threshold - -abs %f  - |mrconvert - sf.nii -datatype UInt8 ',cmd,par.fa_thr);
        
        cmd = sprintf('%s;\n\n A=`fslstats sf.nii -V|awk ''{print $1}''`',cmd);
        cmd = sprintf('%s;\n echo sf.nii has $A points',cmd);
        
        cmd = sprintf('%s;\n if [ $A -le 50 ] ; then \n    echo To few point in sf so tacking FA<0.63',cmd);
        cmd = sprintf('%s;\n    rm -f sf.nii ',cmd);
        cmd =  sprintf('%s;\n    mrmult fa.nii mask_erode3.nii - | threshold - -abs  0.63  - |mrconvert - sf.nii -datatype   UInt8 ',cmd);
        cmd = sprintf('%s;\n fi \n ',cmd);
        
        %[a b] = unix(cmd);  ms = str2num(b); ms=ms(1);
        %    if ms<50
        %      fprintf('To few point in sf so tacking FA<0.63\n');
        
        %      delete('sf.nii')
        %      cmd = 'mrmult fa.nii mask_erode3.nii - | threshold - -abs 0.63  - |erode - - |erode - - -dilate |mrconvert - sf.nii -datatype UInt8 ';
        %      unix(cmd);
        %     cmd = 'fslstats sf.nii -V';  [a b] = unix(cmd);  ms = str2num(b); ms=ms(1);
        %   end
        
        %   if ms<10
        %     error('mask of single fibre too small : %d point\n',ms);
        %   elseif ms<50
        %     warning('mask of single fibre has only %d point\n',ms);
        %   else
        %     fprintf('mask of single fibre with : %d point\n',ms);
        %   end
        
        %estimate the Response function coefficient
        cmd = sprintf('%s\n estimate_response %s -grad %s  sf.nii response.txt -info -lmax %d ',cmd,V4D{nbsuj}, par.grad_file,par.lmax);
        
        %CSD computation
        cmd = sprintf('%s\n csdeconv  %s -grad %s response.txt -lmax %d -mask mask.nii %s\n',cmd,V4D{nbsuj}, par.grad_file,par.lmax,par.csd_name);
        
        if par.sge
            job{end+1} = cmd;
        else
            unix(cmd)
        end
        
    end %if ~skip
end%for nbsuj = 1:length(V4D)

cd(cwd);

job = do_cmd_sge(job,par,jobappend);
