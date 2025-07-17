function [v,ea,iter] = IterCos(x,es)
% initialization
iter = 0;
sol = 0;
ea = 100;

iter = single(iter);
sol = single(sol);
ea = single(ea);
es = single(es);

% iterative calculation
while (1)
 solold = sol;
 sol = sol + (x ^ (2*iter)) * ((-1)^(iter)) /factorial(2*iter);
 iter = iter + 1;
 if sol~=0
 ea=abs((sol - solold)/sol)*100;
 end
 if ea<=es,break,end
end
v = sol;
end