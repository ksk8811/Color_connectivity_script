function transform_4D_multishell_to_singleshells(fi_4D,par)

if ~exist('par')
    par='';
end

defpar.bvals_values = [1000 2000 3000];
defpar.bvecs = '^bvecs$';
defpar.bvals = '^bvals$';

par = complet_struct(par,defpar);


for kf=1:length(fi_4D)
    
    [p,ff,e] = fileparts(fi_4D{kf});
    
    if strfind(ff,'.'),        [ppp ff e] = fileparts(ff);    end
        
    bvals = get_subdir_regex_files(p,par.bvals,1);
    bvecs = get_subdir_regex_files(p,par.bvecs,1);
    
    bval = load(bvals{1});   if size(bval,2)==1, bval=bval';end
    bvec = load(bvecs{1});   if size(bvec,2)==3, bvec=bvec';end

    
    indB0 = find(bval<50);
    totind = length(indB0);
    
    for k =1:length(par.bvals_values)
        indB{k} = find( bval>(par.bvals_values(k)-50) & bval<(par.bvals_values(k)+50) );
        totind = totind + length(indB{k});        
    end
    
    if length(bval) ~= totind
        warning('missing bvalues find only a subset of %d instead of %d',totind,length(bval))
    end
    
    outname = fullfile(p,'toutlesvolume3D');
    cmd = sprintf('fslsplit  %s %s -t',fi_4D{kf},outname);
    unix(cmd)
    
    fi3D = char(get_subdir_regex_files(p,'toutlesvolume3D',length(bval)));
    
    for k =1:length(par.bvals_values)
        outname = fullfile(p,[ff sprintf('_B%d',par.bvals_values(k))]);
        outnamebval = fullfile(p,sprintf('bval_B%d',par.bvals_values(k)));
        outnamebvec = fullfile(p,sprintf('bvec_B%d',par.bvals_values(k)));
        
        do_fsl_merge(fi3D([indB0 indB{k}],:),outname);        
        
        fid_fsl = fopen(outnamebvec,'w');
        for kd=1:3
            fprintf(fid_fsl,'%f ',bvec(kd,[indB0 indB{k}]));
            fprintf(fid_fsl,'\n');
        end
        fclose(fid_fsl) ;       
        
        fid_fsl = fopen(outnamebval,'w');
        fprintf(fid_fsl,'%d ',bval([indB0 indB{k}]));
        fclose(fid_fsl);
                
    end
    
    outname = fullfile(p,[ff '_B0']);
    do_fsl_merge(fi3D([indB0 ],:),outname);        
    
    do_delete(fi3D,0)

end



