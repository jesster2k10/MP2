clear;
clc;
close all;

% f      = 50;
% T      = 1/f;
% tstart = 0;
% tend  = 1;
% dt    = T;
% t     = 0:dt:tend;
% n     = length(t);
% modes = [CircuitMode.NoLoad];
% 
% vin_t = @(t) 230*sqrt(2)*abs((sin(100*pi*t)));

h = 2e-5;
ts = 0;
te = 1;

t = ts:h:te;  % Define the time range from 0 to 1 with a step size of 0.001
N = length(t);
v = @(t) 230 * sqrt(2) * sin(100*pi*t);  % Calculate the values of the function

mode = CircuitMode.NoLoad;
ic = [0,0,0];

e2 = zeros(1,N);
e3 = zeros(1,N);
Iz = zeros(1,N);
Is = zeros(1,N);
Id = zeros(1,N);
Il = zeros(1,N);
Ic = zeros(1,N);

VK = zeros(N,5);
Out = zeros(N,3);

for n = 1:N-1
    tn = t(n);
    tn_1 = tn + h;
    tn_2 = tn + h/2;
    VK(n,:) = [n, tn, v(tn), v(tn_2), v(tn_1) ];
    Vin = [v(tn), v(tn_2), v(tn_1)];
    

    y = powerSupply(mode,Vin,h,ic);

    ic(1) = y.e2;
    ic(2) = y.e3;
    ic(3) = y.iL;

    e2(n) = y.e2;
    e3(n) = y.e3;
    Iz(n) = y.Iz;
    Id(n) = y.Id;
    Is(n) = y.Is;
    Il(n) = y.iL;
    Ic(n) = y.Ic;
end

% figure
% plot(t, v(t));  % Plot the function
% xlabel('t');  % Set the x-axis label
% ylabel('y');  % Set the y-axis label
% title('Plot of 230 * sqrt(2) * abs(sin(100*pi*t))');  % Set the plot title

figure

subplot(2,1,1);
hold on
plot(t, e2, 'r');
plot(t, e3, 'b');
hold off

title(['Voltages for ', char(mode), ' with h = ', num2str(h)]);

legend('e2', 'e3');
xlabel('Time (s)')
ylabel('Vurrent (A)')

subplot(2,1,2);
hold on;
% plot(t, Id, 'r');
% plot(t, Is, 'b');
% plot(t, Ic, 'g');
plot(t, Iz, 'c');
% plot(t, Il, 'm');
hold off;

legend('Iz');
title(['Currents for ', char(mode), ' with h = ', num2str(h)]);
xlabel('Time (s)')
ylabel('Current (A)')

% plot(t, e3);
% 
% for i = 1:length(modes)
%     mode = modes(i);
%     e2  = zeros(1, n);
%     e3  = zeros(1, n);
%     Iz  = zeros(1, n);
%     Il  = zeros(1, n);
%     Ic  = zeros(1, n);
%     Id  = zeros(1, n);
% 
%     ic  = [0, 0, 0]; % e3, e3, iL
% 
%     for k = 1:n-1
%         vin = vin_t([ t(k), t(k)+dt/2, t(k)+dt ])
%         y = powerSupply(mode,vin,dt,ic)
%         ic(1) = y.e2;
%         ic(2) = y.e3;
%         ic(3) = y.iL;
% 
%         e2(n) = y.e2;
%         e3(n) = y.e3;
%         Iz(n) = y.Iz;
%         Il(n) = y.iL;
%         Ic(n) = y.Ic;
%         Id(n) = y.Id;
%     end
% 
%     figure
%     hold on
%     plot(t, e2, 'b')
% end

% clear;
% clc;
% 
% % Define time range and time step sizes
% t_start = 0;      % Start time
% t_end = 10;       % End time
% dt_values = [0.01, 0.05, 0.1, 0.5]; % Array of time step sizes
% modes = [CircuitMode.NoLoad, CircuitMode.FullLoad, CircuitMode.ResistiveLoad, CircuitMode.InductiveLoad]; % Load conditions
% 
% % Define input voltages and initial conditions
% vin = [1, 1, 1];
% ic = [0, 0, 0];
% 
% for dt_index = 1:length(dt_values)
%     dt = dt_values(dt_index);
% 
%     % Calculate number of steps
%     n_steps = floor((t_end - t_start) / dt);
% 
%     % Initialize time array
%     t_values = linspace(t_start, t_end, n_steps);
% 
%     for mode_index = 1:length(modes)
%         mode = modes(mode_index);
% 
%         % Initialize output arrays
%        
% 
%         for i = 1:n_steps
%             % Call the powerSupply function
%             output = powerSupply(mode, vin, dt, ic);
% 
%             % Store the results
%             Id_values(i) = output.Id;
%             Is_values(i) = output.Is;
%             Ic_values(i) = output.Ic;
%             Iz_values(i) = output.Iz;
%             Il_values(i) = output.iL;
%             e2_values(i) = output.e2;
%             e3_values(i) = output.e3;
% 
%             % Update vin and ic for the next iteration
%             vin = [vin(2), vin(3), vin(3)];
%             ic = [output.e2, output.e3, output.iL];
%         end
% 
%         % Plot the results
%         figure;
%         subplot(2,1,1); % Create a subplot for voltages
%         plot(t_values, e2_values, 'r', 'LineWidth', 2); hold on;
%         plot(t_values, e3_values, 'b', 'LineWidth', 2); hold off;
%         title(['Voltages for mode ', num2str(mode), ' with dt = ', num2str(dt)]);
%         xlabel('Time (s)');
%         ylabel('Voltage (V)');
%         legend('e2', 'e3');
%         grid on;
% 
%         subplot(2,1,2); % Create a subplot for currents
%          plot(t_values, Id_values, 'r', 'LineWidth', 2); hold on;
%          plot(t_values, Is_values, 'b', 'LineWidth', 2);
%          plot(t_values, Ic_values, 'g', 'LineWidth', 2);
%          plot(t_values, Iz_values, 'c', 'LineWidth', 2);
%          plot(t_values, Il_values, 'm', 'LineWidth', 2); hold off;
%         title(['Currents for mode ', num2str(mode), ' with dt = ', num2str(dt)]);
%         xlabel('Time (s)');
%         ylabel('Current (A)');
%         grid on;
% 
%         % Save the figure
%         saveas(gcf, ['../graphics/mode', num2str(mode), '_dt', num2str(dt), '.jpg']);
%     end
% end
