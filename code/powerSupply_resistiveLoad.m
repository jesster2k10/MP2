function y = powerSupply_resistiveLoad(x, h)
% powerSupply_noLoad simulates the power supply circuit under a resistive load.
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
% Date:    13/05/2023 
arguments
    x struct {mustBeNonempty, mustBeA(x,'struct')}
    h (1,1) double {mustBePositive, mustBeNonempty}
end

% Common parameters
RL1_Rs = x.RL1 + x.Rs;
RL1Rz  = x.RL1 * x.Rz;
RL1_Rz = x.RL1 + x.Rz;
RL1Vz  = x.RL1 * x.Vz;

% Perform RK4 depending on the biasing of the zener
% When e3 >= Vz the zener is in forward bias:
if (x.e3 < x.Vz)
    id = ((x.V2(1) - x.e2)/2 - x.Vth) / x.Rb;
    k1 = h/x.C*((id>=0)*id - x.e2/RL1_Rs);
    id = ((x.V2(2) - x.e2 - k1/2)/2 - x.Vth) / x.Rb;
    k2 = h/x.C*((id>=0)*id - (x.e2+k1/2)/RL1_Rs);
    id = ((x.V2(2)- x.e2 - k2/2)/2 - x.Vth) / x.Rb;
    k3 = h/x.C*((id>=0)*id - (x.e2+k2/2)/RL1_Rs);
    id = ((x.V2(3)- x.e2-k3)/2 - x.Vth) / x.Rb;
    k4 = h/x.C*((id>=0)*id - (x.e2+k3)/RL1_Rs);
else
    Req = RL1Rz + Rs* RL1_Rz;
    id = ((x.V2(1) - x.e2)/2 - x.Vth) / x.Rb;
    k1 = h/x.C*((id>=0)*id - (x.e2*RL1_Rz-RL1Vz)/Req);
    id = ((x.V2(2) - x.e2 - k1/2)/2 - x.Vth) / x.Rb;
    k2 = h/x.C*((id>=0)*id - ((x.e2+k1/2)*RL1_Rz-RL1Vz)/Req);
    id = ((x.V2(2)- x.e2 - k2/2)/2 - x.Vth) / x.Rb;
    k3 = h/x.C*((id>=0)*id - ((x.e2+k2/2)*RL1_Rz-RL1Vz)/Req);
    id = ((x.V2(3)- x.e2-k3)/2 - x.Vth) / x.Rb;
    k4 = h/x.C*((id>=0)*id - ((x.e2+k3)*RL1_Rz-RL1Vz)/Req);
end

% Apply RK4 to determine e2
y.e2 = x.e2 + (k1+2*k2+2*k3+k4)/6;

% Determine outvoltage e3 depending on biasing of zener
y.e3 = x.RL1 * y.e2 / ( RL1_Rs );
if (y.e3 >= x.Vz) % Forward bias e3 is given by another expression
    y.e3 = (RL1Rz * y.e2 + x.RL1*x.Rs*y.e2) / (x.RL1*x.Rs + x.Rz*x.Rs + RL1Rz);
end

% Determine remaning parameters
y.VL  = -x.L * x.IL/h; % Voltage at the inductor
y.VR  = y.e3; % Voltage at the resistive branch
y.VLL = y.VL; % Voltage at the inductive branch
y.iL2 = 0; % No current flows into the secondary load (indudctor)
y.iL1 = y.e3 / x.RL1; % Current flowing into the primary load (287 Ohms)

end