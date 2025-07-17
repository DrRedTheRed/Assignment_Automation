clear;
clc;

% Define the function
fun = @(E) E.^6 - 6*E.^4 + 8*E.^2 - 2*E - 1;

f = 0;

% Generate a range of values for E
E = linspace(-2, 2.3, 1000);

% Evaluate the function
y = fun(E);

% Plot the function
figure;
plot(E, y, 'LineWidth', 1.5);
legend('function')
legend('0')

hold on
fplot(f)
xlabel('E');
ylabel('f(E)');
title('Plot of f(E) = E^6 - 6E^4 + 8E^2 - 2E - 1');

% Find roots numerically using fzero
roots = zeros(1,6);

section = [-2.5,-1.8,-1,0,0.8,1.8,2.2];

for i = 1:1:6
    [roots(i),Iter,ea] = SecantMethod(section(i),section(i+1),0.5e-5,1000,fun);
end

% Display the roots
disp('Roots:');
disp(roots);
