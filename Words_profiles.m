%Word localizer: plot profiles of activation for basic contrasts (category vs others) 
 
load( 'SPM.mat' ) ;
 
figure(1);

%% transforming mm coordinates to voxels
xyzmm=spm_mip_ui('GetCoords')
iM = SPM.xVol.iM ;
xyzvox = iM( 1:3, : ) * [ xyzmm ; 1 ] ;

%% getting the beta values for each of the basic conrasts
VY = SPM.xCon;
VY = SPM.xCon(1:6);
 
y = ones( length(VY), 1 ) ;
for i = 1:1:length(VY)
      y(i) = spm_sample_vol( VY(i).Vcon, xyzvox(1), xyzvox(2), xyzvox(3), 0 ) ;
      name{i} = VY(i).name;
end

figure
bar(y)
set(gca,'XTickLabel',name)
% 
% yrms = spm_sample_vol( SPM.VResMS, xyzvox(1), xyzvox(2), xyzvox(3), 0 ) ;
% 
% figure
% 
%  errorbar(1:length(y), y,repmat(yrms,size(y)))

