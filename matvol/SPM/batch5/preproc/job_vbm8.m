function matlabbatch=job_vbm8(f,par)
%-----------------------------------------------------------------------
% Job configuration created by cfg_util (rev $Rev: 3357 $)
%-----------------------------------------------------------------------

if ~exist('par'),  par='';end

def_par.jobname='matlab_vbm8';
def_par.sge=0;
def_par.walltime = '01:00:00';
def_par.bias = [1 1 1]; % native-space nomalized Affine
def_par.gm = [1 0 2 2]; % native-space | nomalized | modulated (1 affine 2 non-linear only) | dartel export (1 rigid 2 affine)
def_par.wm = [1 0 2 2];  
def_par.cm = [1 0 2 2];  
def_par.label = [1 0 0];

par = complet_struct(par,def_par);


f=cellstr(char(f));
spm_dir = fileparts(which('spm'));

matlabbatch{1}.spm.tools.vbm8.estwrite.data = f;

matlabbatch{1}.spm.tools.vbm8.estwrite.opts.tpm = {[spm_dir '/toolbox/Seg/TPM.nii']};
matlabbatch{1}.spm.tools.vbm8.estwrite.opts.ngaus = [2 2 2 3 4 2];
matlabbatch{1}.spm.tools.vbm8.estwrite.opts.biasreg = 0.0001;
matlabbatch{1}.spm.tools.vbm8.estwrite.opts.biasfwhm = 60;
matlabbatch{1}.spm.tools.vbm8.estwrite.opts.affreg = 'mni';
matlabbatch{1}.spm.tools.vbm8.estwrite.opts.warpreg = 4;
matlabbatch{1}.spm.tools.vbm8.estwrite.opts.samp = 3;
matlabbatch{1}.spm.tools.vbm8.estwrite.extopts.dartelwarp = 1;
matlabbatch{1}.spm.tools.vbm8.estwrite.extopts.ornlm = 0.7;
matlabbatch{1}.spm.tools.vbm8.estwrite.extopts.mrf = 0.15;
matlabbatch{1}.spm.tools.vbm8.estwrite.extopts.cleanup = 1;
matlabbatch{1}.spm.tools.vbm8.estwrite.extopts.print = 1;
matlabbatch{1}.spm.tools.vbm8.estwrite.output.GM.native = par.gm(1);
matlabbatch{1}.spm.tools.vbm8.estwrite.output.GM.warped = par.gm(2);
matlabbatch{1}.spm.tools.vbm8.estwrite.output.GM.modulated = par.gm(3);
matlabbatch{1}.spm.tools.vbm8.estwrite.output.GM.dartel = par.gm(4);
matlabbatch{1}.spm.tools.vbm8.estwrite.output.WM.native = par.wm(1);
matlabbatch{1}.spm.tools.vbm8.estwrite.output.WM.warped = par.wm(2);
matlabbatch{1}.spm.tools.vbm8.estwrite.output.WM.modulated = par.wm(3);
matlabbatch{1}.spm.tools.vbm8.estwrite.output.WM.dartel = par.wm(4);
matlabbatch{1}.spm.tools.vbm8.estwrite.output.CSF.native = par.cm(1);
matlabbatch{1}.spm.tools.vbm8.estwrite.output.CSF.warped = par.cm(2);
matlabbatch{1}.spm.tools.vbm8.estwrite.output.CSF.modulated = par.cm(3);
matlabbatch{1}.spm.tools.vbm8.estwrite.output.CSF.dartel = par.cm(4);
matlabbatch{1}.spm.tools.vbm8.estwrite.output.bias.native = par.bias(1);
matlabbatch{1}.spm.tools.vbm8.estwrite.output.bias.warped = par.bias(2);
matlabbatch{1}.spm.tools.vbm8.estwrite.output.bias.affine = par.bias(3);
matlabbatch{1}.spm.tools.vbm8.estwrite.output.label.native = par.label(1);
matlabbatch{1}.spm.tools.vbm8.estwrite.output.label.warped =  par.label(2);
matlabbatch{1}.spm.tools.vbm8.estwrite.output.label.dartel =  par.label(3);
matlabbatch{1}.spm.tools.vbm8.estwrite.output.jacobian.warped = 0;
matlabbatch{1}.spm.tools.vbm8.estwrite.output.warps = [1 1];

if par.sge
    
    for k=1:length(f)
        
        matlabbatch{1}.spm.tools.vbm8.estwrite.data = f(k);
        j=matlabbatch;
        cmd = {'spm_jobman(''run'',j)'};
        varfile = do_cmd_matlab_sge(cmd,par);
        save(varfile{1},'j');
    end
end
