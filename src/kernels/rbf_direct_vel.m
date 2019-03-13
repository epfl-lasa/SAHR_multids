function [f] = rbf_direct_vel(param)
%RBF_DIRECT_VEL Summary of this function goes here
%   Detailed explanation goes here

if ~isfield(param,'epsilon')
    error('Define epsilon');
end

if ~isfield(param,'lambda')
    error('Define lambda');
end

if ~isfield(param,'sigma')
    error('Define sigma');
end

k_rbf = Kernels2('gauss', param);
k_rbf = @(x) k_rbf(x,0);

f = @(x,y,v_x,v_y)...
    exp(-vecnorm(repmat(x,size(y,1),1)-repelem(y,size(x,1),1),2,2).^2./param.epsilon ...
        + param.lambda*( ...
    k_rbf(sum(repmat(v_x,size(y,1),1).*repelem(v_y,size(x,1),1),2) + 3*param.sigma*vecnorm(repmat(v_x,size(y,1),1),2,2).*vecnorm(repelem(v_y,size(x,1),1),2,2)) ...
    + sum(repmat(v_x,size(y,1),1).*repelem(v_y,size(x,1),1),2) - 1));
end

