classdef CircuitMode
    % CircuitMode describes the possible modes of the power supply circuit
    %   the power supply circuit operates in four possible modes depending
    %   on whether switching of the primary and secondary switches in the
    %   multi-mode load
    %
    % Version: 1.0.0
    % Author:  Jesse Onolememen
    % Date:    23/05/2023
    enumeration
        NoLoad,
        FullLoad,
        InductiveLoad,
        ResistiveLoad
    end
end

