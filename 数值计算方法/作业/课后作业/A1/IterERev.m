function [v,iter] = IterERev(n)
% initialization
iter = n + 1;

fun = @(x) x.^(n).*(exp(1).^(-x));
sol(iter) = integral(@(x) fun(x),0,1);

% iterative calculation
while ( iter - 1 > 0 )
 sol(iter - 1) = ((1.0/exp(1)) + sol(iter))/ (iter - 1) ;
 iter = iter - 1;
end
v = sol;
end