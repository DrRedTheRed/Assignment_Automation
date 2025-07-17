function I = gauss_quadrature(f, a, b, n)
    % Define the Gauss quadrature points and weights
    [nodes, weights] = gauss_points_weights(n);
    
    % Map nodes from [-1, 1] to [a, b]
    nodes = ((b - a) * nodes + (b + a)) / 2;
    
    % Perform the quadrature sum
    I = weights * f(nodes) * (b - a) / 2;
end

function [nodes, weights] = gauss_points_weights(n)
    % Compute the Gauss quadrature points and weights for n points
    
    % Precompute constants for recurrence relation
    k = 1:n-1;
    a = 1 ./ sqrt(4-1./(k.^2) );
    
    % Compute eigenvalues of the tridiagonal matrix
    A = diag(a, 1) + diag(a, -1);
    [V, D] = eig(A);
    
    % Gauss nodes are the eigenvalues
    nodes = diag(D);
    
    % Gauss weights are proportional to the squares of the elements of the
    % first row of the eigenvector matrix
    weights = 2 * V(1, :).^2;
end
