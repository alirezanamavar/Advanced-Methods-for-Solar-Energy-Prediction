# Solar Power Analysis and Prediction

This project involves analyzing and predicting the power output of a solar energy system using various computational techniques. The approaches include theoretical calculations, linear regression, neural networks, and optimization using a genetic algorithm.

## Project Description
The goal is to estimate and compare the power output of a solar energy system through different methods and evaluate their accuracy against practical data. Key components of the analysis include:

1. **Theoretical Modeling**: Calculating power output based on solar radiation and environmental factors.
2. **Regression Analysis**: Employing linear regression to predict power output.
3. **Neural Networks**: Utilizing a feedforward neural network for prediction.
4. **Genetic Algorithm Optimization**: Tuning a model to minimize error using genetic algorithms.

## Data
The following data files are used in the project:

- `Power.mat`: Contains practical power output data.
- `Radiation1400New.mat`: Solar radiation data.
- `hourly_temperatures.mat`: Hourly temperature data.
- `hourly_Rain.mat`: Hourly rainfall data.

## Requirements

The project is implemented in MATLAB. Ensure you have the following:

- MATLAB installed with the Neural Network and Optimization Toolboxes.
- The `.mat` files mentioned above.

## Code Breakdown

### Loading Data
```matlab
load('Power.mat');
load('Radiation1400New.mat');
load('hourly_temperatures.mat');
load('hourly_Rain.mat');
```
This section loads the necessary data files.

### Theoretical Power Calculation
```matlab
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
P(P < 0) = 0; % Remove negative values
```
This section computes theoretical power output based on environmental parameters.

### Data Preparation
```matlab
X = zeros(8760, 4);
X(:, 1) = normalize(hourly_temperatures, 'range');
X(:, 2) = normalize(Radiation1400New, 'range');
X(:, 3) = normalize(hourlyRain, 'range');
X(:, 4) = reshape(Power1400, [], 1);
```
Data is normalized and organized into a matrix for analysis.

### Linear Regression
```matlab
mdl = fitlm(inputs, targets);
coeffs = mdl.Coefficients.Estimate;
Preg = [ones(size(inputs, 1), 1), inputs] * coeffs;
PPregerr = mean((Preg - reshape(Power1400, 24, [])).^2, 'all');
```
Regression is performed to estimate power output and compute error.

### Neural Network
```matlab
hiddenLayerSize = 20;
net = fitnet(hiddenLayerSize);
net.trainParam.epochs = 2000;
net.trainParam.goal = 1e-6;
[net, tr] = train(net, inputs', targets');
outputs = net(inputs');
PPNNerr = mean((reshape(outputs', 24, []) - reshape(Power1400, 24, [])).^2, 'all');
```
A feedforward neural network is trained to predict power output.

### Genetic Algorithm
```matlab
objective = @(a) mean((targets - (a(1) + a(2)*inputs(:,1) + a(3)*inputs(:,2) + a(4)*inputs(:,3) + a(5)*inputs(:,1).*inputs(:,2) + a(6)*inputs(:,2).*inputs(:,3) + a(7)*inputs(:,1).^2)).^2);
optionsGA = optimoptions('ga', 'MaxGenerations', 500, 'PopulationSize', 200, 'FunctionTolerance', 1e-8);
[bestCoeffsGA, errorGA] = ga(objective, 7, [], [], [], [], [-20, -20, -20, -20, -20, -20, -20], [20, 20, 20, 20, 20, 20, 20], [], optionsGA);
PPGAerr = mean((reshape(PPGA, 24, []) - reshape(Power1400, 24, [])).^2, 'all');
```
Genetic algorithms are used to minimize prediction error by optimizing model coefficients.

### Visualization
#### Error Comparison
```matlab
bars = [PPerr, PPregerr, PPNNerr, errorGA];
bar(categorical({'Theoretical', 'Regression', 'Neural Network', 'Genetic Algorithm'}), bars);
title('Error Comparison between Methods');
```

#### Power Comparison
```matlab
plot(mean(PP, 1), 'r', 'LineWidth', 1.5, 'DisplayName', 'Theoretical');
plot(mean(PPreg, 1), 'b', 'LineWidth', 1.5, 'DisplayName', 'Regression');
plot(mean(PPNN, 1), 'g', 'LineWidth', 1.5, 'DisplayName', 'Neural Network');
plot(mean(PPGA, 1), 'k', 'LineWidth', 1.5, 'DisplayName', 'Genetic Algorithm');
plot(mean(reshape(Power1400, 24, []), 1), 'm', 'LineWidth', 1.5, 'DisplayName', 'Practical');
```

## Results
The project evaluates and compares the following methods based on mean squared error:

- **Theoretical**: Prediction based on environmental factors.
- **Regression**: Linear regression analysis.
- **Neural Network**: Feedforward neural network.
- **Genetic Algorithm**: Coefficient optimization.

## Figures
The following visualizations are generated:

1. Error comparison for all methods.
2. Daily mean power comparison.
3. Individual power predictions for each method.

## Conclusion
This project demonstrates the application of various computational techniques to predict solar power output. The error comparison helps identify the most accurate method for the given data and context.
