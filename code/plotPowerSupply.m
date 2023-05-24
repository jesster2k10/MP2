function y = plotPowerSupply(mode,h,ts,te,p)
arguments
    mode CircuitMode
    h (1,1) double
    ts = 0
    te = 1
    p = 1
end

t = ts:h:te;
N = length(t);
v = @(t) 230 * sqrt(2) * sin(100*pi*t);  

ic = [0,0,0];

e2 = zeros(1,N);
e3 = zeros(1,N);
Iz = zeros(1,N);
Is = zeros(1,N);
Id = zeros(1,N);
Il = zeros(1,N);
Ic = zeros(1,N);


for n = 1:N-1
    tn = t(n);
    tn_1 = tn + h;
    tn_2 = tn + h/2;
    Vin = [v(tn), v(tn_2), v(tn_1)];
    
    g = powerSupply(mode,Vin,h,ic);

    ic(1) = g.e2;
    ic(2) = g.e3;
    ic(3) = g.iL;

    e2(n) = g.e2;
    e3(n) = g.e3;
    Iz(n) = g.Iz;
    Id(n) = g.Id;
    Is(n) = g.Is;
    Il(n) = g.iL;
    Ic(n) = g.Ic;
end

y.e2 = e2;
y.e3 = e3;
y.Iz = Iz;
y.Id = Id;
y.Is = Is;
y.Il = Il;
y.Ic = Ic;

if (p == 1)
figure

subplot(2,1,1);
hold on
plot(t, e2);
plot(t, e3);
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
plot(t, Il);
% plot(t, Il, 'm');
hold off;

legend('Iz');
title(['Currents for ', char(mode), ' with h = ', num2str(h)]);
xlabel('Time (s)')
ylabel('Current (A)')
end

end

