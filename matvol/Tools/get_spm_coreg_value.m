function o = get_spm_coreg_value(VGin,VFin,varargin)
%function x = get_spm_coreg_value(VG,VF,varargin)
%from spm_coreg

% if nargin >= 4
%     x = optfun(varargin{:});
%     return;
% end

def_flags          = spm_get_defaults('coreg.estimate');
def_flags.params   = [0 0 0  0 0 0];
def_flags.graphics = ~spm('CmdLine');
if nargin < 3
    flags = def_flags;
else
    flags = varargin{3};
    fnms  = fieldnames(def_flags);
    for i=1:length(fnms)
        if ~isfield(flags,fnms{i})
            flags.(fnms{i}) = def_flags.(fnms{i});
        end
    end
end

if ischar(VFin),    VFin=cellstr(VFin);end
if ischar(VGin),    VGin=cellstr(VGin);end

for nbs = 1:length(VFin)
    
    VF = spm_vol(VFin{nbs});
    VG = spm_vol(VGin{nbs});
    
    if ~isfield(VG, 'uint8')
        VG.uint8 = loaduint8(VG);
        vxg      = sqrt(sum(VG.mat(1:3,1:3).^2));
        fwhmg    = sqrt(max([1 1 1]*flags.sep(end)^2 - vxg.^2, [0 0 0]))./vxg;
        VG       = smooth_uint8(VG,fwhmg); % Note side effects
    end
    
   
    for k=1:numel(VF)
        VFk = VF(k);
        if ~isfield(VFk, 'uint8')
            VFk.uint8 = loaduint8(VFk);
            vxf       = sqrt(sum(VFk.mat(1:3,1:3).^2));
            fwhmf     = sqrt(max([1 1 1]*flags.sep(end)^2 - vxf.^2, [0 0 0]))./vxf;
            VFk       = smooth_uint8(VFk,fwhmf); % Note side effects
        end
        o.mi(nbs,k)  = optfun(VG,VFk,'mi');
        o.ecc(nbs,k) = optfun(VG,VFk,'ecc');
        o.nmi(nbs,k) = optfun(VG,VFk,'nmi');
        o.ncc(nbs,k) = optfun(VG,VFk,'ncc');
    end
end

%==========================================================================
% function o = optfun(x,VG,VF,s,cf,fwhm)
%==========================================================================
function o = optfun(VG,VF,cf,s,fwhm)
% The function that is minimised.
if nargin<5, fwhm = [7 7];   end
if nargin<4, s    = [1 1 1]; end
if nargin<3, cf   = 'mi';    end

% Voxel sizes
vxg = sqrt(sum(VG.mat(1:3,1:3).^2));sg = s./vxg;

% Create the joint histogram
%H = spm_hist2(VG.uint8,VF.uint8, VF.mat\spm_matrix(x(:)')*VG.mat ,sg);
H = spm_hist2(VG.uint8,VF.uint8, VF.mat*VG.mat ,sg);

% Smooth the histogram
lim  = ceil(2*fwhm);
krn1 = smoothing_kernel(fwhm(1),-lim(1):lim(1)) ; krn1 = krn1/sum(krn1); H = conv2(H,krn1);
krn2 = smoothing_kernel(fwhm(2),-lim(2):lim(2))'; krn2 = krn2/sum(krn2); H = conv2(H,krn2);

% Compute cost function from histogram
H  = H+eps;
sh = sum(H(:));
H  = H/sh;
s1 = sum(H,1);
s2 = sum(H,2);

switch lower(cf)
    case 'mi'
        % Mutual Information:
        H   = H.*log2(H./(s2*s1));
        mi  = sum(H(:));
        o   = -mi;
    case 'ecc'
        % Entropy Correlation Coefficient of:
        % Maes, Collignon, Vandermeulen, Marchal & Suetens (1997).
        % "Multimodality image registration by maximisation of mutual
        % information". IEEE Transactions on Medical Imaging 16(2):187-198
        H   = H.*log2(H./(s2*s1));
        mi  = sum(H(:));
        ecc = -2*mi/(sum(s1.*log2(s1))+sum(s2.*log2(s2)));
        o   = -ecc;
    case 'nmi'
        % Normalised Mutual Information of:
        % Studholme,  Hill & Hawkes (1998).
        % "A normalized entropy measure of 3-D medical image alignment".
        % in Proc. Medical Imaging 1998, vol. 3338, San Diego, CA, pp. 132-143.
        nmi = (sum(s1.*log2(s1))+sum(s2.*log2(s2)))/sum(sum(H.*log2(H)));
        o   = -nmi;
    case 'ncc'
        % Normalised Cross Correlation
        i     = 1:size(H,1);
        j     = 1:size(H,2);
        m1    = sum(s2.*i');
        m2    = sum(s1.*j);
        sig1  = sqrt(sum(s2.*(i'-m1).^2));
        sig2  = sqrt(sum(s1.*(j -m2).^2));
        [i,j] = ndgrid(i-m1,j-m2);
        ncc   = sum(sum(H.*i.*j))/(sig1*sig2);
        o     = -ncc;
    otherwise
        error('Invalid cost function specified');
end


%==========================================================================
% function udat = loaduint8(V)
%==========================================================================
function udat = loaduint8(V)
% Load data from file indicated by V into an array of unsigned bytes.
if size(V.pinfo,2)==1 && V.pinfo(1) == 2
    mx = 255*V.pinfo(1) + V.pinfo(2);
    mn = V.pinfo(2);
else
    spm_progress_bar('Init',V.dim(3),...
        ['Computing max/min of ' spm_str_manip(V.fname,'t')],...
        'Planes complete');
    mx = -Inf; mn =  Inf;
    for p=1:V.dim(3)
        img = spm_slice_vol(V,spm_matrix([0 0 p]),V.dim(1:2),1);
        mx  = max([max(img(:))+paccuracy(V,p) mx]);
        mn  = min([min(img(:)) mn]);
        spm_progress_bar('Set',p);
    end
end

% Another pass to find a maximum that allows a few hot-spots in the data.
spm_progress_bar('Init',V.dim(3),...
    ['2nd pass max/min of ' spm_str_manip(V.fname,'t')],...
    'Planes complete');
nh = 2048;
h  = zeros(nh,1);
for p=1:V.dim(3)
    img = spm_slice_vol(V,spm_matrix([0 0 p]),V.dim(1:2),1);
    img = img(isfinite(img));
    img = round((img+((mx-mn)/(nh-1)-mn))*((nh-1)/(mx-mn)));
    h   = h + accumarray(img,1,[nh 1]);
    spm_progress_bar('Set',p);
end
tmp = [find(cumsum(h)/sum(h)>0.9999); nh];
mx  = (mn*nh-mx+tmp(1)*(mx-mn))/(nh-1);

% Load data from file indicated by V into an array of unsigned bytes.
spm_progress_bar('Init',V.dim(3),...
    ['Loading ' spm_str_manip(V.fname,'t')],...
    'Planes loaded');
udat = zeros(V.dim,'uint8');
st = rand('state'); % st = rng;
rand('state',100); % rng(100,'v5uniform'); % rng('defaults');
for p=1:V.dim(3)
    img = spm_slice_vol(V,spm_matrix([0 0 p]),V.dim(1:2),1);
    acc = paccuracy(V,p);
    if acc==0
        udat(:,:,p) = uint8(max(min(round((img-mn)*(255/(mx-mn))),255),0));
    else
        % Add random numbers before rounding to reduce aliasing artifact
        r = rand(size(img))*acc;
        udat(:,:,p) = uint8(max(min(round((img+r-mn)*(255/(mx-mn))),255),0));
    end
    spm_progress_bar('Set',p);
end
spm_progress_bar('Clear');
rand('state',st); % rng(st);


%==========================================================================
% function acc = paccuracy(V,p)
%==========================================================================
function acc = paccuracy(V,p)
if ~spm_type(V.dt(1),'intt')
    acc = 0;
else
    if size(V.pinfo,2)==1
        acc = abs(V.pinfo(1,1));
    else
        acc = abs(V.pinfo(1,p));
    end
end


%==========================================================================
% function V = smooth_uint8(V,fwhm)
%==========================================================================
function V = smooth_uint8(V,fwhm)
% Convolve the volume in memory (fwhm in voxels).
lim = ceil(2*fwhm);
x  = -lim(1):lim(1); x = smoothing_kernel(fwhm(1),x); x  = x/sum(x);
y  = -lim(2):lim(2); y = smoothing_kernel(fwhm(2),y); y  = y/sum(y);
z  = -lim(3):lim(3); z = smoothing_kernel(fwhm(3),z); z  = z/sum(z);
i  = (length(x) - 1)/2;
j  = (length(y) - 1)/2;
k  = (length(z) - 1)/2;
spm_conv_vol(V.uint8,V.uint8,x,y,z,-[i j k]);


%==========================================================================
% function krn = smoothing_kernel(fwhm,x)
%==========================================================================
function krn = smoothing_kernel(fwhm,x)

% Variance from FWHM
s = (fwhm/sqrt(8*log(2)))^2+eps;

% The simple way to do it. Not good for small FWHM
% krn = (1/sqrt(2*pi*s))*exp(-(x.^2)/(2*s));

% For smoothing images, one should really convolve a Gaussian
% with a sinc function.  For smoothing histograms, the
% kernel should be a Gaussian convolved with the histogram
% basis function used. This function returns a Gaussian
% convolved with a triangular (1st degree B-spline) basis
% function.

% Gaussian convolved with 0th degree B-spline
% int(exp(-((x+t))^2/(2*s))/sqrt(2*pi*s),t= -0.5..0.5)
% w1  = 1/sqrt(2*s);
% krn = 0.5*(erf(w1*(x+0.5))-erf(w1*(x-0.5)));

% Gaussian convolved with 1st degree B-spline
%  int((1-t)*exp(-((x+t))^2/(2*s))/sqrt(2*pi*s),t= 0..1)
% +int((t+1)*exp(-((x+t))^2/(2*s))/sqrt(2*pi*s),t=-1..0)
w1  =  0.5*sqrt(2/s);
w2  = -0.5/s;
w3  = sqrt(s/2/pi);
krn = 0.5*(erf(w1*(x+1)).*(x+1) + erf(w1*(x-1)).*(x-1) - 2*erf(w1*x   ).* x)...
    +w3*(exp(w2*(x+1).^2)     + exp(w2*(x-1).^2)     - 2*exp(w2*x.^2));

krn(krn<0) = 0;


