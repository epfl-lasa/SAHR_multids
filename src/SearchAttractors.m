function [dynamics] = SearchAttractors(x_i,v_i,lambda,eigenvects,eigvect_l)
%SEARCHATTRACTORS Summary of this function goes here
%   Detailed explanation goes here

m = size(lambda,1);

% Extract the number of attractors
lambda = diag(lambda);
n_attracts = sum(lambda>=1-1e-5);
lambda = lambda(n_attracts+1:end);

% Extract the clustering right eigenvectors
clust_eigs = zeros(m,n_attracts);
for i = 1:n_attracts
   clust_eigs(:,i) =  abs(eigenvects(:,i)./vecnorm(eigenvects(:,i),2,2));
end
clust_eigs(isnan(clust_eigs)) = 0;
eigenvects = eigenvects(:,n_attracts+1:end);

% Extract the number of important eigenvalues and eigenvectors
tol = abs(lambda(2) - lambda(1))*50;
for i = 1 : m - n_attracts
    if abs(lambda(i+1) - lambda(i)) > tol
        n_eigs = i;
        break;
    end
end
lambda = lambda(1:n_eigs);
eigenvects = eigenvects(:,1:n_eigs);

% Cluster eigenvectors
dynamics = cell(n_attracts,6);

for i = 1:n_attracts
    row = find(clust_eigs(:,i));
    column = find(clust_eigs(:,i)'*eigenvects~=0);
    
    dynamics{i,1} = x_i(row,:);
    dynamics{i,2} = v_i(row,:);
    dynamics{i,3} = lambda(column);
    dynamics{i,4} = eigenvects(row,column);
    dynamics{i,5} = eigvect_l(row,i);
end

% Search attractors
k_cos = Kernels2('cosine');

for i = 1:n_attracts
    points = zeros((size(dynamics{i,4},2)+1), size(dynamics{i,4},2),2);
    points(1,:,1) = dynamics{i,4}(randi(size(dynamics{i,4},1)),:);
    [~,index] = sort(vecnorm(dynamics{i,4}-points(1,:,1),2,2),'ascend');
    points(1,:,2) = dynamics{i,4}(index(5),:);
    
    for j = 2:size(dynamics{i,4},2)+1
        while 1
           p = dynamics{i,4}(randi(size(dynamics{i,4},1)),:);
           [~,index] = sort(vecnorm(dynamics{i,4}-p,2,2),'ascend');
           n = dynamics{i,4}(index(5),:);
           if (abs(k_cos(points(1:j-1,:,1) - points(1:j-1,:,2), p-n))) < 0.9
               break;
           end
        end
        points(j,:,1) = p;
        points(j,:,2) = n;
    end
    points1 = reshape(points(1,:,:), 2,size(dynamics{i,4},2),[])';
    points2 = reshape(points(2,:,:), 2,size(dynamics{i,4},2),[])';
    dynamics{i,6} = Intersect2Lines(points1, points2)';
    
    figure
    scatter(dynamics{i,4}(:,1), dynamics{i,4}(:,2))
    hold on
    scatter(points1(:,1),points1(:,2),'filled','MarkerEdgeColor',[0 0 0])
    scatter(points2(:,1),points2(:,2),'filled','MarkerEdgeColor',[0 0 0])
    scatter(dynamics{i,6}(1),dynamics{i,6}(2),'filled','MarkerEdgeColor',[0 0 0])
end

end

