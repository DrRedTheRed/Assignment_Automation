clear;
clc;

%initialization

n = 100;
Yin = 0.3;

%for normal ones

for i=1:n
    for j=1:n
        if (j == i-1)
            A(i,j) = 1;
        elseif(j == i)
            A(i,j) = -17/5;
        elseif(j == i+1 )
            A(i,j) = 12/5;
        else A(i,j) = 0;
        end
    end
    if(i == 1)
        b(i) = -Yin;
    else
        b(i) = 0;
    end
end

b = transpose(b);

x1 = naiveGauss(A,b);

%for thomas

for i = 1:n
    if(i == 1)
        a2(i) = 0;
        d2(i) = -Yin;
    else
        a2(i) = 1;
        d2(i) = 0;
    end
    % Subdiagonal
    b2(i) = -17/5;
    % Main diagonal
    if(i == n)
        c2(i) = 0;
    else
        c2(i) = 12/5;
    end
    % Superdiagonal
end


a2 = transpose(a2);
b2 = transpose(b2);
c2 = transpose(c2);
d2 = transpose(d2);

%a2 = [0; 1; 1; 1]; % Subdiagonal
%b2 = [-23/3; -23/3; -23/3; -23/3];   % Main diagonal
%c2 = [20/3; 20/3; 20/3; 0]; % Superdiagonal
%d2 = [-1/2; 0; 0; 0];   % Right-hand side vector

x2 = thomasAlgorithm(a2, b2, c2, d2);

%for GEPP

x3 = gaussianEliminationWithPartialPivoting(A, b);

 %for Jacobi%

% Initial guess for the solution vector
x0 = zeros(size(b));

% Set tolerance and maximum number of iterations
tol = 0.5e-16;
max_iter = 1000;

% Call Jacobi method function
[x4, iter] = jacobi(A, b, x0, tol, max_iter);

 %Jacobi Ends%

%displays%
disp('Solution vector:');
disp(x1);

disp('Y-out');
disp(x1(n));

disp('X-out');
disp(4*x1(1))

disp('Solution vector:');
disp(x2);

disp('Y-out');
disp(x2(n));

disp('X-out');
disp(4*x2(1))

disp('Solution vector:');
disp(x3);

disp('Y-out');
disp(x3(n));

disp('X-out');
disp(4*x3(1))

disp('Solution vector:');
disp(x4);

disp('Y-out');
disp(x4(n));

disp('X-out');
disp(4*x4(1))

disp(['Number of iterations: ', num2str(iter)]);

x5 = A\b;
disp(x5(n));
