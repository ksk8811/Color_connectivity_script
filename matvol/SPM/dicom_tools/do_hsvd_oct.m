function [amp,phi,delta,FHz,Fppm,Z,C]=do_hsvd_oct(m_in,K)


fprintf('HSVD... ')

nbpts = length(m_in.spec_time);
fs = m_in.hdr.spectral_width;
synF = m_in.hdr.synthesizer_frequency;
m = floor(nbpts/2);

fid = m_in.spec_time;

H = hankel(fid(1:m),fid(m:nbpts));
[U,S,V] = svd(H);
Sk = S(1:K,1:K);
Uk = U(:,1:K);
Vk = V(:,1:K);

% total least square solution
Uk_up = Uk(2:end,:);
Uk_down = Uk(1:end-1,:);
[Uplus,Splus,Vplus]=svd([Uk_down Uk_up]);
Q = -Vplus(1:K,K+1:end)*pinv(Vplus(K+1:end,K+1:end));
[u,s,v] = svd(Q);
pol = diag(Q);
poles = pol(1:K);

for p=0:length(fid)-1
    sZ(:,p+1)=poles.^p;
end

dt = 1/fs;
delta = -log(abs(poles))./dt;
FHz = angle(poles)./(2*dt*pi);

Y = fid';
Z = sZ';
C = pinv(Z'*Z)*Z'*Y;

%Y_chap = Z*C;
%t=(1:nbpts)./fs;

amp = abs(C);
phi = angle(C);

Fppm = FHz/(synF)+m_in.hdr.nucleus_offset_frequency;




