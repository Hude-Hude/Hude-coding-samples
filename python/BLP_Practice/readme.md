# BLP Practice with Python  
This folder contains my practice of the Berry, Levinsohn, and Pakes (BLP) model using Python, particularly following the tutorial provided in the official pyBLP documentation.

## Overview
This project demonstrates my implementation of the BLP demand estimation model, commonly used in Industrial Organization (IO) to model demand in differentiated product markets. The practice is based on the cereal data from Nevo (2000) and utilizes the pyBLP package, a Python library designed for solving demand systems using the BLP framework.

## Key Features
- **Data Reading and Preprocessing**: I read and cleaned the dataset for products and markets. This includes key variables like prices, market shares, and demand instruments.
- **Multinomial Logit Estimation**: I set up and solved the standard multinomial logit model, focusing on price sensitivity and market share predictions.
- **Nested Logit Estimation**: I expanded the model to a nested logit, capturing consumer preferences within product nests (e.g., by product mushiness level).
- **Random Coefficients Logit Model**: I implemented the full BLP model with random coefficients, using Monte Carlo simulation and product rule integration for approximation. The model also incorporates observed individual demographic characteristics such as income and age.
- **Generalized Method of Moments (GMM)**: I used the GMM approach for model estimation, iteratively improving the weighting matrix and covariance matrix to obtain precise estimates of price elasticity and substitution patterns between products.

This practice serves as a hands-on walkthrough of demand estimation techniques used in academic and industry research, providing valuable insights into pricing and market competition strategies.
