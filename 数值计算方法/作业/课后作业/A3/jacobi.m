function [x, iter] = jacobi(A, b, x0, tol, max_iter)
% Inputs:
%   A: Coefficient matrix of the system of equations
%   b: Right-hand side vector of the system of equations
%   x0: Initial guess for the solution vector
%   tol: Tolerance for convergence
%   max_iter: Maximum number of iterations allowed
% Outputs:
%   x: Solution vector
%   iter: Number of iterations taken for convergence

% Get the size of the system
n = size(A, 1);

% Initialize iteration counter
iter = 0;

% Initialize solution vector
x = x0;

% Main loop for Jacobi iteration
while iter < max_iter
    % Increment iteration counter
    iter = iter + 1;
    
    % Create a copy of the solution vector from the previous iteration
    x_old = x;
    
    % Perform one iteration of Jacobi method
    for i = 1:n
        % Calculate the ith component of the solution vector
        sigma = 0;
        for j = 1:n
            if j ~= i
                sigma = sigma + A(i, j) * x_old(j);
            end
        end
        x(i) = (b(i) - sigma) / A(i, i);
    end
    
    % Check for convergence
    if norm(x - x_old, inf) < tol
        break;
    end
end

end
