# install necessary packages

install.packages("tidyverse")
install.packages("randomForest")
install.packages("caret")
install.packages("arules")
install.packages("arulesViz")

# Load necessary libraries
library(tidyverse)
library(randomForest)
library(caret)
library(arules)
library(arulesViz)

# Load the data
data <- read.csv("brugada_phenotype_data.csv")
head(data)

# Assume that phenotypes start from the 3rd column to the end
phenotype_columns <- colnames(data)[3:ncol(data)]
data[phenotype_columns] <- lapply(data[phenotype_columns], as.factor)

# Preprocess the data
data[phenotype_columns] <- lapply(data[phenotype_columns], as.factor)
data$condition <- as.factor(data$condition)

# Set conditions for doing rule mining
conditions <- paste("condition=", levels(data$condition), sep="")

# Keep patient IDs in a separate vector
patient_ids <- data$patient_id

# Remove patient_id column
data <- data %>% select(-patient_id)

# Split the data into training and testing sets
set.seed(123)
trainIndex <- createDataPartition(data$condition, p = .8,
                                  list = FALSE,
                                  times = 1)
trainData <- data[ trainIndex,]
testData  <- data[-trainIndex,]

# Train a Random Forest model
rf_model <- randomForest(condition ~ ., data = trainData, importance = TRUE, ntree = 500)

# Predict on the test set
predictions <- predict(rf_model, newdata = testData)

# Evaluate the model
confusionMatrix(predictions, testData$condition)

# Extract feature importance
importance <- importance(rf_model)
varImportance <- data.frame(Phenotype = row.names(importance),
                            Importance = round(importance[ , 'MeanDecreaseGini'], 2))

# Rank the phenotypes by importance
rankedImportance <- varImportance %>%
  arrange(desc(Importance))

# Create the ggplot object
importance_plot <- ggplot(rankedImportance, aes(x = reorder(Phenotype, Importance), y = Importance)) +
  geom_bar(stat = 'identity') +
  coord_flip() +
  labs(title = "Phenotype Importance",
       x = "Phenotype",
       y = "Importance")

# Save the plot
ggsave("phenotype_importance.png", plot = importance_plot, width = 10, height = 8, units = "in")


# Save the importance to a CSV file
write.csv(rankedImportance, "phenotype_importance.csv", row.names = FALSE)

# Association Rule Mining
# Convert condition to a transaction format and add to the data
data$condition <- as.factor(data$condition)
transactions_with_condition <- as(data, "transactions")

# Generate rules with condition included
rules_with_condition <- apriori(transactions_with_condition, parameter = list(supp = 0.1, conf = 0.8))

# Subset rules where the condition is in the RHS
condition_rules <- subset(rules_with_condition, subset = rhs %in% conditions)

# Sort and inspect top rules
top_rules <- sort(condition_rules, by = "lift")[1:10]

# Helper function to clean and split rule items
clean_split_items <- function(items) {
  items <- gsub("[{}]", "", items) # Remove curly braces
  strsplit(items, ",")[[1]] # Split by comma
}

# Helper function to create human-readable rule text
create_rule_text <- function(lhs, rhs) {
  lhs <- gsub("[{}]", "", lhs)
  rhs <- gsub("[{}]", "", rhs)
  paste(lhs, "=>", rhs)
}

# Create a dataframe to hold the formatted rules
rules_df <- data.frame(
  Rule = sapply(1:length(top_rules), function(i) {
    lhs_text <- paste(clean_split_items(labels(lhs(top_rules[i]))[[1]]), collapse=", ")
    rhs_text <- paste(clean_split_items(labels(rhs(top_rules[i]))[[1]]), collapse=", ")
    create_rule_text(lhs_text, rhs_text)
  }),
  Support = quality(top_rules)$support,
  Confidence = quality(top_rules)$confidence,
  Lift = quality(top_rules)$lift,
  stringsAsFactors = FALSE
)

# Save to CSV
write.csv(rules_df, "top_rules.csv", row.names = FALSE)

# Prepare a data frame to store the results of patient IDs
results <- data.frame(Rule = character(), Patient_ID = character(), stringsAsFactors = FALSE)

# Report back the patient IDs that fall into each of the top 10 rules
for (i in 1:length(top_rules)) {
  rule <- top_rules[i]
  lhs_items <- labels(lhs(rule))[[1]]
  rhs_items <- labels(rhs(rule))[[1]]
  
  # Clean and split items
  lhs_items <- clean_split_items(lhs_items)
  rhs_items <- clean_split_items(rhs_items)
  
  # Combine lhs and rhs items to create a full rule match condition
  items <- c(lhs_items, rhs_items)
  rule_text <- create_rule_text(labels(lhs(rule)), labels(rhs(rule)))
  
  # Convert items to a list format suitable for subsetting
  items_list <- lapply(items, function(item) {
    parts <- strsplit(item, "=")[[1]]
    feature <- parts[1]
    value <- parts[2]
    if (feature %in% colnames(data)) {
      condition <- data[[feature]] == value
      return(condition)
    } else {
      return(rep(FALSE, nrow(data)))
    }
  })
  
  # Subset the data to get the indices of rows that match the rule
  matching_indices <- which(Reduce("&", items_list))
  
  matching_patients <- patient_ids[matching_indices]
  
  # Append the results to the data frame
  for (patient_id in matching_patients) {
    results <- rbind(results, data.frame(Rule = paste("Rule", i), Rule_Text = rule_text, Patient_ID = patient_id, stringsAsFactors = FALSE))
  }
}
# Save the results to a CSV file
write.csv(results, "rule_matches.csv", row.names = FALSE)

# Open a PNG device for the graph plot
png("filtered_rules_graph.png", width = 800, height = 600)

# Generate the plot with the graph method
plot(condition_rules, method = "graph", limit = 20)

# Close the device to save the file
dev.off()

# Open a PNG device for the grouped plot
png("filtered_rules_grouped.png", width = 800, height = 600)

# Generate the plot with the grouped method
plot(condition_rules, method = "grouped")

# Close the device to save the file
dev.off()

quality(condition_rules) <- cbind(quality(condition_rules),
                                  interestMeasure(condition_rules, measure = c("phi", "gini"), trans = transactions_with_condition))

top_rules_phi <- head(sort(condition_rules, by = "phi"), n = 100)

# Open a PNG device
png("top_100_rules_by_phi.png", width = 800, height = 600)

# Generate the plot
plot(top_rules_phi, method = "graph", 
     control = list(layout = "stress",  # Choose a suitable layout algorithm
                    circular = FALSE,   # Non-circular layout
                    engine = "ggplot2", # Using ggplot2 for better quality
                    main = "Top 100 Rules by Phi"))

# Close the device to save the file
dev.off()
