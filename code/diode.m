close all;

% Define Constants
f = 50;
T = 1/f;
t = linspace(0, T/2, 1000);
w = 2*pi*f;

% Define the functions
Vc = 4.897 * exp(-71.0227*t) + 0.7907*sin(100*pi*t) - 3.497*cos(100*pi*t) - 1.4;
ic = -0.7651 * exp(-71.0227*t) + 0.5464*cos(100*pi*t) + 2.41695*sin(100*pi*t);
Vin = 230*sqrt(2)/20 * sin(100*pi*t);

% Find the maximum current and corresponding time
[max_ic, index] = max(ic);
time_max_ic = t(index);

figure 

% Create subplot for the voltages
subplot(2,1,1)
plot(t, Vc, 'LineWidth', 1)
hold on
plot(t, Vin, 'LineWidth', 1)
ylabel('Voltage (V)')
xlabel('Time (s)')
legend('Vc(t)', 'Vin(t)')
title('Input vs Output Voltage over Half a Period')
grid on

% Create subplot for the current
subplot(2,1,2)
plot(t, ic, 'LineWidth', 1)
hold on
plot(time_max_ic, max_ic, 'ro') % Mark the maximum current
text(time_max_ic, max_ic, [' Maximum Current: ', num2str(max_ic), 'A'],'VerticalAlignment','bottom','HorizontalAlignment','left')
ylim([min(ic) max_ic+0.5*max_ic]) % Add extra room to the top of the subplot
ylabel('Current (A)')
xlabel('Time (s)')
legend('ic(t)', 'Max current')
title('Current over Half a Period')
grid on

exportgraphics(gcf,"../graphics/diode_current.png","Resolution",300)

