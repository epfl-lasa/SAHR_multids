function [f] = sigmoid(param)
%SIGMOID Summary of this function goes here
%   Detailed explanation goes here

f = @(x) 1./(1 + exp(-(x-0.01)/param.slope));
end

