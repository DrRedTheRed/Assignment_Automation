clear;
clc;

% Define matrix
H = [0,1,0,0,1,0;1,0,1,0,0,0;0,1,0,1,0,0;0,0,1,0,1,0;1,0,0,1,0,1;0,0,0,0,1,0];

% Call the lanczos method function
[e1,v1] = lanczos(H, 6);

disp(e1)
disp(v1)

function [eigenvalues, eigenvectors] = lanczos(A, k)
    n = size(A, 1);
    Q = zeros(n, k);
    alpha = zeros(k, 1);
    beta = zeros(k - 1, 1);
    r0 = rand(n, 1);  % Initial random vector
    r0 = r0 / norm(r0);  % Normalize the initial vector
    
    Q(:, 1) = r0;
    
    for j = 1:k
        if j == 1
            v = A * Q(:, j);
        else
            v = A * Q(:, j) - beta(j - 1) * Q(:, j - 1);
        end
        
        alpha(j) = Q(:, j)' * v;
        v = v - alpha(j) * Q(:, j);
        
        if j < k
            beta(j) = norm(v);
            Q(:, j + 1) = v / beta(j);
        end
    end
    
    % Solve the tridiagonal eigenvalue problem
    [T, D] = eig(diag(alpha) + diag(beta, 1) + diag(beta, -1));
    
    % Eigenvalues
    eigenvalues = diag(D);
    
    % Eigenvectors
    eigenvectors = Q * T;
end