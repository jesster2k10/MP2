clear
close all
clc

h  = 2e-5;
ts = 0;
te = 1;
t  = ts:h:te;

openExample('graphics/PrecomputeDataThenCreateAnimationExample')

% y = plotPowerSupply("NoLoad",h)
% plotPowerSupply("ResistiveLoad", h)
% plotPowerSupply("InductiveLoad", h)
plotPowerSupply("FullLoad", h)

if (1==3)
yn = plotPowerSupply("NoLoad",h,ts,te,0);
yf = plotPowerSupply("FullLoad",h,ts,te,0);
yi = plotPowerSupply("InductiveLoad",h,ts,te,0);
yr = plotPowerSupply("ResistiveLoad",h,ts,te,0);

figure("Name", "Diode Current")
hold on

plot(t,yn.Id);
plot(t,yf.Id);
% plot(t,yi.Id);
plot(t,yr.Id);

legend('No Load', 'Full Load', 'Inductive Load', 'Resistive Load')
xlabel('Time (s)')
ylabel('Current (A)')
title("Diode Current Under All Modes of Operation")
grid minor

hold off
end