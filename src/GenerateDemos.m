function [demo, demo_struct] = GenerateDemos(options)
% GENERATE_MOUSE_DATA(NTH_ORDER, N_DOWNSAMPLE) request the user to give
% demonstrations of a trajectories in a 2D workspace using the mouse cursor
% The data is stored in an [x ; dx/dt] structure  
% The data isdownsampled by N_DOWNSAMPLE samples

%   # Authors: Klas Kronander, Wissam Bejjani and Jose Medina
%   # EPFL, LASA laboratory
%   # Email: jrmout@gmail.com

demo_struct{1} = 'position';

if nargin == 1 && isfield(options,'limits') 
    limits = options.limits;
else
    limits = [0 100 0 100];
end

if nargin == 1 && isfield(options,'calc_vel')
    calc_vel = options.calc_vel;
    if calc_vel
        demo_struct{length(demo_struct)+1} = 'velocity';
    end
else
    calc_vel = false;
end

if nargin == 1 && isfield(options,'get_time')
    get_time = options.get_time;
    if get_time
        demo_struct{length(demo_struct)+1} = 'time';
    end
else
    get_time = false;
end

if nargin == 1 && isfield(options,'get_labels')
    get_labels = options.get_labels;
    if get_labels
        demo_struct{length(demo_struct)+1} = 'labels';
    end
else
    get_labels = false;
end

%% Drawing plot
fig = figure();
view([0 90]);
hold on;

axis(limits);
delete_trace = 0;
start_dem = 1;

% to store the data
X = [];
% flag for signaling that the demonstration has ended
demonstration_index = 0;
demonstration_index_monitor = 0;
% Colors for labels
colors = hsv(10);
% Labels
label_id = 1;
cleared_data = 0;

% select our figure as gcf
figure(fig);
hold on
% disable any figure modes
zoom off
rotate3d off
pan off
brush off
datacursormode off

set(fig,'WindowButtonDownFcn',@(h,e)button_clicked(h,e));
set(fig,'WindowButtonUpFcn',[]);
set(fig,'WindowButtonMotionFcn',[]);
set(fig,'Pointer','circle');
hp = gobjects(0);

% Stop button
stop_btn = uicontrol('style','pushbutton','String', 'Store Data','Callback',@stop_recording, ...
          'position',[0 0 110 25], ...
          'UserData', 1);

% Label button
label_btn = uicontrol('style','pushbutton','String', 'Change Label','Callback',@change_label, ...
          'position',[150 0 210 25], ...
          'UserData', 1);            

% Clear button
uicontrol('style','pushbutton','String', 'Clear','Callback',@clear_data, ...
          'position',[400 0 110 25], ...
'UserData', 1);      
        
% wait until demonstration is finished
while( (get(stop_btn, 'UserData') == 1))
    pause(0.01);
    if demonstration_index ~= demonstration_index_monitor
        x_obs{demonstration_index} = X;
        labels{demonstration_index} = label_id;
        X = [];
        demonstration_index_monitor = demonstration_index;
        set(fig,'WindowButtonDownFcn',@(h,e)button_clicked(h,e));
        set(fig,'WindowButtonUpFcn',[]);
        set(fig,'WindowButtonMotionFcn',[]);
        set(fig,'Pointer','circle');
    end
end

n_demonstrations = demonstration_index_monitor;
demo = cell(n_demonstrations,1);

%% Savitzky-Golay filter and derivatives
%   x :             input data size (time, dimension)
%   dt :            sample time
%   nth_order :     max order of the derivatives 
%   n_polynomial :  Order of polynomial fit
%   window_size :   Window length for the filter
start_dem = 1 + cleared_data;
for dem = start_dem:n_demonstrations
    data = [];
    
    pos = x_obs{dem}(1:2,:);
    t = x_obs{dem}(3,:);
    
    data = [data;  pos];
    
    if calc_vel
        ppx = spline(t,pos);
        ppxd = differentiate_spline(ppx);
        vel = ppval(ppxd,t);
        data = [data; vel];
    end
    
    if get_time
        data = [data; t];
    end
    
    if get_labels
        data = [data; labels{dem}*ones(1,size(t, 2))];
    end
    
    demo{dem} = data;
end

return

%% Functions for data capture
% Clear data button function
function clear_data(ObjectS, ~)
    data = [];
    X = [];
    label_id = 1;
    cleared_data = demonstration_index;
    set(ObjectS, 'UserData', 0); % unclick button
    delete(hp);
end
    
    
function stop_recording(ObjectS, ~)
    set(ObjectS, 'UserData', 0);
end

function change_label(ObjectS, ~)
    label_id = label_id + 1;
end

function ret = button_clicked(~,~)
    if(strcmp(get(gcf,'SelectionType'),'normal'))
        start_demonstration();
    end
end

function ret = start_demonstration()
    disp('Started demonstration');
    tic;
    %------------------------------------------------------------------
    % Print current point when mouse button pressed.
    % For printing when releasing mouse button released, place these
    % lines at the beginning of stop_demonstration function)
    x = get(gca,'Currentpoint');
    x = x(1,1:2)';
    x = [x;toc];
    X = [X, x];
    hp = [hp, plot(x(1),x(2), '.' ,'markersize',20, 'Color', colors(label_id,:))];
    %------------------------------------------------------------------
    set(gcf,'WindowButtonMotionFcn',@record_current_point);
    set(gcf,'WindowButtonUpFcn',@stop_demonstration);
    ret = 1;
end

function ret = stop_demonstration(~,~)
    disp('Stopped demonstration. Press stop recording in the figure if you have enough demonstrations.');
    set(gcf,'WindowButtonMotionFcn',[]);
    set(gcf,'WindowButtonUpFcn',[]);
    set(gcf,'WindowButtonDownFcn',[]);
    if(delete_trace)
        delete(hp);
    end
    demonstration_index = demonstration_index + 1;
end

function ret = record_current_point(~,~)
    x = get(gca,'Currentpoint');
    x = x(1,1:2)';
    x = [x;toc];
    X = [X, x];
    hp = [hp, plot(x(1),x(2), '.' ,'markersize',20, 'Color', colors(label_id,:))];
end

function [ d_nth_x ] = sgolay_time_derivatives(x, dt, nth_order, ...
                                                n_polynomial, window_size)
%   SGOLAY_TIME_DERIVATIVES Computes Savitzky Golay filter with a moving
%   window and derivatives up to the n-th order 
%   x :             input data size (time, dimension)
%   dt :            sample time
%   nth_order :     max order of the derivatives 
%   n_polynomial :  Order of polynomial fit
%   window_size :   Window length for the filter

    if (size(x,1) < window_size) 
        error(['The window size (' num2str(window_size) ...
            ') is greater than the data length (' num2str(size(x,1)) ...
            '). Choose a smaller window size...'] );
    end
    
    [~,g] = sgolay(n_polynomial,window_size);   % Calculate S-G coefficients
    for dim=1:size(x,2)
        y = x(:,dim)';
        half_win  = ((window_size+1)/2) -1; % half window size
        ysize = size(y,2); %number of data points
        for n = (window_size+1)/2 : ysize-(window_size+1)/2,
            for dx_order = 0:nth_order
                  d_nth_x(n,dim,dx_order+1) = dot(y(n-half_win : n+half_win), ...
                      factorial(dx_order)/dt^dx_order * g(:,dx_order+1));
            end
        end
    end

    % Remove the data at the beginning due to the 
    crop_size = (window_size+1)/2;
    d_nth_x = d_nth_x(crop_size:end, :, :);
end

function pp_out = differentiate_spline(pp_in)
% extract details from piece-wise polynomial by breaking it apart
[breaks,coefs,l,k,d] = unmkpp(pp_in);
% make the polynomial that describes the derivative
pp_out = mkpp(breaks,repmat(k-1:-1:1,d*l,1).*coefs(:,1:k-1),d);
end

end

