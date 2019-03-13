%% Load demos
clear; close all; clc;
load 2as_3t.mat;
demo = DataStruct.demo;
demo_struct = DataStruct.demo_struct;

%% Process data
proc_options = struct('center_data', false,...
                      'tol_cutting', 1,...
                      'dt', 0.1...
                      );
[X, targets] = ProcessDemos(demo, 2, demo_struct, proc_options);
