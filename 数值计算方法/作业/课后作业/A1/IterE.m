function [v,ea,iter] = IterE(es)
% initialization
iter = 0;
sol(1) = 1 - 1/exp(1);
ea = 0.5 * eps;

% iterative calculation
while (1)
 sol(iter+2) = -1/exp(1) + (iter+1)*(sol(iter+1));
 iter = iter + 1;
 ea = (iter+1)*ea + 0.5 * eps;
 if ea>=es,break,end
end
v = sol;
end