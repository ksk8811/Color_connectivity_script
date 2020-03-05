addpath(genpath('/Users/k.siudakrzywicka/Desktop/tools/conn'))

cd '/Users/k.siudakrzywicka/Desktop/RDS_fMRI/RDS_localizers/RDS_longitudinal_rest/conn_project01/results/firstlevel/ANALYSIS_03';


d1=load('resultsROI_Subject001_Condition001.mat','DOF');
d2=load('resultsROI_Subject002_Condition001.mat','DOF');
se=sqrt(1/max(0,d1.DOF-3)+1/max(0,d2.DOF-3));




for source=[5, 7:9]
 filenames=arrayfun(@(n)sprintf('BETA_Subject%03d_Condition001_Source%03d.nii',n,source),1:2,'uni',0);
 a=spm_vol(char(filenames));
 z=spm_read_vols(a);
 mask=any(isnan(z),4)|all(z==0,4);
 p=spm_Ncdf((z(:,:,:,2)-z(:,:,:,1))/se); % difference in correlations p-value
 p=2*min(p,1-p); % two-sided p-values
 p(mask)=nan;
 
 filename=sprintf('p_corr_Subject1_Condition001vsCondition002_Source%03d.nii',source);
 V=struct('mat',a(1).mat,'dim',a(1).dim,'fname',filename,'pinfo',[1;0;0],'n',[1,1],'dt',[spm_type('float32') spm_platform('bigend')]);
 spm_write_vol(V,p);
 
 filename=sprintf('p_corr_thresholded_0001_Subject1_Condition001vsCondition002_Source%03d.nii',source);
 V=struct('mat',a(1).mat,'dim',a(1).dim,'fname',filename,'pinfo',[1;0;0],'n',[1,1],'dt',[spm_type('uint8') spm_platform('bigend')]);
 spm_write_vol(V,double(p<.0001));

 
 p(:)=conn_fdr(p(:));
 filename=sprintf('pFDR_corr_Subject1_Condition001vsCondition002_Source%03d.nii',source);
 V=struct('mat',a(1).mat,'dim',a(1).dim,'fname',filename,'pinfo',[1;0;0],'n',[1,1],'dt',[spm_type('float32') spm_platform('bigend')]);
 spm_write_vol(V,p);
 
 filename=sprintf('pFDR_thresholded_p07_corr_Subject1_Condition001vsCondition002_Source%03d.nii',source);
 V=struct('mat',a(1).mat,'dim',a(1).dim,'fname',filename,'pinfo',[1;0;0],'n',[1,1],'dt',[spm_type('uint8') spm_platform('bigend')]);
 spm_write_vol(V,double(p<.07));
 

 
end 

