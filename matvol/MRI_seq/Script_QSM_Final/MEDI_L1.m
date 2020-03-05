% Morphology Enabled Dipole Inversion (MEDI)
%   [x, cost_reg_history, cost_data_history] = MEDI_L1(varargin)
%
%   output
%   x - the susceptibility distribution 
%   cost_reg_history - the cost of the regularization term
%   cost_data_history - the cost of the data fidelity term

%   When using the code, please cite 
%   T. Liu et al. MRM 2013;69(2):467-76
%   J. Liu et al. Neuroimage 2012;59(3):2560-8.
%   T. Liu et al. MRM 2011;66(3):777-83
%   de Rochefort et al. MRM 2010;63(1):194-206
%
%   Adapted from Ildar Khalidov
%   Modified by Tian Liu on 2011.02.01
%   Modified by Tian Liu and Shuai Wang on 2011.03.15
%   Modified by Tian Liu and Shuai Wang on 2011.03.28 add voxel_size in grad and div
%   Last modified by Tian Liu on 2013.07.24
%   Simplified by Mathieu D. Santin on 2013.11.21

function [x, cost_reg_history, cost_data_history] = MEDI_L1(lambda,phase_int,N_std,Mask,iMag,matrix_size,voxel_size,B0_dir,Tau)

data_weighting = 1;
gradient_weighting = 1;

%%%%%%%%%%%%%%% weights definition %%%%%%%%%%%%%%
cg_max_iter = 100;
cg_tol = 0.01;
max_iter = 10;
tol_norm_ratio = 0.1;
data_weighting_mode = data_weighting;
gradient_weighting_mode = gradient_weighting;
grad = @cgrad;
div = @cdiv;

tempn = double(N_std);
D=dipole_kernel_liu(matrix_size, voxel_size, B0_dir);

m = dataterm_mask(data_weighting_mode, tempn, Mask);
b0 = m.*exp(1i*phase_int);
wG = gradient_mask(gradient_weighting_mode, iMag, Mask, grad, voxel_size);


iter=0;
x = zeros(matrix_size); 
res_norm_ratio = Inf;
cost_data_history = zeros(1,max_iter);
cost_reg_history = zeros(1,max_iter);

e=0.000001; %a very small number to avoid /0

while (res_norm_ratio>tol_norm_ratio)&&(iter<max_iter)
tic
    iter=iter+1;
    Vr = 1./sqrt(abs(wG.*grad(real(x),voxel_size)).^2+e);
    w = m.*exp(1i*ifftn(D.*fftn(x)));
    reg = @(dx) div(wG.*(Vr.*(wG.*grad(real(dx),voxel_size))),voxel_size);
    fidelity = @(dx)2*lambda*real(ifftn(D.*fftn(conj(w).*w.*real(ifftn(D.*fftn(dx))))));

    A =  @(dx) reg(dx) + fidelity(dx);       
    b = reg(x) + 2*lambda*real(ifftn(D.*fftn( conj(w).*conj(1i).*(w-b0))));

    dx = real(cgsolve(A, -b, cg_tol, cg_max_iter, 0));
    res_norm_ratio = norm(dx(:))/norm(x(:));
    x = x + dx;

    wres=m.*exp(1i*(real(ifftn(D.*fftn(x))))) - b0;

    cost_data_history(iter) = norm(wres(:),2);
    cost=abs(wG.*grad(x));
    cost_reg_history(iter) = sum(cost(:));   
    fprintf('iter: %d; res_norm_ratio:%8.4f; cost_L2:%8.4f; cost:%8.4f.\n',iter, res_norm_ratio,cost_data_history(iter), cost_reg_history(iter));
toc
    

end

%convert x to ppm
x = x/Tau.*Mask;
end





              
