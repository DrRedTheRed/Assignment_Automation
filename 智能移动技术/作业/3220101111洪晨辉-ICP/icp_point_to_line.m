%Dr.Red 2025.4.14%
clear; clc;

tgt_pc = pcread('0.ply');
fullmap = tgt_pc;

robot_tf{1} = eye(4,4);
T = eye(4,4);

output_folder = 'ICP_results_p2l';
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

for i = 1:9
    filename =sprintf('%d.ply', i);
    src_pc =pcread(filename);

    %3D -> 2D
    src = src_pc.Location(:,1:2);
    tgt = tgt_pc.Location(:,1:2);

    src = (T(1:2,1:2)*src'+T(1:2,4))';
    
    normals = estimate_normals_2d(tgt, 20);%PCA
    
    [R2d, t2d] = icp_point2line_2d(src, tgt, normals, 30);
    
    %2D -> 3D
    src_3d = src_pc.Location;
    R3d = eye(3); R3d(1:2,1:2) = R2d;
    t3d = [t2d; 0];

    T_icp = eye(4);
    T_icp(1:3, 1:3) = R3d;
    T_icp(1:3, 4) = t3d;

    T = T_icp * T ;

    src_3d_homo = [src_3d, ones(size(src_3d,1),1)]';
    aligned_pts = (T * src_3d_homo)';
    aligned_pts = aligned_pts(:,1:3);

    fig = figure(i);
    aligned_pc = pointCloud(aligned_pts);
    pcshowpair(tgt_pc, aligned_pc, 'MarkerSize', 50);
    title(sprintf('ICP aligned accumulated and ply_%d',i));
    saveas(fig, fullfile(output_folder, sprintf('ICP_Aligned_accumulated_image_and_ply_%d.png',i)));

    fullmap = pcmerge(fullmap,aligned_pc,0.01);
    tgt_pc = fullmap;
    robot_tf{i+1} = T;
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

function [R_total, t_total] = icp_point2line_2d(source_pts, target_pts, target_normals, max_iter)
    R_total = eye(2);
    t_total = zeros(2,1);

    for iter = 1:max_iter
        indices = knnsearch(target_pts, source_pts);
        q = target_pts(indices, :);
        n = target_normals(indices, :);

        A = [];
        b = [];

        for i = 1:size(source_pts, 1)
            p = source_pts(i,:)';
            qi = q(i,:)';
            ni = n(i,:)';

            r = p - qi;
            b_i = -ni' * r;
            A_i = [ -p(2)*ni(1) + p(1)*ni(2), ni(1), ni(2) ];

            A = [A; A_i];
            b = [b; b_i];
        end

        xi = pinv(A) * b;
        dtheta = xi(1);
        dt = xi(2:3);

        R_inc = [cos(dtheta), -sin(dtheta); sin(dtheta), cos(dtheta)];
        source_pts = (R_inc * source_pts')' + dt';

        R_total = R_inc * R_total;
        t_total = R_inc * t_total + dt;
    end
end


function normals = estimate_normals_2d(pts, k)
    normals = zeros(size(pts));
    N = size(pts,1);
    centroid = mean(pts);  % mass center

    for i = 1:N
        [idx, ~] = knnsearch(pts, pts(i,:), 'K', k);
        neighbors = pts(idx, :);
        neighbors = neighbors - mean(neighbors);

        [~, ~, V] = svd(neighbors, 'econ');
        n = V(:,2);

        % The direction of it is toward center
        to_center = centroid' - pts(i,:)';
        if dot(n, to_center) < 0
            n = -n;
        end

        normals(i,:) = n';
    end

    normals = normals ./ vecnorm(normals, 2, 2);
end
