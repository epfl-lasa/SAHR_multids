function [f] = polynomial(param)
%POLY_HOM Summary of this function goes here
%   Detailed explanation goes here
% Homogeneous and inhomogeneous Polynomial Kernel
if ~isfield(param,'degree')
    error('Define polynomial degree');
end

if ~isfield(param,'const')
    f = @(x,y) sum(repmat(x,size(y,1),1).*repelem(y,size(x,1),1),2)...
        .^param.degree;
else
    f = @(x,y) (sum(repmat(x,size(y,1),1).*repelem(y,size(x,1),1),2) + param.const)...
        .^param.degree;
end

if nargout > 1
    error('Gradient not available yet.');
end

if nargout > 2
    error('Hessian not available yet.');
end

end

