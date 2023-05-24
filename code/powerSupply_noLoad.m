function y = powerSupply_noLoad(x, h)
% powerSupply_noLoad simulates the power supply circuit under no-load conditions.
% Applies RK4 to solve for e2 depending on the biasing of the zener.
%
% Inputs:
% x: a structure containing the necessary parameters of the circuit.
%   The parameters include:
%       N (Transformer turns ratio)
%       C (Capacitance)
%       Rs (Minimum resistance) 
%       RL1 (Resistance of primary load)
%       RL2 (Resistance of secondary load)
%       Rb (Ideal diode bulk resistance)
%       Rz (Zener diode resistance)
%       Vz (Zener diode voltage)
%       Vth (Ideal diode threshold voltage)
%       L (Inductance of inductor L)
%       V2 (Secondary transformer voltage) 
%       e2 (Node voltage at node (2) through capacitor)
%       e3 (Node voltage at node (3) through zener)
%       iL (Current at node (4)/(5) through inductor).
%
% h: The time step size for the RK4 method, a positive real scalar.
%
% Outputs:
% y: A structure containing the calculated circuit parameters at
% the next time step (n+1). 
%
% Author:  Jesse Onolememen
% Version: 1.0.0
% Date:    23/05/2023 
arguments
    x struct {mustBeNonempty, mustBeA(x,'struct')}
    h (1,1) double {mustBePositive, mustBeNonempty}
end

% Perform RK4 depending on the biasing of the zener
% When e3 >= Vz the zener is in forward bias:
if (x.e3 < x.Vz)
    id = ((x.V2(1) - x.e2)/2 - x.Vth) / x.Rb;
    k1 = h/x.C*((id>=0)*id);
    id = ((x.V2(2) - x.e2 - k1/2)/2 - x.Vth) / x.Rb;
    k2 = h/x.C*((id>=0)*id);
    id = ((x.V2(2)- x.e2 - k2/2)/2 - x.Vth) / x.Rb;
    k3 = h/x.C*((id>=0)*id);
    id = ((x.V2(3)- x.e2-k3)/2 - x.Vth) / x.Rb;
    k4 = h/x.C*((id>=0)*id);
else
    Req = x.Rz+x.Rs;
    id = ((x.V2(1) - x.e2)/2 - x.Vth) / x.Rb;
    k1 = h/x.C*((id>=0)*id - (x.e2-x.Vz)/(Req));
    id = ((x.V2(2) - x.e2 - k1/2)/2 - x.Vth) / x.Rb;
    k2 = h/x.C*((id>=0)*id - (x.e2+k1/2-x.Vz)/(Req));
    id = ((x.V2(2)- x.e2 - k2/2)/2 - x.Vth) / x.Rb;
    k3 = h/x.C*((id>=0)*id - (x.e2+k2/2-x.Vz)/(Req));
    id = ((x.V2(3)- x.e2-k3)/2 - x.Vth) / x.Rb;
    k4 = h/x.C*((id>=0)*id - (x.e2+k3-x.Vz)/(Req));
end

% Apply RK4 to determine e2
y.e2 = x.e2 + (k1+2*k2+2*k3+k4)/6;

% Determine outvoltage e3 depending on biasing of zener
if (y.e2 >= x.Vz)
    y.e3 = (y.e2 * x.Rz + x.Vz * x.Rs)/(x.Rs + x.Rz);
else
    y.e3 = y.e2;
end

% Determine remaining circuit parameters
y.VL  = -x.L * x.iL/h; % Voltage at the inductor
y.VR  = 0; % No voltage at the resistive branch;
y.VLL = y.VL; % Voltage at the inductive branch
y.iL2 = 0; % No current flows into the secondary load (indudctor)
y.iL1 = 0; % No current flows into the primary load
y.iL = 0;

end