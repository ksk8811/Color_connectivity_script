function [] = extract_roi_data3(P,roi)


textfile = 'contrast_value.csv';

fff=fopen(textfile,'w');


if length(roi)==1
    roi = repmat(roi,size(P));
end


for nbs = 1:length(roi)
    
    roisuj = cellstr(roi{nbs});
    Psuj = cellstr(P{nbs});
    
    for nbr = 1:length(roisuj)
        
        for nbp=1:length(Psuj)
            [pp sujname stat model conname] = get_parent_path(Psuj(nbp),4);
            [h Ap] = nifti_spm_vol(Psuj{nbp});
            
            [pp roiname] = get_parent_path(roisuj(nbr));
            
            [h Ar] = nifti_spm_vol(roisuj{nbr});
            indroi = Ar>0;
            
            fprintf(fff,'\n %s,%s,%s,%s', roiname{1},sujname{1}, model{1}, conname{1});
            fprintf(fff,',%f',Ap(indroi));
        end
    end
end

fclose(fff)
