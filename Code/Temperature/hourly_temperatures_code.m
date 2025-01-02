clc;
clear;
close all;

load('Temperature.mat');

num_days = 365;
num_hours = 365 * 24;
hourly_temperatures = zeros(num_hours, 1);

for day = 1:num_days
    for i = 1:8
        idx = (day - 1) * 8 + i;
        if i == 1
            prev_temp = Temperature1400((day - 1) * 8 + 8);
            next_temp = Temperature1400((day - 1) * 8 + 2);
        elseif i == 8
            prev_temp = Temperature1400((day - 1) * 8 + 7);
            next_temp = Temperature1400((day - 1) * 8 + 1);
        else
            prev_temp = Temperature1400((day - 1) * 8 + i - 1);
            next_temp = Temperature1400((day - 1) * 8 + i + 1);
        end
        
        hourly_temperatures((day - 1) * 24 + 3 * i - 2) = Temperature1400(idx);
        hourly_temperatures((day - 1) * 24 + 3 * i - 1) = prev_temp + (Temperature1400(idx) - prev_temp) / 2;
        hourly_temperatures((day - 1) * 24 + 3 * i) = next_temp + (Temperature1400(idx) - next_temp) / 2;
    end
end

figure;

subplot(2,1,1);
plot(linspace(1, num_hours, num_hours), hourly_temperatures, 'r-', 'LineWidth', 1.5);
title('Hourly Temperatures', 'FontSize', 14);
xlabel('Hour of Year', 'FontSize', 12);
ylabel('Temperature (°C)', 'FontSize', 12);
grid on;

subplot(2,1,2);
plot(linspace(1, num_days*8, num_days*8), Temperature1400, 'b-', 'LineWidth', 1.5);
title('Three-Hourly Temperatures', 'FontSize', 14);
xlabel('Hour of Year', 'FontSize', 12);
ylabel('Temperature (°C)', 'FontSize', 12);
grid on;

set(gcf, 'Position', [100, 100, 800, 600]);
