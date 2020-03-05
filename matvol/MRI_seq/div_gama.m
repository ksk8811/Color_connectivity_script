
function  div_gama(f1,f2,gamma,outname)

for nbs=1:length(outname)
    
    v1 = spm_vol(f1{nbs});
    v2 = spm_vol(f2{nbs});
    
    A1=spm_read_vols(v1);
    A2=spm_read_vols(v2);
    
    %g=gamma*max(A2(:)).^2
    g=gamma
    
    B = (A1.*A2 -g)./(A1.^2+A2.^2+2*g);
    B = (B+0.5).*4096;
    
    
    v1.fname = outname{nbs};
    v1.dt=[16 0];
    
    spm_write_vol(v1,B)
end