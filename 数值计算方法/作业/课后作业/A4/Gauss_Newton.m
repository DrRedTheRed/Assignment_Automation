clear;
clc;

x = [0,8,16,24,32,40];
y = [14.621,11.843,9.870,8.418,7.305,6.413];

% Plot the sample data
figure;
scatter(x, y);
hold on;

% Gauss-Newton Method
beta0 = [14; -0.1]; % Initial guess for parameters
beta = beta0;
max_iters = 100; % Maximum number of iterations
tol = 1e-6; % Tolerance for convergence

for iter = 1:max_iters
    % Calculate the Jacobian matrix
    J = zeros(length(x), length(beta));
    for i = 1:length(x)
        J(i, 1) = exp(beta(2) * x(i)); % Partial derivative w.r.t. beta(1)
        J(i, 2) = beta(1) * x(i) * exp(beta(2) * x(i)); % Partial derivative w.r.t. beta(2)
    end
    
    % Calculate the residuals
    residuals = y - model(x, beta);
    
    % Compute the step
    step = (J' * J) \ (J' * residuals');
    
    % Update the parameters
    beta = beta + step;
    
    % Check for convergence
    if norm(step) < tol
        break;
    end
end

% Plot the fitted curve
f = @(x) beta(1) * exp(beta(2) * x);
fplot(f);
plot(27,f(27),'o');
legend('Data', 'Fitted Curve');
xlabel('x');
ylabel('y');
title('Nonlinear Regression using Gauss-Newton Method');

% Define your nonlinear model function
function y = model(x, beta)
    % Example: y = beta(1) * exp(beta(2) * x)
    y = beta(1) * exp(beta(2) * x);
end
