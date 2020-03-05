function [data_n,m,v] = st_normalise(data,method,mask)

% Normalisation of the time courses of a dastaset
%
% [data_n,m,v] = st_normalise(data,method,mask)
%
% INPUTS
% data          3D+t or 1D+t dataset 
% method        (opt., default 0) 0, 1 or 2 (see OUTPUTS)
% mask          mask of interest
%
% OUTPUTS
% data_n        4D (3D+t) dataset with time courses in mask are mean-corrected (method = 2) 
%               or mean-corrected and of unit-variance (method = 0, fast, or 1, slow with memory optimization).
%
% COMMENTS
% Vincent Perlbarg 02/07/05

% Copyright (C) 07/2009 Vincent Perlbarg, LIF/Inserm/UPMC-Univ Paris 06, 
% vincent.perlbarg@imed.jussieu.fr
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.

% On redimensionne les donnees pour se ramener au cas 1D+t
if length(size(data))==4
    data_4D = 1;
    [nx,ny,nz,nt] = size(data);
    data = reshape(data,[nx*ny*nz,nt]);
else
    data_4D = 0;
    nt = size(data,1);
    data = data';
end

% Options par defaut
if nargin == 3;
    data=data(mask(:),:);
end

if nargin==1
    method = 0;
end

% Normalisation des data selon methodes 1,2 ou 3
if method==0
    m=mean(data,2);
    data_n=data-m*ones([1 size(data,2)]);
    v=(1/(nt-1))*sum(data_n.^2,2);
    ect=sqrt(v);
    data_n=data_n./(ect*ones([1 size(data,2)]));
    data_n(isnan(data_n))=0;
end

if method==1
    nb_courbes=size(data,1);
    m=mean(data,2);
    data_n=zeros(size(data));
    for i=1:nb_courbes
        data_n(i,:)=data(i,:)-m(i);
    end
    v=(1/(nt-1))*sum(data_n.^2,2);
    for i=1:nb_courbes
        if v(i)~=0
            data_n(i,:)=data_n(i,:)/sqrt(v(i));
        end
    end
end

if method==2
    m=mean(data,2);
    data_n=data-m*ones([1 size(data,2)]);
    if nargout == 3
        v=(1/(nt-1))*sum(data_n.^2,2);
    end
end

% On renvoie les data normalisees au bon format.
if data_4D
    if nargin ==3
        data_n_bis = zeros([nx*ny*nz nt]);
        data_n_bis(mask(:),:) = data_n;
        data_n = reshape(data_n_bis,[nx,ny,nz,nt]);
        if nargout > 1
            m_bis = zeros([nx*ny*nz 1]);
            m_bis(mask(:),:) = m;
            m = reshape(m_bis,[nx,ny,nz]);
        end
        if nargout > 2
            v_bis = zeros([nx*ny*nz 1]);
            v_bis(mask(:),:) = v;
            v = reshape(v_bis,[nx,ny,nz]);
        end
    else
        data_n = reshape(data_n,[nx,ny,nz,nt]);
    end
else
    data_n = data_n';
end
