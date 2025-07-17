function x = thomasAlgorithm(a, b, c, d)
% Thomas algorithm for solving tridiagonal linear equations
% Inputs:
%   a, b, c: diagonals of the tridiagonal matrix (subdiagonal, main diagonal, superdiagonal)
%   d: right-hand side vector
% Output:
%   x: solution vector

n = length(d);
c_prime = zeros(n, 1);
d_prime = zeros(n, 1);

% Forward elimination
c_prime(1) = c(1) / b(1);
d_prime(1) = d(1) / b(1);
for i = 2:n-1
    c_prime(i) = c(i) / (b(i) - a(i) * c_prime(i - 1));
    d_prime(i) = (d(i) - a(i) * d_prime(i - 1)) / (b(i) - a(i) * c_prime(i - 1));
end
d_prime(n) = (d(n) - a(n) * d_prime(n - 1)) / (b(n) - a(n) * c_prime(n - 1));

% Backward substitution
x = zeros(n, 1);
x(n) = d_prime(n);
for i = n-1:-1:1
    x(i) = d_prime(i) - c_prime(i) * x(i + 1);
end

end
