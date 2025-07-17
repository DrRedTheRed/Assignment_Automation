function x = naiveGauss(A, b)
    % Check if the matrix is square
    [m, n] = size(A);
    if m ~= n
        error('Matrix A must be square');
    end
    
    % Check if the number of rows of A matches the number of elements in b
    if n ~= length(b)
        error('Dimensions of A and b are inconsistent');
    end
    
    % Augmented matrix [A|b]
    Ab = [A, b];
    
    % Forward elimination
    for k = 1:n-1
        for i = k+1:n
            factor = Ab(i,k) / Ab(k,k);
            Ab(i,k:n+1) = Ab(i,k:n+1) - factor * Ab(k,k:n+1);
        end
    end
    
    % Back substitution
    x = zeros(n, 1);
    x(n) = Ab(n,n+1) / Ab(n,n);
    for i = n-1:-1:1
        x(i) = (Ab(i,n+1) - Ab(i,i+1:n)*x(i+1:n)) / Ab(i,i);
    end
end
