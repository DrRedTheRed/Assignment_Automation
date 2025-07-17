function y_output = piecewiselinearinterp(x,y,x_input)
n = length(x);
nn = length(x_input);
 
for j=1:nn
    for i=1:n-1
        if (x_input(j)>x(i) && x_input(j)<=x(i+1))
            y_output(j) = ((x_input(j)-x(i+1))/(x(i)-x(i+1)))*y(i)+(((x_input(j)-x(i))/(x(i+1)-x(i)))*y(i+1));
        end
    end
end

plot(x,y);

end