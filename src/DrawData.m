function [varargout] = DrawData(data, targets, options)
close all;

if nargin == 3 && isfield(options,'limits') 
    limits = options.limits;
else
    limits = [0 100 0 100];
end

if nargin == 3 && isfield(options,'plot_pos') 
    plot_pos = options.plot_pos;
else
    plot_pos = true;
end

if nargin == 3 && isfield(options,'plot_vel') 
    plot_vel = options.plot_vel;
else
    plot_vel = false;
end

%% Plot Recorded data
plot_options            = [];
plot_options.is_eig     = false;
plot_options.labels     = data(end,:);

if plot_pos
    plot_options.title      = 'Position';
    varargout{1} = PlotData(data(1:2,:)',plot_options);
    axis square;
    xlim(limits(1:2)); ylim(limits(3:4))
    hold on
    for i = 1:size(targets,1)
        plot(targets(i,1), targets(i,2),'xk','markersize',30);
    end
    
%     quiver(data(1,:)',data(2,:)',data(3,:)',data(4,:)');
end

if plot_vel
    plot_options.title      = 'Velocity';
    varargout{2} = PlotData(data(3:4,:)',plot_options);
    axis equal;
end

end

