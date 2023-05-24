clear;
close all;
clc;

PLOT_SYS = 1;
PLOT_DIODE = 0;
PLOT_POWER = 0;

T = 1/50;
nCycles = 250;
h = T/nCycles;

C=2200e-6*1;
Rs = 300*1;

%% 1. Plot system parameters
ts = 0;
te = 1;

yn = plotPowerSupply("NoLoad",h,ts,te,PLOT_SYS);
yf = plotPowerSupply("ResistiveLoad",h,ts,te,PLOT_SYS);
yi = plotPowerSupply("InductiveLoad",h,ts,te,PLOT_SYS);
yr = plotPowerSupply("FullLoad",h,ts,te,PLOT_SYS);

%% 2. Power Dissipation in Rs
if PLOT_POWER
t = ts:h:te;
maxP = 0.5;
p_yn = Rs * yn.Is.^2;
p_yf = Rs * yf.Is.^2;
p_yi = Rs * yi.Is.^2;
p_yr = Rs * yr.Is.^2;

figure("Name", "Power Disspiation")
hold on

plot(t,p_yn);
plot(t,p_yf);
plot(t,p_yi);
plot(t,p_yr);

legend('No Load', 'Full Load', 'Inductive Load', 'Resistive Load')
xlabel('Time (s)')
ylabel('Power (W)')
title("Power Disspation in Rs under All Modes of Operation with Nominal Values")
grid minor

% Find maximum values and indices
[max_yn, ind_yn] = max(p_yn);
[max_yf, ind_yf] = max(p_yf);
[max_yi, ind_yi] = max(p_yi);
[max_yr, ind_yr] = max(p_yr);

% Find overall max and its index
[max_val, max_idx] = max([max_yn, max_yf, max_yi, max_yr]);
max_time = t([ind_yn, ind_yf, ind_yi, ind_yr]);
max_time = max_time(max_idx);

hold off
exportgraphics(gcf,'../graphics/exports/power_dissipation_nominal.png','Resolution',300)

% Print max values to console
fprintf('Max Power No Load: %.2f W\n', max_yn)
fprintf('Max Power Full Load: %.2f W\n', max_yf)
fprintf('Max Power Inductive Load: %.2f W\n', max_yi)
fprintf('Max Power Resistive Load: %.2f W\n', max_yr)
fprintf('Max Overall Power: %.2f W\n', max_val)
end

%% 2. Check maximim diode current
if PLOT_DIODE
ts = 0;
te = (h*nCycles*4);
t=ts:h:te;

yn = plotPowerSupply("NoLoad",h,ts,te,0);
yf = plotPowerSupply("FullLoad",h,ts,te,0);
yi = plotPowerSupply("InductiveLoad",h,ts,te,0);
yr = plotPowerSupply("ResistiveLoad",h,ts,te,0);

figure("Name", "Diode Current")
hold on

plot(t,yn.Id);
plot(t,yf.Id);
plot(t,yi.Id);
plot(t,yr.Id);

legend('No Load', 'Full Load', 'Inductive Load', 'Resistive Load')
xlabel('Time (s)')
ylabel('Current (A)')
title("Diode Current Under All Modes of Operation")
grid minor

% Find maximum values and indices
[max_yn, ind_yn] = max(yn.Id);
[max_yf, ind_yf] = max(yf.Id);
[max_yi, ind_yi] = max(yi.Id);
[max_yr, ind_yr] = max(yr.Id);

% Find overall max and its index
[max_val, max_idx] = max([max_yn, max_yf, max_yi, max_yr]);
max_time = t([ind_yn, ind_yf, ind_yi, ind_yr]);
max_time = max_time(max_idx);

% Plot text label
text(max_time, max_val, sprintf('Max Overall: %.2f A', max_val))

% Add y-axis padding
y_lim = ylim;
padding = 0.1 * (y_lim(2) - y_lim(1)); % 10% padding
ylim([y_lim(1), y_lim(2) + padding])

hold off
exportgraphics(gcf,'../graphics/exports/diode_current_MIN.png','Resolution',300)

% Print max values to console
fprintf('Max Current No Load: %.2f A\n', max_yn)
fprintf('Max Current Full Load: %.2f A\n', max_yf)
fprintf('Max Current Inductive Load: %.2f A\n', max_yi)
fprintf('Max Current Resistive Load: %.2f A\n', max_yr)
fprintf('Max Overall Current: %.2f A\n', max_val)
end
