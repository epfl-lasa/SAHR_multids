function [dynamics] = RegularizeData(dynamics)
%REGULARIZEDATA Summary of this function goes here
%   Detailed explanation goes here

x_train = dynamics{1};
v_train = dynamics{2};
psi = dynamics{4};
x_a = dynamics{6};

n_points = ceil(size(x_train,1)*(1-30/100));
n_exclude = ceil(size(x_train,1)*5/100);

k_dist = Kernels('euclid_dist');

t = 0.5;
kpar = struct('sigma', sqrt(t/2));
k = Kernels('gauss', kpar);
gram_options = struct('norm', false,...
                      'vv_rkhs', false);
% figure(100);

while size(x_train,1) ~= n_points
    S = GramMatrix(k, gram_options, x_train, x_train);
    D = sum(S,2);
    [~, index] = sort(k_dist(psi,x_a),'ascend');
    D(index(1:n_exclude)) = 0;
    [~,del] = max(D);
%     D = sort(S,2,'ascend');
%     [~,del] = min(sum(D(:,1:10),2));
    x_train(del,:) = [];
    v_train(del,:) = [];
    psi(del,:) = [];
end

S = GramMatrix(k, gram_options, x_train, x_train); 

dynamics{1} = x_train;
dynamics{2} = v_train;
dynamics{4} = psi;
dynamics{5} = sum(S,2)/max(sum(S,2));

end
