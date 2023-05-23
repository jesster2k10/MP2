function [circuit] = power_supply(mode,vin,h,ic)
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
% ic:   A [1x3] real vector containing the initial conditions for the capacitor voltage,
%       inductance, and the node voltage (e3) of the node housing the zener.
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
    mode (1,1) CircuitMode
    v    (1,3) double
    h    (1,1) double
    ic   (1,3) double
end

% 2. Constant definition
N   = [20, 1];  % Transformer turns ratio
C   = 2200e-6;  % Capacitance of capacitor C (F)
Rs  = 270;      % Minimum resistance of Rs (Ohms)
RL1 = 287;      % Resistance of primary load (Ohms) 
RL2 = 65.7;     % Resistance of secondary load (Ohms)
Rb  = 3.2;      % Ideal diode bulk resistance (Ohms)
Rz  = 4.85;     % Zener diode resistance (Ohms)
Vz  = 6.2;      % Zener diode voltage (V)
L   = 105.8e-4; % Inductance of inductor L (H)
V2 =  N(1)/N(2) * abs(vin); % Secondary transformer voltage (V)

% 3. Switching operation for each mode

end


