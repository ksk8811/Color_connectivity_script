function varargout = iptregistry(varargin)
%IPTREGISTRY Store information in persistent memory.
%   IPTREGISTRY(A) stores A in persistent memory.
%   A = IPTREGISTRY returns the value currently stored.
%
%   Once called, IPTREGISTRY cannot be cleared by calling clear
%   mex.
%
%   See also IPTGETPREF, IPTSETPREF.

%   Steven L. Eddins, September 1996
%   Copyright 1993-1998 The MathWorks, Inc.  All Rights Reserved.
%   $Revision: 1.1.1.1 $  $Date: 2001/11/07 09:38:03 $

error('Missing MEX-file IPTREGISTRY');
