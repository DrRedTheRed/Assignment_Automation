function [x0,iter,ea] = Bisection(xl,xu,es,imax,f)

    iter = 0;
    fl = f(xl);
    xr = xl;

    while(1)
        xr = (xl+xu) / 2;
        fr = f(xr);
        iter = iter + 1;
        
        flag = fl*fr;
        if flag < 0
            xu = xr;
        elseif flag > 0
            xl = xr;
            fl = fr;
        else
            ea = 0;
        end
        
        if xr ~= 0 
            ea = abs((xu-xl)/(xu+xl))*100;
        end

        X1(iter) = xl;
        X2(iter) = xu;
        Y(iter) = ea;

        if ea < es || iter >= imax, break,end
    end

    x0 = xr;

    for i = 1:iter
        plot([X1(i),X2(i)],[Y(i),Y(i)],"-o");
        hold on;
    end
    
end