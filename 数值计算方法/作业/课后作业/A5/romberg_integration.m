function I = romberg_integration(f, a, b, n)

    % Initialize the Romberg table
    R = zeros(n, n);
    
    % Compute the first column of the table using trapezoidal rule
    h = (b - a);
    R(1, 1) = h/2 * (f(a) + f(b));
    
    for i = 2:n
        % Compute the integral using the trapezoidal rule with 2^(i-1) intervals
        h = h / 2;
        sum_f = 0;
        for k = 1:(2^(i-2))
            sum_f = sum_f + f(a + (2*k - 1)*h);
        end
        R(i, 1) = 0.5 * R(i-1, 1) + h * sum_f;
        
        % Extrapolate to higher orders of accuracy
        for j = 2:i
            R(i, j) = R(i, j-1) + (R(i, j-1) - R(i-1, j-1)) / ((4^(j-1)) - 1);
        end
    end
    
    % The final result is in the last row and last column of the table
    I = R(n, n);
end
