function [root, iterations, ea] = SecantMethod(x0, x1, tolerance, max_iterations, func)
    syms x; % Declare symbolic variable for the function
    
    % Convert the input function string to a MATLAB function handle
    f = matlabFunction(sym(func));
    
    % Initial values
    x_prev = x0;
    x_curr = x1;
    iterations = 0;
    ea = 100;

    while true
        iterations = iterations + 1;
        
        % Secant method formula
        x_next = x_curr - f(x_curr) * (x_curr - x_prev) / (f(x_curr) - f(x_prev));
        
        if ea ~= 0
            ea = abs((x_next - x_curr)/x_next)*100;
        end

        % Check for convergence
        if ea < tolerance || iterations >= max_iterations
            root = x_next;
            break;
        end
        
        plot([x_prev,x_curr],[f(x_prev),f(x_curr)],"--o");
        hold on
        plot(x_next,0,"-o");
        if iterations <= 6
            text(x_next+0.001,0.001,num2str(iterations));
        end

        x_prev = x_curr;
        x_curr = x_next;
    end

    fplot(f,[0.6,0.8]);
    ylim([-10,4]);
    
    legend off
end