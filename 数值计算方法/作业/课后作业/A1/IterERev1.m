function [v,iter] = IterERev1(n)
% initialization
iter = n + 1;

% iterative calculation
while ( iter > 0 )
 fun = @(x) x.^(iter - 1).*(exp(1).^(-x));
 sol(iter) = integral(@(x) fun(x),0,1);
 iter = iter - 1;
end
v = sol;
end