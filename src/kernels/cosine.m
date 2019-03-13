function [f] = cosine
%COSINE Summary of this function goes here
%   Detailed explanation goes here
% Positions (Velocities) Cosine Kernel

f = @(x,y) sum(repmat(x,size(y,1),1).*repelem(y,size(x,1),1),2)...
    ./vecnorm(repmat(x,size(y,1),1),2,2)./vecnorm(repelem(y,size(x,1),1),2,2);

if nargout > 1
    error('Gradient not available yet.');
end

if nargout > 2
    error('Hessian not available yet.');
end
    
end

