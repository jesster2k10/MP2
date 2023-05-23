function [circuit] = power_supply(mode,v,h,x)
% power_supply: Uses RK4 to determine the parameters (.i.e. voltages
% and currents) of the simple power supply circuit. The analysis is
% governed by the respective mode of operation.
%
% Inputs:
% mode: the current mode of operation (enum: CircuitMode)
% v:    input voltage
% h:    time step
% x:    circuit input parameters
%
% Outputs:
% circuit: A matrix containing the circuit parameters
%
% Author:  Jesse Onolememen
% Version: 1.0.0
% Date:    23/05/2023 
%
arguments
    mode CircuitMode
end
end

