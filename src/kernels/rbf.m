function [f, df, d2f] = rbf(param)
% RBF Gauss Kernel: exp(-||x-y||/2*sigma^2)
% This is the classical Gaussian Kernel
% Required parameters: sigma
if ~isfield(param,'sigma')
    error('Define sigma');
end

f = @(x,y)...
    exp(-vecnorm(repmat(x,size(y,1),1)-repelem(y,size(x,1),1),2,2).^2/...
    2/param.sigma^2);

% Gradient
if nargout > 1
    df = @(x,y)...
         (repmat(x,size(y,1),1)-repelem(y,size(x,1),1))/...
         param.sigma^2.*f(x,y);     
end

% Hessian
if nargout > 2          
d2f = @(x,y)...
      (-repmat(reshape(eye(size(x,2)),1,[]),size(x,1)*size(y,1),1)+...
      (repelem(repmat(x,size(y,1),1)-repelem(y,size(x,1),1),1,size(x,2)).*...
      repmat(repmat(x,size(y,1),1)-repelem(y,size(x,1),1),1,size(x,2)))/param.sigma^2)/...
      param.sigma^2.*f(x,y);
end

end

