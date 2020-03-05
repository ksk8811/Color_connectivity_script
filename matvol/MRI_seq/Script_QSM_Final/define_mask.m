function Mask=define_mask(iMag,thresh)

% Define Brain mask -> Needs to be done with SPM8
mask=iMag>(thresh*max(iMag(:)));
mask=~BWorder(bwlabeln(~mask));
mask=bwdist(~mask,'chessboard')>3;
mask=(bwlabeln(mask,6));
mask=mask==mask(ceil(end/2),ceil(end/2),ceil(end/2));
mask=bwdist(mask,'chessboard')<=3;
Mask=bwdist(~mask,'chessboard')>2;
Mask(:,:,[1 end])=0;