function [y] = powerSupply(mode,vin,h,ic,C,Rs)
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
% C:    Capacitance value (Farads). Defaults to 2200nF
% Rs:   Rs resistance value (Ohms). Defaults to 300Ohms
%
% Outputs:
% y:    A structure containing the calculated circuit parameters 
%       at the next time step (n+1). The structure contains:
%       - Id: Current through the diode (A)
%       - Is: Current through the resistor Rs (A)
%       - Ic: Current through the capacitor C (A)
%       - Iz: Current through the zener diode (A)
%       - VL: Voltage at the inductor (V)
%       - VR: Voltage at the resistive branch (V)
%       - VLL: Voltage at the inductive branch (V)
%       - iL2: Current flowing into the secondary load (inductor) (A)
%       - iL1: Current flowing into the primary load (RL1) (A)
%       - e2: The node voltage at node 2 (V)
%       - e3: The node voltage at node 3 (V)
%       - iL: The current flowing through the inductor (A)
%
% Author:  Jesse Onolememen
% Version: 1.0.0
% Date:    13/05/2023 
%
%
arguments
    mode (1,1) CircuitMode {mustBeNonempty}
    vin  (1,3) double {mustBeNonempty}
    h    (1,1) double {mustBePositive, mustBeNonempty}
    ic   (1,3) double {mustBeNonempty}
    C    (1,1) double {mustBeReal} = 2200e-6;
    Rs   (1,1) double {mustBeReal} = 300;
end

% Constant definition
x.N   = [20, 1];  % Transformer turns ratio
x.C   = C;  % Capacitance of capacitor C (F)
x.Rs  = Rs;      % Minimum resistance of Rs (Ohms)
x.RL1 = 287;      % Resistance of primary load (Ohms) 
x.RL2 = 65.7;     % Resistance of secondary load (Ohms)
x.Rb  = 3.2;      % Ideal diode bulk resistance (Ohms)
x.Rz  = 4.85;     % Zener diode resistance (Ohms)
x.Vz  = 6.2;      % Zener diode voltage (V)
x.L   = 105.8e-4; % Inductance of inductor L (H)
x.V2  =  x.N(2)/x.N(1) * abs(vin); % Secondary transformer voltage (V)
x.e2  = ic(1);     % Node voltage at node (2) through capacitor (V)
x.e3  = ic(2);     % Node voltage at node (3) through zener (V)
x.iL  = ic(3);     % Current at node (4)/(5) through inductor (A)
x.Vth = 0.7;      % Threshold voltage of silicion ideal diode (V)


% Switching operation for each mode
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

% Determine the primary currents
% Determine the diode current id(t)
y.Id = ( (x.V2(3) - y.e2)/2 - x.Vth ) / x.Rb;
y.Id = ( y.Id > 0) * y.Id; % Apply unit step function;

% Determine the current in resistor Rs -> is
y.Is = ( y.e2 - x.e3 ) / x.Rs;

% Determine the current through the capacitor ic(t)
y.Ic = y.Id - y.Is;

% Determine the zener current iz(t)
y.Iz = ( y.e3 - x.Vz ) / x.Rz;
y.Iz = ( y.Iz > 0 )*y.Iz; % Apply unit step function

end