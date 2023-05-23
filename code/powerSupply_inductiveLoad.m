function circuit = powerSupply_inductiveLoad(params, h)
% powerSupply_inductiveLoad simulates the power supply circuit under
% an inductive and resistive load. Applies RK4 to solve for the circuit
% parameters e2, iL depending on the biasing of the zener
%
% Inputs:
% circuitParams: a structure containing the necessary parameters of the circuit.
%   The parameters include:
%       N (Transformer turns ratio)
%       C (Capacitance)
%       Rs (Minimum resistance) 
%       RL1 (Resistance of primary load)
%       RL2 (Resistance of secondary load)
%       Rb (Ideal diode bulk resistance)
%       Rz (Zener diode resistance)
%       Vz (Zener diode voltage)
%       L (Inductance of inductor L)
%       V2 (Secondary transformer voltage) 
%       e2 (Node voltage at node (2) through capacitor)
%       e3 (Node voltage at node (3) through zener)
%       iL (Current at node (4)/(5) through inductor).
%
% h: The time step size for the RK4 method, a positive real scalar.
%
% Outputs:
% circuit: A structure containing the calculated circuit parameters at
% the next time step (n+1). 
%
% Author:  Jesse Onolememen
% Version: 1.0.0
% Date:    23/05/2023 
arguments
    params struct {mustBeNonempty, mustBeA(params,'struct')}
    h      (1,1) double {mustBePositive, mustBeNonempty}
end
end