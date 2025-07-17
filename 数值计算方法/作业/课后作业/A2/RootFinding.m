%clearing script
clear;
clc;

%initialization
y = 1.0;
x = 90;
v0 = 30;
y0 = 1.8;
g = 9.81;

%root finding
f = @(theta) tan(theta).*x - g .* x.^2./(2.*v0.^2.*cos(theta).^2) + y0 - y;

g = @(theta) theta + tan(theta).*x - g .* x.^2./(2.*v0.^2.*cos(theta).^2) + y0 - y;

%for any two-point init. methods.
xl = 0.6;
xu = 0.8;
es = 0.5e-13;
imax = 100;

%for any open methods.
x0 = 0.6;

%bisection method
figure(1);
[theta0(1),iter(1),ea(1)] = Bisection(xl,xu,es,imax,f);

%false position method modified
figure(2);
[theta0(2),iter(2),ea(2)] = ModRegulaFalsi(xl,xu,es,imax,f);

%fixed-point method
figure(3);
[theta0(3),iter(3),ea(3)] = Fixpt(x0,es,imax,g);

%newton_raphson method
figure(4);
[theta0(4),iter(4),ea(4)] = NewtonRaphson(x0,es,imax,f);

%secant method
figure(5);
[theta0(5),iter(5),ea(5)] = SecantMethod(xl,xu,es,imax,f);

disp(theta0);
disp(iter);
disp(ea);
