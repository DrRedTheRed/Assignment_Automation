function x = gaussianEliminationWithPartialPivoting(A, b)
% Gaussian elimination with partial pivoting
% Inputs:
%   A: coefficient matrix
%   b: right-hand side vector
% Output:
%   x: solution vector

% Concatenate A and b to form the augmented matrix
augmentedMatrix = [A, b];

% Size of the augmented matrix
n = size(augmentedMatrix, 1);

% Forward elimination
for k = 1:n-1
    % Partial pivoting
    [~, maxIndex] = max(abs(augmentedMatrix(k:n, k)));
    maxIndex = maxIndex + k - 1;
    if maxIndex ~= k
        % Swap rows k and maxIndex
        augmentedMatrix([k maxIndex], :) = augmentedMatrix([maxIndex k], :);
    end
    
    % Perform elimination
    for i = k+1:n
        factor = augmentedMatrix(i, k) / augmentedMatrix(k, k);
        augmentedMatrix(i, k+1:end) = augmentedMatrix(i, k+1:end) - factor * augmentedMatrix(k, k+1:end);
    end
end

% Back substitution
x = zeros(n, 1);
x(n) = augmentedMatrix(n, n+1) / augmentedMatrix(n, n);
for i = n-1:-1:1
    x(i) = (augmentedMatrix(i, n+1) - augmentedMatrix(i, i+1:n) * x(i+1:n)) / augmentedMatrix(i, i);
end

end
