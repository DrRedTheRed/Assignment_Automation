function result = multiple_application_simpsons_one_third_rule(f, a, b, n)

    h = (b - a) / n;


    result = 0;

    for i = 1:2:n-1
        % Calculate the endpoints of the current pair of segments
        x0 = a + (i - 1) * h;
        x1 = a + i * h;
        x2 = a + (i + 1) * h;

        % Apply Simpson's 1/3 Rule to the current pair of segments
        result = result + (h / 3) * (f(x0) + 4*f(x1) + f(x2));
    end

    % Adjust the result for odd number of segments
    if mod(n, 2) == 1
        % If the number of segments is even, apply Simpson's 1/3 Rule to
        % the last segment separately
        x0 = a + (n - 1) * h;
        x1 = a + (n - 0.5) * h;
        x2 = a + n * h;
        result = result + ((h/2) / 3) * (f(x0) + 4*f(x1) + f(x2));
    end
end
