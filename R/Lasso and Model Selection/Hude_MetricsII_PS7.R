# Load necessary libraries
library(readr)
library(glmnet)
library(Matrix)
set.seed(1987)
# Read the data
column_names <- c("y", "x1", "x2", "x3", "x4", "x5", "x6", "x7", "x8", "x9", "x10")
data <- readr::read_delim("/Users/kissshot894/Documents/MAE/Econometrics ll/pset7.txt", delim = " ", col_names = column_names)

# Create a formula that includes all 2-way and 3-way interactions
interaction_formula <- reformulate(
  termlabels = paste(column_names[-1], collapse = "+"),
  response = "y"
)
# Extend the formula to include 2-way and 3-way interactions
extended_formula <- update(interaction_formula, . ~ . + (.)^2 + (.)^3)

# Generate the model matrix excluding the intercept
x <- model.matrix(extended_formula, data = data)[,-1]  # '-1' to exclude the intercept column

# Extract the response variable
y <- data$y

# Fit Lasso model using glmnet with cross-validation
cvfit <- cv.glmnet(x, y, type.measure = "mse", nfolds = 5, alpha = 1)

# Extract the lambda that gives the minimum mean cross-validated error
lambda.min <- cvfit$lambda.min

# Print the optimal lambda value
print(paste("The optimal lambda value is:", lambda.min))

# Fit final Lasso model using the selected lambda
finalfit <- glmnet(x, y, alpha = 1, lambda = lambda.min)

# Determine the number of non-zero coefficients
non_zero_coeff <- sum(coef(finalfit, s = lambda.min) != 0)

# Print active set of covariates
activeset <- coef(finalfit, s = lambda.min)
print(activeset)
print(paste("Number of covariates with non-zero coefficients:", non_zero_coeff))


# Adaptive Lasso
# Fit initial Lasso model to obtain coefficients for penalty factors

# Extract coefficients at the best lambda and calculate penalty factors
initial_coefficients <- coef(finalfit, s = lambda.min)[-1]

penalty_factors <- 1 / abs(initial_coefficients)

# Fit Adaptive Lasso using calculated penalty factors
adaptive_cv_fit <- cv.glmnet(x, y, alpha = 1, penalty.factor = penalty_factors, type.measure = "mse")
lambda_adaptive <- adaptive_cv_fit$lambda.min

# Fit final Adaptive Lasso model using the selected lambda
adaptive_fit <- glmnet(x, y, alpha = 1, lambda = lambda_adaptive, penalty.factor = penalty_factors)

# Determine the number of non-zero coefficients in the Adaptive Lasso model
non_zero_adaptive_coeff <- sum(coef(adaptive_fit, s = lambda_adaptive) != 0)

# Optionally, print the coefficients to see which are non-zero
active_set_adaptive <- coef(adaptive_fit, s = lambda_adaptive)
print(active_set_adaptive)

# Print results
print(paste("Optimal lambda for Adaptive Lasso:", lambda_adaptive))
print(paste("Number of covariates with non-zero coefficients in Adaptive Lasso:", non_zero_adaptive_coeff))


# 3) Post-Lasso
# Extract non-zero coefficients from adaptive Lasso, excluding the intercept if included
non_zero_indices <- which(coef(adaptive_fit, s = lambda_adaptive)[-1] != 0)  # Assuming the first element is the intercept
non_zero_names <- colnames(x)[non_zero_indices]

# Subset the x matrix to include only columns with non-zero coefficients from adaptive Lasso
x_selected <- x[, non_zero_names, drop = FALSE]

# Convert the subset x matrix to a data frame
x_selected_df <- as.data.frame(x_selected)

# Combine 'y' with 'x_selected_df' into a new data frame
ols_data <- cbind(y = y, x_selected_df)

# Fit the OLS model using only the selected covariates
post_lasso_model <- lm(y ~ . - 1, data = ols_data)  # '-1' to exclude the intercept

# Summarize the OLS model results
summary_post_lasso <- summary(post_lasso_model)

# Print the summary of the OLS model
print(summary_post_lasso)