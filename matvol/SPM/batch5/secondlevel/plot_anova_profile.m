% AFFICHAGE DU PROFIL DE REPONSE POUR UNE ANOVA DANS SPM
% Revue et corrigée 05/01/2005

function [ymat]=plot_anova_profile();

load( 'SPM.mat' ) ;

figure(1);
xyzmm=spm_mip_ui('GetCoords')
iM = SPM.xVol.iM ;
xyzvox = iM( 1:3, : ) * [ xyzmm ; 1 ] ;

%
fprintf( '\n READ RAW DATA\n' ) ;
VY = SPM.xY.VY;
y = ones( length(VY), 1 ) ;
h = waitbar( 0, 'Raw data reading...' ) ;
for i = 1:1:length(VY)
      waitbar( i/length(VY), h ) ;
      VY(i).fname
      y(i) = spm_sample_vol( VY(i), xyzvox(1), xyzvox(2), xyzvox(3), 0 ) ;
end
close(h) ;

fprintf( '\n AVERAGING \n\n' ) ;
nconds = length(SPM.xX.iH);
nsubj = length(y)/nconds;
ymat=reshape(y,nsubj,nconds);
meanactiv = mean(ymat);  %%%% mean activation across subjects
meanbysubj = mean(ymat');
withinsubj = ymat-repmat(meanbysubj',1,nconds); %%%% mean activation after subtraction of the subject's mean
sterror = std(withinsubj)/sqrt(nsubj);

fprintf( '\n DISPLAY RESULTS\n\n' ) ;
figure(31);clf;
hold on

bar(1:nconds,mean(ymat));
errorbar(1:nconds,mean(ymat),sterror,'.k');
xlabel( 'Conditions', 'FontSize', 12 )
YLstr = sprintf( 'Response at [%g, %g, %g]', xyzmm ) ;
title( YLstr, 'FontSize', 12 )

% END OF PROGRAM
