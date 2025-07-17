clear;
clc;

x = [0,8,16,24,32,40];
y = [14.621,11.843,9.870,8.418,7.305,6.413];

x_val = 0:0.1:40;

figure(1);
lagrange_interp(x, y, x_val);

figure(2);
spline(x,y,x_val);

figure(3);
Polyfit(x,y,x_val);
