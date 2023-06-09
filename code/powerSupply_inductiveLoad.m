function y = powerSupply_inductiveLoad(x, h)
% powerSupply_noLoad simulates the power supply circuit under an inductive
% and resistive load. Applies RK4 to solve for e2, iL depending on the
% biasing of the zener.
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
Rs_Rz = x.Rs + x.Rz;

% Perform RK4 depending on the biasing of the zener
% When e3 < Vz the zener is in cut off
if (x.e3 < x.Vz)  
    id = ((x.V2(1) - x.e2)/2 - x.Vth) / x.Rb;
    k1 = [h/x.C * ((id>=0)*id - x.iL);
          h/x.L * ( x.e2 - ( x.Rs+x.RL2 ) * x.iL )];

    id = ((x.V2(2) - x.e2 - k1(1)/2)/2 - x.Vth) / x.Rb;
    k2 = [h/x.C * ((id>=0)*id - (x.iL + k1(2)/2));
          h/x.L * ( (x.e2 + k1(1)/2) - ( x.Rs+x.RL2 ) * (x.iL + k1(2)/2) )];

    id = ((x.V2(2)- x.e2 - k2(1)/2)/2 - x.Vth) / x.Rb;
    k3 = [h/x.C * ((id>=0)*id - (x.iL + k2(2)/2));
          h/x.L * ( (x.e2 + k2(1)/2) - ( x.Rs+x.RL2 ) * (x.iL + k2(2)/2) )];

    id = ((x.V2(3)- x.e2 - k3(1)/2) - x.Vth) / x.Rb;
    k4 = [h/x.C * ((id>=0)*id - (x.iL + k3(2)/2));
          h/x.L * ( (x.e2 + k3(1)/2) - ( x.Rs+x.RL2 ) * (x.iL + k3(2)/2) )];
else
    id = ((x.V2(1) - x.e2)/2 - x.Vth) / x.Rb;
    k1 = [h/x.C * ((id>=0)*id - ( x.e2 - x.Vz + (x.Rz * x.iL) ) / Rs_Rz);
           h/x.L * ( ( x.e2 * x.Rz + x.Rs*x.Rz - x.Rz*x.Rz*x.iL / Rs_Rz ) - x.RL2 * x.iL )];

    id = ((x.V2(2) - x.e2 - k1(1)/2)/2 - x.Vth) / x.Rb;
    k2 = [h/x.C * ((id>=0)*id - ( (x.e2 + k1(1)/2) - x.Vz + (x.Rz * (x.iL + k1(2)/2)) ) / Rs_Rz);
           h/x.L * ( ( (x.e2 + k1(1)/2) * x.Rz + x.Rs*x.Rz - x.Rz*x.Rz*(x.iL + k1(2)/2) / Rs_Rz ) - x.RL2 * (x.iL + k1(2)/2) )];

    id = ((x.V2(2)- x.e2 - k2(1)/2)/2 - x.Vth) / x.Rb;
    k3 = [h/x.C * ((id>=0)*id - ( (x.e2 + k2(1)/2) - x.Vz + (x.Rz * (x.iL + k2(2)/2)) ) / Rs_Rz);
           h/x.L * ( ( (x.e2 + k2(1)/2) * x.Rz + x.Rs*x.Rz - x.Rz*x.Rz*(x.iL + k2(2)/2) / Rs_Rz ) - x.RL2 * (x.iL + k2(2)/2) )];

    id = ((x.V2(3)- x.e2 - k3(1)/2) - x.Vth) / x.Rb;
    k4 = [h/x.C * ((id>=0)*id - ( (x.e2 + k3(1)/2) - x.Vz + (x.Rz * (x.iL + k3(2)/2)) ) / Rs_Rz);
           h/x.L * ( ( (x.e2 + k3(1)/2) * x.Rz + x.Rs*x.Rz - x.Rz*x.Rz*(x.iL + k3(2)/2) / Rs_Rz ) - x.RL2 * (x.iL + k3(2)/2) )];
end

% Apply RK4 to determine e2 and iL
y.e2 = x.e2 + (k1(1)+2*k2(1)+2*k3(1)+k4(1))/6;
y.iL = x.iL + (k1(2)+2*k2(2)+2*k3(2)+k4(2))/6;

% Determine output votlage e_3 based on zener biasing
% y.e3 = (y.e2 - x.Vz + x.Rz*y.iL)/Rs_Rz;
y.e3 = y.e2 - x.Rs*y.iL;
if (y.e3 >= x.Vz) % Reverse breakdown e3 is given by another expression
    y.e3 = ( y.e2*x.Rz + x.Vz*x.Rs - y.iL*x.Rs*x.Rz ) / Rs_Rz;
end

% Determine remaining circuit parameters
y.VL  = y.e3 - x.RL2*y.iL; % Voltage at the inductor
y.VR  = 0; % Voltage at the resistive branch
y.VLL = y.e3; % Voltage at the inductive branch
y.iL2 = y.iL; % No current flows into the secondary load (indudctor)
y.iL1 = 0; % Current flowing into the primary load (287 Ohms)

end