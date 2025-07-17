clear;
clc;

H = tf([32 98],[1 4 16 0]);
bode(H);