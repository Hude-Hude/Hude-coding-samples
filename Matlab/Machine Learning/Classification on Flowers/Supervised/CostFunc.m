function [Jval, Grad] = CostFunc(Th, X, y)

m = length(y);

Grad = zeros(size(Th));

%for computing cost function
%hfunc = sigmoid(X*Th);
%cost = (y.*log(hfunc)) + ((1-y).*log(1 - hfunc));
%J = -(1/m)*sum(cost);

H = sigmoid(X*Th);
T = y.*log(H) + (1 - y).*log(1 - H);
Jval = -1/m*sum(T);

%for computing gradient
for i = 1 : m,
	Grad = Grad + (H(i) - y(i)) * X(i,:)';
end

Grad = 1/m*Grad;

end