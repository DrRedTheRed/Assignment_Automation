function [v,ea,iter] = IterMeth3(x,es)
% initialization
iter = 1;
sol = 0;
ea = 100;
% iterative calculation
while (1)
 solold = sol;
 sol = sol + (x ^ iter) * ((-1)^(iter+1)) /iter;
 iter = iter + 1;
 if sol~=0
 ea=abs((sol - solold)/sol)*100;
 end
 if ea<=es,break,end
end
v = sol;
end