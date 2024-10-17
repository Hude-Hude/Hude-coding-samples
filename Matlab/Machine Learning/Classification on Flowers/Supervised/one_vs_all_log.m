%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Problem Set 4 - Advanced Econometrics
% 
% Hude Hude
% hh3024@columbia.edu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all
clear all
clc

%% Data Preparation

load iris
load setosa_thetaval
load Versicolor_thetaval
load Virginica_thetaval

Xt1 = meas(41:50, 1:4);  % Setosa test data
Xt2 = meas(91:100, 1:4); % Versicolor test data
Xt3 = meas(141:150, 1:4); % Virginica test data
Xt = [Xt1; Xt2; Xt3];
[m, n] = size(Xt);
Xtest = zeros(m,2);
for i = 1:m
    Xtest(i,:) = [mean(Xt(i,:)) var(Xt(i,:))];  % Using mean and variance
end 

Xtest = [ones(m, 1) Xtest];  % Add intercept term

% Actual labels for the test set
y1 = ones(10, 1);   % Setosa (label = 1)
y2 = 2 * ones(10, 1);  % Versicolor (label = 2)
y3 = 3 * ones(10, 1);  % Virginica (label = 3)
y_actual = [y1; y2; y3];  % Combine all labels

% Plot test data
plotClass(Xtest(:,2:3)', y_actual');
hold on

plot_x = [min(Xtest(:,2))-2,  max(Xtest(:,2))+2];

% Calculate the decision boundary line for Setosa
plot_y1 = (-1./theta1(3)).*(theta1(2).*plot_x + theta1(1));
plot(plot_x, plot_y1, 'b')

% Calculate the decision boundary line for Versicolor
plot_y2 = (-1./theta2(3)).*(theta2(2).*plot_x + theta2(1));
plot(plot_x, plot_y2, 'r')

% Calculate the decision boundary line for Virginica
plot_y3 = (-1./theta3(3)).*(theta3(2).*plot_x + theta3(1));
plot(plot_x, plot_y3, 'g')

hold off
grid off
legend('Setosa','Versicolor','Virginica')
axis([0 5 2 6]);


%% Predictions
% Compute probabilities for each class (probability of not being in the class)
prediction1 = sigmoid(Xtest * theta1);  % Probability of NOT being Setosa
prediction2 = sigmoid(Xtest * theta2);  % Probability of NOT being Versicolor
prediction3 = sigmoid(Xtest * theta3);  % Probability of NOT being Virginica

% Adjust probabilities to get the probability of being in the class of interest
prob1 = 1 - prediction1;  % Probability of being Setosa
prob2 = 1 - prediction2;  % Probability of being Versicolor
prob3 = 1 - prediction3;  % Probability of being Virginica

% Final predictions: the class with the highest probability
prediction = zeros(m,1);
for i = 1:m
    if prob1(i,:) >= prob2(i,:) && prob1(i,:) >= prob3(i,:)
        prediction(i,:) = 1;  % Setosa
    elseif prob2(i,:) >= prob1(i,:) && prob2(i,:) >= prob3(i,:)
        prediction(i,:) = 2;  % Versicolor
    else
        prediction(i,:) = 3;  % Virginica
    end
end



%% Confusion Matrix & Precision, Recall, F1-Score
C = confusionmat(y_actual, prediction);
disp('Confusion matrix is:');
disp(C);

% Precision, recall, and F1-score for Setosa
precision1 = C(1,1) / sum(C(:,1));  % Precision for Setosa
recall1 = C(1,1) / sum(C(1,:));     % Recall for Setosa
fmeas1 = 0;
if precision1 + recall1 ~= 0
    fmeas1 = 2 * (precision1 * recall1) / (precision1 + recall1);  % F1 Score for Setosa
end

% Precision, recall, and F1-score for Versicolor
precision2 = C(2,2) / sum(C(:,2));  % Precision for Versicolor
recall2 = C(2,2) / sum(C(2,:));     % Recall for Versicolor
fmeas2 = 0;
if precision2 + recall2 ~= 0
    fmeas2 = 2 * (precision2 * recall2) / (precision2 + recall2);  % F1 Score for Versicolor
end

% Precision, recall, and F1-score for Virginica
precision3 = C(3,3) / sum(C(:,3));  % Precision for Virginica
recall3 = C(3,3) / sum(C(3,:));     % Recall for Virginica
fmeas3 = 0;
if precision3 + recall3 ~= 0
    fmeas3 = 2 * (precision3 * recall3) / (precision3 + recall3);  % F1 Score for Virginica
end

%% Accuracy
Acc = sum(diag(C)) / sum(C(:));  % Accuracy = (True Positives) / (Total)

%% Display Results
disp('Precision and Recall for Setosa (class 1) are:'); disp(precision1); disp(recall1);
disp('F measure for Setosa is:'); disp(fmeas1);

disp('Precision and Recall for Versicolor (class 2) are:'); disp(precision2); disp(recall2);
disp('F measure for Versicolor is:'); disp(fmeas2);

disp('Precision and Recall for Virginica (class 3) are:'); disp(precision3); disp(recall3);
disp('F measure for Virginica is:'); disp(fmeas3);

disp('Accuracy of the system is:'); disp(Acc);
