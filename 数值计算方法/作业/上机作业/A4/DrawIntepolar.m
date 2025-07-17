clear;
clc;

f = @(x) x ./ (1 + x .^ 4);

%init

n = 10;

for i = 1:(n+1)
    x(i) = -5 + (10 * (i-1) / n);
end

y = f(x);

x_val = -5:0.1:5;

hold on
lagrange_interp(x, y, x_val);
fplot(f);
piecewiselinearinterp(x,y,x_val);
title('Lagrange Interpolating Polynomial(n=10)');
legend('Data Points', 'Interpolated Polynomial', 'x/(1+x^4)','piecewise');
