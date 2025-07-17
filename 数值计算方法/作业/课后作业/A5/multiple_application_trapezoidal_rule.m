function result = multiple_application_trapezoidal_rule(f, a, b, n)
    
    h = (b - a) / n;
    
    result = 0;
    
    for i = 1:n
        % Calculate the endpoints of the current segment
        x0 = a + (i - 1) * h;
        x1 = a + i * h;
        
        % Apply trapezoidal rule to the current segment
        result = result + (f(x0) + f(x1)) / 2 * (x1 - x0);
    end
    
end
