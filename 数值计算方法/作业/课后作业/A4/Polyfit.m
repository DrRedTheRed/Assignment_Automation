function Polyfit(x,y,x_val)

% Degree of the polynomial
degree = 2;

% Perform polynomial regression
coefficients = polyfit(x, y, degree);

% Generate polynomial values
y_predicted = polyval(coefficients, x_val);

% Plot the data and polynomial regression curve
plot(x, y, 'o', x_val, y_predicted, '-');
xlabel('x');
ylabel('y');
title('Polynomial Regression');
legend('Data', 'Polynomial Regression Curve');

hold on
plot(x_val(271),y_predicted(271),'o');

disp("Exact:");
disp(y_predicted(271));

