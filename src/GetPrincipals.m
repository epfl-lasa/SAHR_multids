function f = GetPrincipals(K, Alpha)
%GETPRINCIPALS Summary of this function goes here
%   Detailed explanation goes here

[m, n, dim] = size(K);
k = size(Alpha, 2);
f = zeros(n,dim,k);

Alpha = reshape(repelem(Alpha,1,n),m,n,k);

for i = 1:dim
   f(:,i,:) = permute(sum(Alpha.*K(:,:,i)),[2,1,3]);
end

end