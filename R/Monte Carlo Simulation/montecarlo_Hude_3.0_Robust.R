rm(list = ls())
# Load library needed
library(dplyr)
library(tidyr)
library(ggplot2)
library(openxlsx)
library(parallel)
# Set a seed for reproducibility
set.seed(894)
chunk_size <- 10000 

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

# Function to process each chunk
process_chunk <- function(df) {
  # Since all_estabs is constant and not modified, we don't need to pass it every time
  # Ensure all_estabs is defined in the global environment or pass it to mclapply as an argument
  overlap_summary <- df %>%
    group_by(worker_id_nonconn, estab_id) %>%
    summarise(overlap_count = n(), .groups = "drop")
  
  panel <- overlap_summary %>%
    pivot_wider(
      names_from = estab_id,
      values_from = overlap_count,
      values_fill = list(overlap_count = 0),
      names_prefix = "estab_",
      names_sort = TRUE,
      values_fn = list(overlap_count = sum)
    )
  
  # Ensure all establishment columns are present, fill with 0 if absent
  missing_cols <- setdiff(paste("estab_", all_estabs, sep = ""), names(panel))
  if (length(missing_cols) > 0) {
    panel[missing_cols] <- 0
  }
  
  panel[is.na(panel)] <- 0
  
  panel <- panel %>%
    mutate(Total_Connections = rowSums(select(., starts_with("estab_")), na.rm = TRUE)) %>%
    select(worker_id_nonconn, Total_Connections, everything())
  
  return(panel)
}

# Assume all_estabs is defined in the global environment
all_estabs <- unique(connections$estab_id)

# Prepare data chunks
n <- nrow(overlap_detail)
chunks <- split(overlap_detail, cut(1:n, ceiling(n/chunk_size), labels = FALSE))

# Create a cluster of cores
cl <- makeCluster(detectCores() - 1)  # Use one less than the total number of cores

# Export the necessary libraries and objects to the cluster
clusterEvalQ(cl, {
  library(dplyr)
  library(tidyr)
})
clusterExport(cl, c("all_estabs", "process_chunk"))

# Use parLapply to process each chunk in parallel
results <- parLapply(cl, chunks, process_chunk)

# Stop the cluster
stopCluster(cl)

# Combine all processed chunks
final_panel <- bind_rows(results)

# #Below are for statistic summary purpose only.
# connections_per_estab <- colSums(final_panel[, -c(1,2)], na.rm = TRUE)
# 
# df_connections_per_estab <- data.frame(establishment = names(connections_per_estab), 
#                                        total_connections = connections_per_estab)
# 
# number_of_connections <- nrow(connections)
# number_of_non_connections <- nrow(sample) - number_of_connections
# 
# mean_connections <- mean(connections_per_estab)
# median_connections <- median(connections_per_estab)
# sd_connections <- sd(connections_per_estab)
# min_connections <- min(connections_per_estab)
# max_connections <- max(connections_per_estab)
# 
# summary_connections_per_estab<- data.frame(
#   Statistics = c("Number of Connections", "Number of Non-Connections", "Mean Connections per Estab", "Median Connections per Estab", "SD Connections per Estab", "Min Connections per Estab", "Max Connections per Estab"),
#   Value = c(number_of_connections, number_of_non_connections, mean_connections, median_connections, sd_connections, min_connections, max_connections)
# )
# 
# ggplot(df_connections_per_estab, aes(x = establishment, y = total_connections)) +
#   geom_col(fill = "steelblue") +
#   theme_minimal() +
#   labs(title = "Total Connections per Public Sector Establishment",
#        x = "Public Sector Establishment",
#        y = "Total Connections") +
#   theme(axis.text.x = element_blank(), axis.ticks.x = element_blank())
# 
# excel_file_path <- "C:/RA_Projects/Labor Market Lab/3.0/montecarlo_outputs_Hude_seed894.xlsx"
# wb <- createWorkbook()
# addWorksheet(wb, "Worker")
# writeData(wb, "Worker", sample)
# addWorksheet(wb, "Firm")
# writeData(wb, "Firm", samplef)
# addWorksheet(wb, "Connections")
# writeData(wb, "Connections", connections)
# addWorksheet(wb, "Overlap detail")
# writeData(wb, "Overlap detail", overlap_detail)
# addWorksheet(wb, "Conn per Estab")
# writeData(wb, "Conn per Estab", summary_connections_per_estab)
# saveWorkbook(wb, excel_file_path, overwrite = TRUE)