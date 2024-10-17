# Load the package
library(dplyr)
library(igraph)

connection <- read.csv("C:/MAE/Research/Project_SteamNetwork/Connections.csv", header = FALSE, colClasses = c("character", "character", "character"))

# Assign column names
colnames(connection) <- c("user_id", "IF_id", "IF2_id")

connection <- distinct(connection)

# Create edges between user_id and IF_id
edges <- as.vector(t(connection[, c("user_id", "IF_id")]))

# Create the graph (undirected since the relationship is mutual)
g <- graph(edges, directed = FALSE)

# Find the connected components (groups of connected users)
components <- components(g)

# Create a new dataframe with user_id and their corresponding group_id
grouped_users <- data.frame(
  user_id = V(g)$name,                   # All nodes in the graph (user_id and IF_id)
  group_id = components$membership       # Group IDs based on connected components
)

# Filter to keep only user_ids (since IF_id might be included in the graph)
grouped_users <- grouped_users[grouped_users$user_id %in% connection$user_id, ]
