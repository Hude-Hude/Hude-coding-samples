#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Apr  4 13:56:11 2024

@author: Hude Hude
"""

import numpy as np
import pandas as pd
import scipy
import sympy
import patsy
import pyhdfe
import pyblp

### Part II.B
print("Part II Part II.B Data")
print()
# 1) Read Dataset
nevo_product_data = pd.read_csv(pyblp.data.NEVO_PRODUCTS_LOCATION)

# 2) View Dataset
print(nevo_product_data.head())

# 3) Verify Dataset
total_rows = nevo_product_data.shape[0]
num_cities = nevo_product_data['city_ids'].nunique()
num_quarters = nevo_product_data['quarter'].nunique()
num_brands = nevo_product_data['brand_ids'].nunique()
num_markets = nevo_product_data['market_ids'].nunique()
print(f"Total number of observations: {total_rows}")
print(f"Unique cities: {num_cities}")
print(f"Unique quarters: {num_quarters}")
print(f"Unique brands: {num_brands}")
print(f"Unique markets: {num_markets}")
print()
# 4) Summary of Statistics
print(nevo_product_data.describe())
print()

### Part III.A Multinomial Logit
print("Part III.A Multinomial Logit")
print()
# i.a) Formulation
logit_formulation = pyblp.Formulation('prices', absorb='C(product_ids)')
print(logit_formulation)
print()
# i.b) Problem
problem = pyblp.Problem(logit_formulation, nevo_product_data)
print()
# ii.a) Solve
logit_results = problem.solve()
print()

### Part III.B Nested Logit
print("Part III.B Nested Logit")
# i)
def solve_nl(df):
    groups = df.groupby(['market_ids', 'nesting_ids'])
    df['demand_instruments20'] = groups['shares'].transform(np.size)
    nl_formulation = pyblp.Formulation('0 + prices')
    problem = pyblp.Problem(nl_formulation, df)
    return problem.solve(rho=0.7)
# Assume one single nest for all products, with the outside good in its own nest.
# ii)
df1 = nevo_product_data.copy()
df1['nesting_ids'] = 1

# iii)
print("Solve a single nest case:")
nl_results1 = solve_nl(df1)

print("Inspect problem:")
print(nl_results1.problem)
print()

# iv)
df2 = nevo_product_data.copy()
df2['nesting_ids'] = df2['mushy']

# v)
nl_results2 = solve_nl(df2)


# Random Coefficient
X1_formulation = pyblp.Formulation('0 + prices', absorb='C(product_ids)')
X2_formulation = pyblp.Formulation('1 + prices + sugar + mushy')
product_formulations = (X1_formulation, X2_formulation)

# mc_integration = pyblp.Integration('monte_carlo', size=50, specification_options={'seed': 0})
# print(mc_integration)

# mc_problem = pyblp.Problem(product_formulations, nevo_product_data, integration=mc_integration)

# bfgs = pyblp.Optimization('bfgs', {'gtol': 1e-4})

# results1 = mc_problem.solve(sigma=np.ones((4, 4)), optimization=bfgs)

agent_data = pd.read_csv(pyblp.data.NEVO_AGENTS_LOCATION)

agent_formulation = pyblp.Formulation('0 + income + income_squared + age + child')

nevo_problem = pyblp.Problem(
    product_formulations,
    nevo_product_data,
    agent_formulation,
    agent_data
)

initial_sigma = np.diag([0.3302, 2.4526, 0.0163, 0.2441])
initial_pi = np.array([
  [ 5.4819,  0,      0.2037,  0     ],
  [15.8935, -1.2000, 0,       2.6342],
  [-0.2506,  0,      0.0511,  0     ],
  [ 1.2650,  0,     -0.8091,  0     ]
])
tighter_bfgs = pyblp.Optimization('bfgs', {'gtol': 1e-5})
nevo_results = nevo_problem.solve(
    initial_sigma,
    initial_pi,
    optimization=tighter_bfgs,
    method='1s'
)
print(nevo_results)