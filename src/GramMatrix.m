function K = GramMatrix(f, options, varargin)
%KERNELMATRIX Summary of this function goes here
%   Detailed explanation goes here

if isfield(options,'norm') 
    norm = options.norm;             
else
    norm = false;
end

if isfield(options,'vv_rkhs') 
    vv_rkhs = options.vv_rkhs;             
else
    vv_rkhs = false;
end

feval = f(varargin{:});

m = size(varargin{1},1);
n = size(varargin{2},1);
d =  sqrt(size(feval,2));

if vv_rkhs
    K = reshape(...
        permute(...
        reshape(...
        reshape(...
        reshape(feval',1,[]),d,[]),d,m*d,[]),[2,1,3]),[],n*d,1);
    [m,n] = size(K);
else
    K = reshape(feval, m, n, []);
end

% Matrix Normalization
% For Vector-Valued RKHS matrices this likely change the final result if
% done before or after the expansion of the matric.
if norm && m==n
    column_sums = sum(K,1) / m;
    total_sum   = sum(column_sums,2) / m;
    C = repmat(column_sums,m,1,1);
    K = K - C - permute(C,[2,1,3]);
    K = K + total_sum; 
end

end
