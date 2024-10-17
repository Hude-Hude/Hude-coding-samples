%%Class Assignment for Machine Learning, Implementing Logistic Regression
%on iris data, will try to write whole program and function myself%
close all
clear all
clc
%for loading the data and pre-processing it
%load iris data
load iris
%after loading assign the predictors to matrix X and labels to matrix Y
Xo1 = meas(1:40, 1:4);
Xo2 = meas(51:90, 1:4);
Xo3 = meas(101:140, 1:4);
Xo = [Xo3; Xo1; Xo2];
[m n] = size(Xo);
X = zeros(m,2);
%only taking into account two classes, for testing and will enhance it for
%one vs all classification
y = zeros(120,1);
%as it runs only on two classes i.e. 0 and 1, just replace all 1's with 0's
% and replace all 2's with 1's
for i = 1:(m/3)
    y(i) = 0;
end
for i = (m/3)+1:m
    y(i) = 1;
end
for i = 1:m
    X(i,:) = [mean(Xo(i,:)) var(Xo(i,:))];
end

%% Plotting the data
fprintf(['Plotting data with + indicating (y = 0) examples and o ' ...
         'indicating (y = 1) examples.\n']);
disp('class 0 represents "Virginica" and class 1 represents "Setosa & Versicolor"')


plotData(X, y);

% Labels and Legend
title('Virginica vs setosa and versicolor')

% Specified in plot order
legend('Virginica', 'Setosa & Versicolor')
hold off;

%% Computing Cost
%  Setup the data matrix appropriately, and add ones for the intercept term
[m, n] = size(X);

% Add intercept term to x and X_test
X = [ones(m, 1) X];

% Initialize fitting parameters
initial_theta = ones(n + 1, 1);

% Compute and display initial cost and gradient
[cost, grad] = CostFunc(initial_theta, X, y);

fprintf('Cost at initial theta (zeros): %f\n', cost);
fprintf('Gradient at initial theta (zeros): \n');
fprintf(' %f \n', grad);


%% Optimizing using fminunc

%  Set options for fminunc
%options = optimset('GradObj', 'on', 'MaxIter', 400);
options = optimoptions('fmincon','Algorithm','sqp','Display','iter','TolCon',1e-12);
%  Run fminunc to obtain the optimal theta
%  This function will return theta and the cost 
[theta, cost] = ...
	fminunc(@(t)(CostFunc(t, X, y)), initial_theta, options);
% Print theta to screen
fprintf('Cost at theta found by fminunc: %f\n', cost);
fprintf('theta: \n');
fprintf(' %f \n', theta);

% Plot Boundary
plotDecisionBoundary(theta, X, y);

% Put some labels 
hold on;
% Labels and Legend
title('Virginica vs Setosa and Versicolor')

% Specified in plot order
legend('Virginica', 'Setosa & Versicolor')
hold off;


%% Prediction on the remaining dataset
theta3 = theta;
Xt1 = meas(41:50, 1:4);
Xt2 = meas(91:100, 1:4);
Xt3 = meas(141:150, 1:4);
Xt = [Xt3; Xt1; Xt2];
[m n] = size(Xt);
Xtest = zeros(m,2);
for i = 1:m
    Xtest(i,:) = [mean(Xt(i,:)) var(Xt(i,:))];
end 

Xtest = [ones(m, 1) Xtest];
prob = sigmoid(Xtest*theta);
p = predict(Xtest,prob);


plotData(Xtest(:,2:3), p)

hold on

plot_x = [min(Xtest(:,2))-2,  max(Xtest(:,2))+2];

% Calculate the decision boundary line
plot_y = (-1./theta(3)).*(theta(2).*plot_x + theta(1));

% Plot, and adjust axes for better viewing
plot(plot_x, plot_y)

hold off

save('Virginica_thetaval','theta3');

    
