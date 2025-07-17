function [xr,iter,ea] = Fixpt(x0,es,imax,g)

%initialization
xrold = x0;
xr = g(xrold);

iter = 0;
ea = 0;

%plotting
fplot(g);
hold on
fplot(@(x)x);

%recurrence iteration
while(1)
    plot([xrold xrold], [xrold xr], 'k-')
    xlim([0,5])
    ylim([0,5])
    plot([xrold xr], [xr xr], 'k--')
    xlim([0,5])
    ylim([0,5])

    xrold = xr;
    xr = g(xrold);
    iter = iter + 1;
    if xr~= 0
        ea = abs((xrold - xr)/xr)*100;
    end
    if ( iter >= imax || ea < es ),break,end
end
%result
end
