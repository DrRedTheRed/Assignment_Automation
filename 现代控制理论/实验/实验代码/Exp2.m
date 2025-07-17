clear
clc

K = 0.1:0.1:1;
T = 0.1:0.1:1;

sys = tf(zeros(1,1,1,length(T)));

s = tf('s');

for i=1:length(T)
    sys(:,:,:,i) = 1+1/(T(i)*s);
end

figure(1)
step(sys)

for i=1:length(K)
    sys(:,:,:,i) = K(i)*(1+1/(T(10)*s));
end

figure(2)
step(sys)