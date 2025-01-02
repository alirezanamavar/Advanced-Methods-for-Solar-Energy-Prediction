clear; clc; close all;

load('Power.mat');
load('Radiation1400New.mat');
load('hourly_temperatures.mat');
load('hourly_Rain.mat');

Is = Radiation1400New * 1e-6;
Ta = hourly_temperatures;
N = 22032;
T_noct = 20.5;
I_sc = 9.18;
v_oc = 45.1;
I_mp = 8.61;
V_mp = 36.6;
ki = 0.05;
kv = -0.14;
FF = (V_mp * I_mp) / (v_oc * I_sc);

Tc = Ta + Is .* ((T_noct - 20) / 0.8);
I = Is .* (I_sc + ki .* (Tc - 25));
v = v_oc - kv .* Tc;
P = N * FF .* v .* I * 1e-3;
P(P < 0) = 0; % حذف مقادیر منفی

X = zeros(8760, 4);
X(:, 1) = normalize(hourly_temperatures, 'range');
X(:, 2) = normalize(Radiation1400New, 'range');
X(:, 3) = normalize(hourlyRain, 'range');
X(:, 4) = reshape(Power1400, [], 1);

PP = reshape(P, 24, []);
PPer = PP - reshape(Power1400, 24, []);
PPerr = mean(PPer.^2, 'all');

inputs = X(:, 1:3);
targets = X(:, 4);

mdl = fitlm(inputs, targets);
coeffs = mdl.Coefficients.Estimate;
Preg = [ones(size(inputs, 1), 1), inputs] * coeffs;
PPreg = reshape(Preg, 24, []);
PPreger = PPreg - reshape(Power1400, 24, []);
PPregerr = mean(PPreger.^2, 'all');

hiddenLayerSize = 20;
net = fitnet(hiddenLayerSize);
net.trainParam.epochs = 2000;
net.trainParam.goal = 1e-6;
net.divideParam.trainRatio = 0.7;
net.divideParam.valRatio = 0.2;
net.divideParam.testRatio = 0.1;
[net, tr] = train(net, inputs', targets');
outputs = net(inputs');
errors = targets' - outputs;
performance = perform(net, targets', outputs);

PPNN = reshape(outputs', 24, []);
PPNNerr = mean((PPNN - reshape(Power1400, 24, [])).^2, 'all');

objective = @(a) mean((targets - (a(1) + a(2)*inputs(:,1) + a(3)*inputs(:,2) + a(4)*inputs(:,3) + a(5)*inputs(:,1).*inputs(:,2) + a(6)*inputs(:,2).*inputs(:,3) + a(7)*inputs(:,1).^2)).^2);
nVars = 7;
optionsGA = optimoptions('ga', 'MaxGenerations', 500, 'PopulationSize', 200, 'FunctionTolerance', 1e-8, 'Display', 'iter', 'MutationFcn', @mutationadaptfeasible, 'CrossoverFraction', 0.8);
[bestCoeffsGA, errorGA] = ga(objective, nVars, [], [], [], [], [-20 -20 -20 -20 -20 -20 -20], [20 20 20 20 20 20 20], [], optionsGA);

PPGA = reshape(bestCoeffsGA(1) + bestCoeffsGA(2)*inputs(:,1) + bestCoeffsGA(3)*inputs(:,2) + bestCoeffsGA(4)*inputs(:,3) + bestCoeffsGA(5)*inputs(:,1).*inputs(:,2) + bestCoeffsGA(6)*inputs(:,2).*inputs(:,3) + bestCoeffsGA(7)*inputs(:,1).^2, 24, []);
PPGAerr = mean((PPGA - reshape(Power1400, 24, [])).^2, 'all');

figure('Name', 'Error Comparison');
bars = [PPerr, PPregerr, PPNNerr, errorGA];
bar(categorical({'Theoretical', 'Regression', 'Neural Network', 'Genetic Algorithm'}), bars);
title('Error Comparison between Methods');
ylabel('Mean Squared Error'); grid on;

figure('Name', 'Comparison of Mean Powers');
plot(mean(PP, 1), 'r', 'LineWidth', 1.5, 'DisplayName', 'Theoretical');
hold on;
plot(mean(PPreg, 1), 'b', 'LineWidth', 1.5, 'DisplayName', 'Regression');
plot(mean(PPNN, 1), 'g', 'LineWidth', 1.5, 'DisplayName', 'Neural Network');
plot(mean(PPGA, 1), 'k', 'LineWidth', 1.5, 'DisplayName', 'Genetic Algorithm');
plot(mean(reshape(Power1400, 24, []), 1), 'm', 'LineWidth', 1.5, 'DisplayName', 'Practical');
legend('Location', 'best');
title('Comparison of Mean Powers');
xlabel('Day'); ylabel('Power (kW)'); grid on;

figure('Name', 'Theoretical Power by Day');
plot(mean(PP, 1), 'r', 'LineWidth', 1.5);
title('Theoretical Power (Daily)');
xlabel('Day'); ylabel('Power (kW)'); grid on;

figure('Name', 'Regression Power by Day');
plot(mean(PPreg, 1), 'b', 'LineWidth', 1.5);
title('Regression Power (Daily)');
xlabel('Day'); ylabel('Power (kW)'); grid on;

figure('Name', 'Neural Network Power by Day');
plot(mean(PPNN, 1), 'g', 'LineWidth', 1.5);
title('Neural Network Power (Daily)');
xlabel('Day'); ylabel('Power (kW)'); grid on;

figure('Name', 'Genetic Algorithm Power by Day');
plot(mean(PPGA, 1), 'k', 'LineWidth', 1.5);
title('Genetic Algorithm Power (Daily)');
xlabel('Day'); ylabel('Power (kW)'); grid on;

figure('Name', 'Practical Power by Day');
plot(mean(reshape(Power1400, 24, []), 1), 'm', 'LineWidth', 1.5);
title('Practical Power (Daily)');
xlabel('Day'); ylabel('Power (kW)'); grid on;
