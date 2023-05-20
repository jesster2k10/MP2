% Define the constants
a = sym('a');
b = sym('b');
x = sym('x');

% Define the system of equations
eqns = [a*(-x)*N + M == b, a*x*M + N == 0];

% Solve the system of equations
sol = solve(eqns, [M, N]);

% Get A from N
A = -sol.N;

% Display the results
disp(['A = ', char(A)]);
disp(['M = ', char(sol.M)]);
disp(['N = ', char(sol.N)]);