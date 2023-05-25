function y = powerSupply_fullLoad(x, h)
% powerSupply_noLoad simulates the power supply circuit under full load conditions.
% Applies RK4 to solve for e2, iL depending on the biasing of the zener.
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

% Define common parameters
RL1_Rs = x.Rs + x.RL1;
Rd = x.Rs*x.Rz + x.Rz*x.RL1 + x.Rs*x.RL1; % common denominator;

% Perform RK4 depending on the biasing of the zener
% When e3 < Vz the zener is in cut off
if (x.e3 < x.Vz)       
    id = ((x.V2(1) - x.e2)/2 - x.Vth) / x.Rb;
    k1 = [h/x.C * ((id>=0)*id - ((x.e2 - x.Rs*x.iL) / RL1_Rs) - x.iL);
          h/x.L * ( ( x.e2*x.RL1 - x.iL*( x.Rs*(x.RL1 + x.RL2) + x.RL1*x.RL2 ) ) / RL1_Rs ) ];

    id = ((x.V2(2) - x.e2 - k1(1)/2)/2 - x.Vth) / x.Rb;
    k2 = [h/x.C * ((id>=0)*id - (((x.e2 + k1(1)/2) - x.Rs*(x.iL + k1(2)/2)) / RL1_Rs) - (x.iL + k1(2)/2));
          h/x.L * ( ( (x.e2 + k1(1)/2)*x.RL1 - (x.iL + k1(2)/2)*( x.Rs*(x.RL1 + x.RL2) + x.RL1*x.RL2 ) ) / RL1_Rs ) ];

    id = ((x.V2(2)- x.e2 - k2(1)/2)/2 - x.Vth) / x.Rb;
    k3 = [h/x.C * ((id>=0)*id - (((x.e2 + k2(1)/2) - x.Rs*(x.iL + k2(2)/2)) / RL1_Rs) - (x.iL + k2(2)/2));
          h/x.L * ( ((x.e2 + k2(1)/2)*x.RL1 - (x.iL + k2(2)/2)*( x.Rs*(x.RL1 + x.RL2) + x.RL1*x.RL2 ) ) / RL1_Rs ) ];

    id = ((x.V2(3)- x.e2-k3(1))/2 - x.Vth) / x.Rb;
    k4 = [h/x.C * ((id>=0)*id - (((x.e2 + k3(1)) - x.Rs*(x.iL + k3(2))) / RL1_Rs) - (x.iL + k3(2)));
          h/x.L * ( ( (x.e2 + k3(1))*x.RL1 - (x.iL + k3(2))*( x.Rs*(x.RL1 + x.RL2) + x.RL1*x.RL2 ) ) / RL1_Rs ) ];
else
    id = ((x.V2(1) - x.e2)/2 - x.Vth) / x.Rb;
    k1 = [h/x.C * ( (id>=0)*id - ( x.e2 * (x.Rz*x.RL1) - x.Vz*x.RL1 + x.iL*x.Rz*x.RL1 )/Rd );
          h/x.L * ( ( (x.e2*x.Rz*x.RL1 + x.Vz*x.RL1*x.Rs + x.iL*x.Rs*x.Rz) / Rd ) - x.RL2*x.iL )];

    id = ((x.V2(2) - x.e2 - k1(1)/2)/2 - x.Vth) / x.Rb;
    k2 = [h/x.C * ( (id>=0)*id - ( (x.e2 + k1(1)/2) * (x.Rz*x.RL1) - x.Vz*x.RL1 + (x.iL + k1(2)/2)*x.Rz*x.RL1 )/Rd );
          h/x.L * ( ( ((x.e2 + k1(1)/2)*x.Rz*x.RL1 + x.Vz*x.RL1*x.Rs + (x.iL + k1(2)/2)*x.Rs*x.Rz) / Rd ) - x.RL2*x.iL )];

    id = ((x.V2(2)- x.e2 - k2(1)/2)/2 - x.Vth) / x.Rb;
    k3 = [h/x.C * ( (id>=0)*id - ( (x.e2 + k2(1)/2) * (x.Rz*x.RL1) - x.Vz*x.RL1 + (x.iL + k2(2)/2)*x.Rz*x.RL1 )/Rd );
          h/x.L * ( ( ((x.e2 + k2(1)/2)*x.Rz*x.RL1 + x.Vz*x.RL1*x.Rs + (x.iL + k2(2)/2)*x.Rs*x.Rz) / Rd ) - x.RL2*(x.iL + k2(2)/2) )];

    id = ((x.V2(3)- x.e2-k3(1))/2 - x.Vth) / x.Rb;
    k4 = [h/x.C * ( (id>=0)*id - ( (x.e2 + k3(1)) * (x.Rz*x.RL1) - x.Vz*x.RL1 + (x.iL + k3(2))*x.Rz*x.RL1 )/Rd );
          h/x.L * ( ( ((x.e2 + k3(1))*x.Rz*x.RL1 + x.Vz*x.RL1*x.Rs + (x.iL + k3(2))*x.Rs*x.Rz) / Rd ) - x.RL2*(x.iL + k3(2)) )];
end

% Apply RK4 to determine e2 and iL
y.e2 = x.e2 + (k1(1)+2*k2(1)+2*k3(1)+k4(1))/6;
y.iL = x.iL + (k1(2)+2*k2(2)+2*k3(2)+k4(2))/6;

% Determine output votlage e_3 based on zener biasing
y.e3 = ( ((y.e2 - x.Rs*y.iL)/(x.RL1 + x.Rs)) * x.RL1 );
if (y.e3 >= x.Vz) % Reverse breakdown e3 is given by another expression
    y.e3 = (y.e2*x.Rz*x.RL1 + x.Vz*x.Rs*x.RL1 + y.iL*x.Rs*x.Rz) / Rd;
end 

% Determine remaining circuit parameters
y.VL  = y.e3 - x.RL2*y.iL; % Voltage at the inductor
y.VR  = y.e3; % Voltage at the resistive branch
y.VLL = y.e3; % Voltage at the inductive branch
y.iL2 = y.iL; % No current flows into the secondary load (indudctor)
y.iL1 = y.e3 / x.RL1; % Current flowing into the primary load (287 Ohms)

end