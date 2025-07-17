function [root, iterations, ea] = NewtonRaphson( initial_guess, tolerance, max_iterations, func )
    syms x; % Declare symbolic variable for the function
    
    % Convert the input function string to a MATLAB function handle
    f = matlabFunction(sym(func));
    df = matlabFunction(diff(sym(func))); % Derivative of the function
    
    root = initial_guess;
    iterations = 0;
    ea = 100;
    
    while true
        iterations = iterations + 1;
        
        % Newton-Raphson iteration formula
        root_new = root - f(root) / df(root);

        if ea ~= 0 
            ea = abs((root_new-root)/root_new)*100;
        end

        % Check for convergence
        if ea < tolerance || iterations >= max_iterations
            root = root_new;
            break;
        end
        
        plot([root,root_new],[f(root),0],"-o");
        hold on

        root = root_new;
    end

    fplot(f,[0.5,1]);
    ylim([-5,5]);

end