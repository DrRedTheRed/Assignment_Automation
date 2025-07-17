%Dr.Red 2025.4.14%
clear; clc;

ply_goal = pcread('0.ply');
Q = ply_goal.Location;

fullmap = ply_goal;

robot_tf{1} = eye(4,4);
T_icp = eye(4);

output_folder = 'ICP_results';
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

for i = 1:9
    % The original cloud
    filename =sprintf('%d.ply', i);
    curr_ply =pcread(filename);
    P = curr_ply.Location; %of course, the original graph could stay at original position whatsoever.

    T_icp = eye(4);

    max_iter = 100;
    tolerance = 1e-5;
    prev_error = inf;

    for iter = 1:max_iter
        indices = knnsearch(Q, P);
        Q_matched = Q(indices, :);

        % 2. SVD stuff
        mu_P = mean(P);
        mu_Q = mean(Q_matched);% These are centers of mass

        X = P - mu_P;
        Y = Q_matched - mu_Q;

        H = X' * Y;

        [U, ~, V] = svd(H);
        R = V * U';

        %Very important: this step is to prevent a vertically/horizontally
        %reversed result which makes det(R)= -1 by SVD. If so, we need to
        %make it positive.
        if det(R) < 0
            V(:, end) = -V(:, end);
            R = V * U';
        end

        t = mu_Q'-R * mu_P';

        T_step = eye(4);
        T_step(1:3, 1:3) = R;
        T_step(1:3, 4) = t;
    
        T_icp = T_step * T_icp;  % inner transformation build-up

        P = (R * P')' +repmat(t', size(P, 1), 1);

        error = mean(vecnorm(P - Q_matched, 2, 2)); %RMSE

        if abs(prev_error-error) < tolerance
            break;
        end

        prev_error= error;
    end
    
    aligned_ply = pointCloud(P);

    %fig = figure;
    %pcshowpair(ply_goal, aligned_ply, 'MarkerSize', 50);
    %title(sprintf('ICP aligned ply_%d and ply_%d', i-1,i));
    %saveas(fig, fullfile(output_folder, sprintf('ICP_Aligned_ply_%d_and_ply_%d.png',i-1,i)));

    aligned_ply = pointCloud(P);%The new cloud
    
    fullmap = pcmerge(fullmap,aligned_ply,0.01);

    ply_goal = aligned_ply;
    Q = P; 
    robot_tf{i+1} = T_icp;
end

figure;
pcshow(fullmap, 'MarkerSize', 20);
hold on;

num_frames = length(robot_tf);
positions = zeros(num_frames, 3);

for i = 1:num_frames
    T = robot_tf{i};
    positions(i, :) = T(1:3, 4)';
end

plot3(positions(:,1), positions(:,2), positions(:,3), 'r-', 'LineWidth', 2);

axis_length = 0.5;
for i = 1:num_frames
    T = robot_tf{i};
    origin = T(1:3,4);

    x_axis = T(1:3,1) * axis_length;
    y_axis = T(1:3,2) * axis_length;
    z_axis = T(1:3,3) * axis_length;

    quiver3(origin(1), origin(2), origin(3), x_axis(1), x_axis(2), x_axis(3), ...
        'r', 'LineWidth', 1.5, 'MaxHeadSize', 2);
    quiver3(origin(1), origin(2), origin(3), y_axis(1), y_axis(2), y_axis(3), ...
        'g', 'LineWidth', 1.5, 'MaxHeadSize', 2);
    quiver3(origin(1), origin(2), origin(3), z_axis(1), z_axis(2), z_axis(3), ...
        'b', 'LineWidth', 1.5, 'MaxHeadSize', 2);

    text(origin(1), origin(2), origin(3), sprintf(' %d', i-1), 'FontSize', 10, 'Color', 'k');
end

title('Point Cloud Map with Robot Trajectory and Orientation');
xlabel('X'); ylabel('Y'); zlabel('Z');
axis equal;
view(3);

