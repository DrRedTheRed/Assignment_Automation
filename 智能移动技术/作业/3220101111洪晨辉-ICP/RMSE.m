load('robot_tf_true_a.mat','T')
robot_tf_true = T;

load('robot_tf_r2l.mat','robot_tf')

N = min(length(robot_tf), length(robot_tf_true));

est_positions = zeros(N, 3);
true_positions = zeros(N, 3);

for i = 1:N
    est_positions(i, :) = robot_tf{i}(1:3, 4)';
    true_positions(i, :) = robot_tf_true{i}(1:3, 4)';
end

errors = est_positions - true_positions;

dists = vecnorm(errors, 2, 2);

rmse = sqrt(mean(dists.^2));
max_error = max(dists);

fprintf('RMSE between estimated and true positions: %.4f meters\n', rmse);
fprintf('Maximum position error: %.4f meters\n', max_error);
