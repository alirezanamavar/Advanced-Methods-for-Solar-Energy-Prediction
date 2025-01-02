clc;
clear;
close all;

load('Rain.mat');

hourlyRain = interp1(1:length(Rain1400), Rain1400, linspace(1, length(Rain1400), 8760), 'linear');

figure;

subplot(2,1,1);
plot(linspace(1, 365*24, 8760), hourlyRain, 'r-', 'LineWidth', 1.5);
title('Hourly Rainfall (Interpolated)', 'FontSize', 14);
xlabel('Hour of Year', 'FontSize', 12);
ylabel('Rainfall (mm)', 'FontSize', 12);
grid on;

subplot(2,1,2);
plot(linspace(1, 365*8, length(Rain1400)), Rain1400, 'b-', 'LineWidth', 1.5);
title('Three-Hourly Rainfall', 'FontSize', 14);
xlabel('Hour of Year', 'FontSize', 12);
ylabel('Rainfall (mm)', 'FontSize', 12);
grid on;

set(gcf, 'Position', [100, 100, 800, 600]);
