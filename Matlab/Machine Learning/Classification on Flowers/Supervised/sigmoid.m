function g = sigmoid(b)

%J = sigmoid(b)

%g = zeros(size(b));

g = 1./(1 + exp(-b));

end