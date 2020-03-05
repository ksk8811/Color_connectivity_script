
%concatenate phase acquisition

suj=get_subdir_regex

pdir = get_subdir_regex(suj,'_phase$')


cout.suj={};
cout.tr=[];
cout.alpha=[];
cout.phase=[];
cout.afraction=[];
cout.pixdim1 = [];

for nbs=1:length(pdir)
    [ss sernam] = get_parent_path(pdir(nbs));
    
    ii = strfind(sernam{1},'_');
    snum = str2num(sernam{1}(2:ii(1)-1));
    mag  =   get_subdir_regex(suj,['^S' sprintf('%.2d',snum-1) '_']);
    
    if isempty(mag) %i do not know why I have phase for S100 but magnitude in S98
        mag  =   get_subdir_regex(suj,['^S' sprintf('%.2d',snum-2) '_']);
    end
    
    [pp sernam] = get_parent_path(mag);

    f1 = get_subdir_regex_files(mag,'.*img');
    f2 = get_subdir_regex_files(pdir(nbs),'.*img');  
    fname = [sernam{1} '.nii'];
    fo = fullfile(ss{1} ,  fname) ;
    v = spm_vol(char([f1 f2]));
      
    spm_file_merge(v,fo);
    
    %read pix dim from nifti
    mat=v(1).mat;
    vox = sqrt(diag(mat'*mat));
    
    %read info from csf
    cvsfile = get_subdir_regex_files(mag,'csv$');
    [a h] = readtext(cvsfile{1});
    
    
    cout.suj{end+1}   = fname;
    cout.tr(end+1)    = a{2,21};
    cout.alpha(end+1) = a{2,23};
    cout.phase(end+1) = a{2,54};
    cout.afraction(end+1) = a{2,53};
    cout.pixdim1(end+1) = vox(1);
end

ff=get_subdir_regex_files(pp,'.*mat$')
do_delete(ff,0)

csvout = fullfile(pp{1},'paramQUICS.csv')

write_result_to_csv(cout,csvout)
