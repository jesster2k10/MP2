function [y] = powerSupply(mode,vin,h,ic)
% power_supply: Uses the 4th order Runge-Kutta (RK4) method to solve
% the differential equations governing the operation of a power supply circuit.
%
% The function performs one iterative step of the RK4 method, according to the specified
% load conditions (mode). This function is designed to be called repeatedly to simulate 
% the circuit over a period of time.
%
% Inputs:
% mode: The load condition of the circuit, determining how the equations are solved
%       (enum: CircuitMode).
% vin:  A [1x3] real vector containing the input voltages at three points in time:
%       the current time step (n), the midpoint of the current time step (n+1/2), and 
%       the next time step (n+1).
% h:    The time step size for the RK4 method, a positive real scalar.
% ic:   A [1x3] real vector containing the initial conditions for the capacitor voltage (e2),
%       zener voltage (e3), and inductance current (iL)
%
% Outputs:
% circuit: A [1x13] real vector containing the calculated circuit parameters 
%          at the next time step (n+1). 
%
% Author:  Jesse Onolememen
% Version: 1.0.0
% Date:    23/05/2023 
%
%
% 1. Input validation
arguments
    mode (1,1) CircuitMode {mustBeNonempty}
    vin  (1,3) double {mustBeNonempty}
    h    (1,1) double {mustBePositive, mustBeNonempty}
    ic   (1,3) double {mustBeNonempty}
end

% 2. Constant definition
x.N   = [20, 1];  % Transformer turns ratio
x.C   = 2200e-6;  % Capacitance of capacitor C (F)
x.Rs  = 270;      % Minimum resistance of Rs (Ohms)
x.RL1 = 287;      % Resistance of primary load (Ohms) 
x.RL2 = 65.7;     % Resistance of secondary load (Ohms)
x.Rb  = 3.2;      % Ideal diode bulk resistance (Ohms)
x.Rz  = 4.85;     % Zener diode resistance (Ohms)
x.Vz  = 6.2;      % Zener diode voltage (V)
x.L   = 105.8e-4; % Inductance of inductor L (H)
x.V2  =  N(1)/N(2) * abs(vin); % Secondary transformer voltage (V)
x.e2  = ic(1);     % Node voltage at node (2) through capacitor (V)
x.e3  = ic(2);     % Node voltage at node (3) through zener (V)
x.iL  = ic(3);     % Current at node (4)/(5) through inductor (A)
x.Vth = 0.7;      % Threshold voltage of silicion ideal diode (V)

% 3. Switching operation for each mode
switch mode
    case CircuitMode.NoLoad
        y = powerSupply_noLoad(x, h);
    case CircuitMode.FullLoad
        y = powerSupply_fullLoad(x, h);
    case CircuitMode.ResistiveLoad
        y = powerSupply_resistiveLoad(x, h);
    case CircuitMode.InductiveLoad
        y = powerSupply_inductiveLoad(x, h);
    otherwise
        error("Invalid mode passed to powerSupply()")
end

end