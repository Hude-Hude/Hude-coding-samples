rm(list = ls())
# Load library needed
library(dplyr)
library(tidyr)
library(ggplot2)
library(openxlsx)

# Set a seed for reproducibility
set.seed(31)

# Initialize parameters and generate firm sizes
firms <- seq(1, 1000)
sample <- data.frame(firms)
for(i in 1:length(sample$firms)){
  sample$size[i] <- sample(1:1000, 1)
}

months <- 48 # Total period of simulation in months
cohorts <- seq(1, months) # Represents each month in the simulation period

# Allocate employees to each firm for each month/year
samplef <- data.frame()
for(i in 1:length(sample$firms)){
  s <- cbind(
    rmultinom(n = 1, size = sample$size[i], prob = rep(1/max(cohorts), max(cohorts))), 
    sample$size[i], 
    i, 
    cohorts
  )
  samplef <- rbind(samplef, s) # Append to the records dataframe
}
colnames(samplef) <- c("cohort", "size", "firm_id", "month_year") # Adjusted column names

# Filter out entries where no employees were allocated in a month
samplef <- samplef %>% filter(cohort > 0)

# Generate worker entries for each firm and month
sample <- data.frame() # Reset 'sample' to hold individual worker records
for(i in 1:length(samplef$cohort)){
  s <- cbind(
    paste0(seq(1, samplef$cohort[i]), "_", samplef$firm_id[i]), 
    samplef$size[i], 
    samplef$firm_id[i], 
    samplef$month_year[i]
  )
  sample <- rbind(sample, s) # Append to the workers dataframe
}
colnames(sample) <- c("worker_id",  "size", "firm_id", "month_start") # Adjusted column names to original

# Differentiate workers in the same firm
sample$worker_id <- paste0(sample$worker_id, "_", seq(1, length(sample$worker_id)))

# Randomly generate tenure (end month) for each worker, considering the simulation period
for(i in 1:length(sample$worker_id)){
  if(as.numeric(sample$month_start[i]) < months){
    sample$month_end[i] <- sample(as.numeric(sample$month_start[i]):months, 1)
  } else {
    sample$month_end[i] <- months
  }
}

# Randomly pick workers to employ in the public sector
n_connections <- sample(round(length(sample$worker_id) * .01):round(length(sample$worker_id) * .1), 1)
connection_ids <- sample(sample$worker_id, n_connections)

# Create connections dataframe including worker_ids, month_start and month_end
connections <- sample %>%
  filter(worker_id %in% connection_ids) %>%
  select(worker_id, month_start, month_end, firm_id)

# Generate public sector establishments
n_estabs <- sample(round(n_connections * .1):round(n_connections * .5), 1)

# Assign each transitioning worker to a public sector establishment
connections$estab_id <- sample(seq(1, n_estabs), nrow(connections), replace = TRUE)

# Generate a joined dataframe for overlap analysis
overlap_detail <- sample %>%
  # Filter to only non-connection workers
  filter(!worker_id %in% connections$worker_id) %>%
  # Perform the join, acknowledging many-to-many relationships
  inner_join(connections, by = "firm_id", suffix = c("_nonconn", "_conn"), relationship = "many-to-many") %>%
  # Keep only rows where employment periods overlap
  filter(month_start_nonconn <= month_end_conn & month_end_nonconn >= month_start_conn)

# Aggregate overlaps by worker and public sector establishment
overlap_summary <- overlap_detail %>%
  group_by(worker_id_nonconn, estab_id) %>%
  summarise(overlap_count = n(), .groups = "drop")

# Pivot the summary into a wide format panel
panel <- overlap_summary %>%
  pivot_wider(
    names_from = estab_id,
    values_from = overlap_count,
    values_fill = list(overlap_count = 0)
  )

# Replace NA with 0 for establishments with no connections (if any remain)
panel[is.na(panel)] <- 0

# Add a new column for total connections by summing across establishments for each worker
panel <- panel %>%
  mutate(Total_Connections = rowSums(select(., -worker_id_nonconn), na.rm = TRUE)) %>%
  select(worker_id_nonconn, Total_Connections, everything())

# Replace NA with 0 for establishments with no connections (if any remain)
panel[is.na(panel)] <- 0

# Calculate column sums for each public sector establishment to get the total number of connections per establishment
connections_per_estab <- colSums(panel[, -c(1,2)], na.rm = TRUE)

# Convert the total connections per establishment into a dataframe for plotting
df_connections_per_estab <- data.frame(establishment = names(connections_per_estab), 
                                       total_connections = connections_per_estab)

# Data Summary
number_of_connections <- nrow(connections)
number_of_non_connections <- nrow(sample) - number_of_connections

# Calculate descriptive statistics for total_connections_per_estab
mean_connections <- mean(connections_per_estab)
median_connections <- median(connections_per_estab)
sd_connections <- sd(connections_per_estab)
min_connections <- min(connections_per_estab)
max_connections <- max(connections_per_estab)

# Create a summary table
summary_connections_per_estab<- data.frame(
  Statistics = c("Number of Connections", "Number of Non-Connections", "Mean Connections per Estab", "Median Connections per Estab", "SD Connections per Estab", "Min Connections per Estab", "Max Connections per Estab"),
  Value = c(number_of_connections, number_of_non_connections, mean_connections, median_connections, sd_connections, min_connections, max_connections)
)

# Generate the histogram plot (Call this part in Console to generate the plot)
ggplot(df_connections_per_estab, aes(x = establishment, y = total_connections)) +
  geom_col(fill = "steelblue") +
  theme_minimal() +
  labs(title = "Total Connections per Public Sector Establishment",
       x = "Public Sector Establishment",
       y = "Total Connections") +
  theme(axis.text.x = element_blank(), axis.ticks.x = element_blank())


#------------------------------------