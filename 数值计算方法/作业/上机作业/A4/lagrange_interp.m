function lagrange_interp(x, y, x_val)
    n = length(x);
    L = ones(n,length(x_val));
    
    for i = 1:n
        for j = 1:n
            if i ~= j
                L(i,:) = L(i,:) .* (x_val - x(j)) / (x(i) - x(j));
            end
        end
    end
    
    interpolated_y = zeros(1,length(x_val));
    for i = 1:n
        interpolated_y = interpolated_y + y(i) * L(i,:);
    end
    
    disp('Interpolated values:');
    disp(interpolated_y);
    
    % Plot the interpolated polynomial
    plot(x, y, 'o', x_val, interpolated_y);
    xlabel('x');
    ylabel('y');
end
