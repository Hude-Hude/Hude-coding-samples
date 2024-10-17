%% Versicolor vs All Classification
close all
clear all
clc

% Load the iris dataset
load iris

% Pre-processing: Assign predictors and labels for Versicolor vs all
Xo1 = meas(1:40, 1:4);   % Setosa
Xo2 = meas(51:90, 1:4);  % Versicolor
Xo3 = meas(101:140, 1:4); % Virginica
Xo = [Xo2; Xo1; Xo3];
[m, n] = size(Xo);
X = zeros(m, 2);

% Labels: Versicolor (0), Setosa & Virginica (1)
y = zeros(120, 1);
for i = 1:40
    y(i) = 0;  % Versicolor is class 0
end
for i = 41:120
    y(i) = 1;  % Setosa & Virginica are class 1
end

% Compute the mean and variance for features
for i = 1:m
    X(i,:) = [mean(Xo(i,:)) var(Xo(i,:))];
end

%% Plotting the data
fprintf(['Plotting data with + indicating (y = 0) examples and o ' ...
         'indicating (y = 1) examples.\n']);
disp('class 0 represents "Versicolor" and class 1 represents "Setosa & Virginica"')
plotData(X, y);

% Labels and Legend
title('Versicolor vs Setosa and Virginica')
legend('Versicolor', 'Setosa & Virginica')
hold off;

%% Computing Cost
[m, n] = size(X);
X = [ones(m, 1) X];  % Add intercept term

% Initialize fitting parameters
initial_theta = ones(n + 1, 1);

% Compute initial cost and gradient
[cost, grad] = CostFunc(initial_theta, X, y);
fprintf('Cost at initial theta: %f\n', cost);

%% Optimizing using fminunc
options = optimoptions('fmincon', 'Algorithm', 'sqp', 'Display', 'iter', 'TolCon', 1e-12);
[theta, cost] = fminunc(@(t)(CostFunc(t, X, y)), initial_theta, options);
fprintf('Cost at theta found by fminunc: %f\n', cost);
fprintf('theta: \n');
fprintf(' %f \n', theta);

% Plot Boundary
plotDecisionBoundary(theta, X, y);

% Labels and Legend
title('Versicolor vs Setosa and Virginica')
legend('Versicolor', 'Setosa & Virginica')
hold off;

%% Prediction on the test dataset
Xt1 = meas(41:50, 1:4);  % Setosa test
Xt2 = meas(91:100, 1:4); % Versicolor test
Xt3 = meas(141:150, 1:4);% Virginica test
Xt = [Xt2; Xt1; Xt3];
[m, n] = size(Xt);
Xtest = zeros(m, 2);

% Compute mean and variance for test data
for i = 1:m
    Xtest(i,:) = [mean(Xt(i,:)) var(Xt(i,:))];
end

Xtest = [ones(m, 1) Xtest];  % Add intercept term
prob = sigmoid(Xtest * theta); % Compute probabilities
p = predict(Xtest, prob);      % Predict based on probabilities

% Plot the test data
plotData(Xtest(:, 2:3), p);

hold on;
plot_x = [min(Xtest(:, 2)) - 2, max(Xtest(:, 2)) + 2];
plot_y = (-1./theta(3)) .* (theta(2).*plot_x + theta(1));
plot(plot_x, plot_y);
hold off;

% Save theta for future use
theta2 = theta;
save('Versicolor_thetaval', 'theta2');
