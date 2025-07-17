function spline(x,y,x_val)

% Perform cubic spline interpolation
y_interp = interp1(x, y, x_val, 'spline');

% Plot original data and interpolated curve
plot(x, y, 'o', x_val, y_interp, '-');
legend('Original Data', 'Interpolated Curve');
xlabel('x');
ylabel('y');
title('Cubic Spline Interpolation');
hold on
plot(x_val(271),y_interp(271),'o');

disp("Exact:");
disp(y_interp(271));
