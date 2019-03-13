function [f, varargout] = Kernels2(type, param)
%KERNELS Summary of this function goes here
%   Detailed explanation goes here

switch type      

    case 'gauss'
        [f, varargout{1}, varargout{2}] = rbf(param);
        
    case 'gauss_direct_vel'
        [f] = rbf_direct_vel(param);

    case 'cosine'
        [f] = cosine;
    
    case 'polynomial'
        [f] = polynomial(param);

    case 'euclid_dist'
        [f] = euclidian;
        
    otherwise
        error('Kernel not available.');
end

end
