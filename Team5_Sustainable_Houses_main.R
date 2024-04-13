# ***** Random houses data set generation *****

# Ensure required packages are installed and loaded
if (!require("openxlsx")) install.packages("openxlsx")
if (!require("tidyverse")) install.packages("tidyverse")
library(openxlsx)
library(tidyverse)

# Set seed for reproducibility
set.seed(42)

# Number of houses to generate data for
num_of_houses <- 10000

# Read sustainability features from an Excel file
sustainability_features_df <- read.xlsx("Sustainability_Features_Data.xlsx", sheet = 1)
sustainability_features <- sustainability_features_df$Feature

# Create a data frame for storing sustainability data for houses
sustainable_houses <- data.frame(HouseID = paste("House", 1:num_of_houses, sep = "_"))

# Generate random "yes" or "no" for each sustainability feature
for (feature in sustainability_features) {
  sustainable_houses[[feature]] <- sample(c("yes", "no"), num_of_houses, replace = TRUE)
}

# Write the data frame to an Excel file
write.xlsx(sustainable_houses, "Sustainability_Houses_Dataset.xlsx")

# ***************************** END OF DATA GENERATION CODE **************************

# ***************************** Calculating Weights **********************************

# Read the data again (can be skipped if this is the same session)
sustainability_features_df <- read.xlsx("Sustainability_Features_Data.xlsx", sheet = 1)

# Define weights for priorities, implementations, and cost factors
priority_weights <- c("Low" = 0, "Medium" = 0.1111, "High" = 0.2222, "Very High" = 0.3333)
implementation_weights <- c("Easy" = 0.3333, "Moderate" = 0.2222, "Hard" = 0.1111, "Very Hard" = 0)
cost_factor_weights <- c("Low" = 0.3333, "Moderate" = 0.2222, "Expensive" = 0.1111, "Very Expensive" = 0)

# Helper function for safe weight lookup
safe_weight_lookup <- function(weight_list, key) {
  if (is.na(key) || !key %in% names(weight_list)) {
    return(0)
  } else {
    return(weight_list[[key]])
  }
}

# Assign weights to each feature based on priority, implementation difficulty, and cost factor
sustainability_features_df <- sustainability_features_df %>%
  rowwise() %>%
  mutate(Calc_weights = safe_weight_lookup(priority_weights, Priority) +
           safe_weight_lookup(implementation_weights, Implementation) +
           safe_weight_lookup(cost_factor_weights, Cost_Factor)) %>%
  ungroup()

# Write the updated features data to an Excel file
#write.xlsx(sustainability_features_df, "Sustainability_Features_Dataset_With_Weights.xlsx")

# ***************************** Connecting both datasets **********************************

# Create mappings from features to their weights and subcategories
feature_weights <- setNames(sustainability_features_df$Calc_weights, sustainability_features_df$Feature)
feature_subcategory <- setNames(sustainability_features_df$Sub_Category, sustainability_features_df$Feature)

# Read the sustainable houses dataset
sustainability_houses_df <- read.xlsx("Sustainability_Houses_Dataset.xlsx")

# Replace dots with spaces in column names for consistency
corrected_colnames <- gsub("\\.", " ", colnames(sustainability_houses_df))
colnames(sustainability_houses_df) <- corrected_colnames

# Convert "yes"/"no" in sustainability_houses_df to 1/0
sustainability_houses_df[, -1] <- lapply(sustainability_houses_df[, -1], function(x) ifelse(tolower(x) == "yes", 1, 0))

# Filter feature weights to include only those features present in the houses dataset
feature_weights_corrected <- feature_weights[names(feature_weights) %in% colnames(sustainability_houses_df)]

# Calculate total sustainability score
sustainability_houses_df <- sustainability_houses_df %>%
  rowwise() %>%
  mutate(Sustainability_score = sum(c_across(names(feature_weights_corrected)) * feature_weights_corrected)) %>%
  ungroup()

# ***************************** Calculating Individual Subcategory Scores **********************************

# Function to calculate subcategory weights
calculate_category_weights <- function(df, subcat, weights) {
  categories <- unique(unlist(subcat))
  subcat_matrix <- matrix(0, nrow = nrow(df), ncol = length(categories), dimnames = list(NULL, categories))
  
  for (feature in names(subcat)) {
    if (feature %in% colnames(df)) {
      category_name <- subcat[[feature]]
      subcat_matrix[, category_name] <- subcat_matrix[, category_name] + df[[feature]] * weights[feature]
    }
  }
  
  return(as.data.frame(subcat_matrix))
}

# Calculate subcategory weights
subcategory_weights_df <- calculate_category_weights(sustainability_houses_df, feature_subcategory, feature_weights_corrected)

# Add the subcategory weights as new columns to the original data
data_with_category_weights <- cbind(sustainability_houses_df, subcategory_weights_df)

# Write the final dataset with scores to an Excel file
# write.xlsx(data_with_category_weights, "Sustainability_Houses_Dataset_With_Scores.xlsx")