%Current Integral
clear;
clc;

%initalization on function
i = @(t) (60-t).^2+(60-t).*sin(sqrt(t));

r = @(t) 10.*i(t)+2.*i(t).^(2/3);

u = @(t) i(t).*r(t);

fplot(u,[0 60]);
legend('Voltage');
xlabel('t');
ylabel('u');
title('Function');

u_ave(1) = integral(u,0,60) / 60;

u_ave(2) = multiple_application_trapezoidal_rule(u,0,60,1000000) / 60;

u_ave(3) = multiple_application_simpsons_one_third_rule(u,0,60,1000000) / 60;

u_ave(4) = romberg_integration(u,0,60,18) / 60;

u_ave(5) = gauss_quadrature(u,0,60,1000) / 60;

disp(u_ave)