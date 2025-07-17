function [v,ea,iter] = IterMeth4(x,es)
% initialization
iter = 1;
sol = 0;
ea = 100;
% iterative calculation
while (1)
 solold = sol;
 sol = sol + (x ^ (2 * iter-1)) * 2 / (2 * iter-1);
 iter = iter + 1;
 if sol~=0
 ea=abs((sol - solold)/sol)*100;
 end
 if ea<=es,break,end
end
v = sol;
end