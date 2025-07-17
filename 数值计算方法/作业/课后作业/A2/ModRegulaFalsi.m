function [x0,iter,ea] = ModRegulaFalsi(xl,xu,es,imax,f)
    iter = 0;
    fl = f(xl);
    fu = f(xu);
    xr = xl;
    iu = 0;
    il = 0;
    
    plot([xl,xu],[fl,fu],"-o");
    hold on;

    while(1)
        xrold = xr;
        xr = xu - fu*(xl - xu)/(fl - fu);
        fr = f(xr);

        iter = iter + 1;
        if xr ~= 0
            ea = abs((xr - xrold)/ xr) * 100;
        end

        flag  = fl * fr;
        if flag < 0 
            xu = xr;
            fu = f(xu);
            iu = 0;
            il = il +1;
            if il >= 2
                fl = fl / 2;
            end
        elseif flag > 0
            xl = xr;
            fl = f(xl);
            il = 0;
            iu = iu + 1;
            if iu >= 2
                fu = fu / 2;
            end
        else
            ea = 0;
        end

        plot([xl,xu],[fl,fu],"-o");
        
        if ea < es || iter >= imax, break, end
    end
    fplot(f,[0.6,0.8]);
    x0 = xr;
end