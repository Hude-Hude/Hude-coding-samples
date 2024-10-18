# Monte Carlo Simulation: Labor Market and Public Sector Connections

**Author**: Hude Hude  
**Contact**: hh3024@columbia.edu

## Project Overview

This project simulates a labor market with 1,000 firms, each employing a random number of workers over a 48-month period. The simulation models the entry and exit of workers and tracks the workers who move into public sector establishments. The main goal is to identify which workers had overlapping employment periods with those who transitioned into the public sector, and to calculate their connections to public sector establishments.

This project is my first work in R. Prior to this work, I had never used R. I was able to complete this work in one month, during which I learned the basic grammar of R, the characteristics of data frames unique to R, and useful packages such as `parallel` for handling computationally heavy tasks. This project demonstrates my ability to learn new programming languages and tackle complex tasks efficiently.

### Key Steps

1. **Labor Market Simulation**:
   - 1,000 firms are generated, each with a randomly assigned number of employees (1 to 1,000).
   - Workers are assigned random entry and exit months over the 48-month period.
   - A subset of workers is randomly selected as "connections," who leave the private sector and join public sector establishments after 48 months.

2. **Overlap Calculation**:
   - Identifies workers who overlapped with public sector-bound workers during their employment period.
   - Assembles a panel dataset for each worker, indicating the number of connections they have across different public sector establishments.

3. **Statistical Summary and Visualization**:
   - Generates a distribution plot of the number of connections per public sector establishment.
   - Outputs a summary table with descriptive statistics for connections across public sector establishments.

### Code Information

**Current version**:  
- `montecarlo_Hude_3.0.R`: Runs faster but is subject to memory constraints of R and the computer used.  
- `montecarlo_Hude_3.0_Robust.R`: A more robust version that handles larger datasets through parallelization and chunking to avoid memory issues such as "Maximum Integer Limit" and "Memory Limit."

**Findings**:
- The recent simulations were run using seed (31) and seed (894). Seed (894) generates a significantly larger dataset compared to seed (31), which can lead to capacity issues. 
- Outputs and previous work are stored in two separate folders within the `montecarlo_Hude` directory.

### Results Summary

1. **Excel Outputs**:  
   - The most recent code version outputs an Excel file containing copies of the generated dataframes. However, the file contains millions of entries, so it may take time to open.

2. **Histogram of Connections per Establishment**:  
   - The histogram represents the number of non-connection workers who had at least one connection in each public sector establishment.  
   - Note that the count of connections per establishment does not equal the total number of workers moving to the public sector. Instead, it reflects the number of non-connection workers with at least one connection to a worker in a public sector establishment, which can result in multiple connections for a single worker.

### Tools Used

- **Programming Languages**: R
- **Libraries**: `parallel`, `dplyr`, `tidyr`, `ggplot2`, `openxlsx`


