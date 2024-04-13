library(openxlsx)
library(tidyverse)
library(dplyr)
library(purrr)

dataSet <- read.xlsx("Sustainability_Houses_Dataset_With_Scores.xlsx")
dataSet <- head(dataSet,1000)

# Replacing dots with spaces in column names for better usage
corrected_colnames <- gsub("\\.", "_", colnames(dataSet))
colnames(dataSet) <- corrected_colnames

# Normalizing the sustainability score
normalize_column <- function(column) {
  (column - min(column)) / (max(column) - min(column))
}

# Normalizing the Sustainability_score
normalize_min_max <- function(x) {
  return((x - min(x)) / (max(x) - min(x)))
}
dataSet$Normalized_scores <- normalize_min_max(dataSet$Sustainability_score)

# Overall Sustainability Score Classification (Not using right now)
classification_results <- sapply(dataSet$Normalized_scores, function(x) {
  if (x >= 0.5) {
    return(1)
  } else {
    return(0)
  }
})
dataSet$Classification <- classification_results
# write.xlsx(dataSet, "Sustainability_Houses_Classification_Dataset.xlsx")

# Loading the dataset to avoid overriding issues
dataSet <- read.xlsx("Sustainability_Houses_Classification_Dataset.xlsx")


# MODEL DEVELOPMENT
library(caTools)
print(sum(dataSet$Classification == 1))
table(dataSet$Classification)
spl = sample.split(dataSet$HouseID, SplitRatio = 0.75)
Sustainability_Train = subset(dataSet, spl==TRUE)
Sustainability_Test = subset(dataSet, spl==FALSE)

# Building a Logistic Regression Model for CONSTRUCTION category
Construction_Model <- glm(Classification ~ 
                            Structure + 
                            Insulation +
                            Gardening +
                            Hygiene +
                            Power_management +
                            Sustainable_material +
                            Water_management+ 
                            Waste_management+ 
                            Airflow, data = Sustainability_Train, family = "binomial")
summary(Construction_Model)

# Training
Construction_Model_PredictTrain = predict(Construction_Model, type="response")
summary(Construction_Model_PredictTrain)
tapply(Construction_Model_PredictTrain, Sustainability_Train$Classification, mean)
table(Sustainability_Train$Classification, Construction_Model_PredictTrain > 0.5)

# Testing
Construction_Model_PredictTest = predict(Construction_Model, type="response", newdata=Sustainability_Test)
table(Sustainability_Test$Classification, Construction_Model_PredictTest > 0.5)

# Building a Logistic Regression Model for Electricity category
Electricity_Model <- glm(Classification ~
                           Power_management +
                           Temperature_Management +
                           Power_generation, data = Sustainability_Train, family = "binomial")
summary(Electricity_Model)

# Training
Electricity_Model_PredictTrain = predict(Electricity_Model, type="response")
summary(Electricity_Model_PredictTrain)
tapply(Electricity_Model_PredictTrain, Sustainability_Train$Classification, mean)
table(Sustainability_Train$Classification, Electricity_Model_PredictTrain > 0.5)

# Testing
Electricity_Model_PredictTest = predict(Electricity_Model, type="response", newdata=Sustainability_Test)
table(Sustainability_Test$Classification, Electricity_Model_PredictTest > 0.5)

# Building a Logistic Regression Model for SmartFeatures category
SmartFeatures_Model <- glm(Classification ~ Connectivity, data = Sustainability_Train, family = "binomial")
summary(SmartFeatures_Model)

# Training
SmartFeatures_Model_PredictTrain = predict(SmartFeatures_Model, type="response")
summary(SmartFeatures_Model_PredictTrain)
tapply(SmartFeatures_Model_PredictTrain, Sustainability_Train$Classification, mean)
table(Sustainability_Train$Classification, SmartFeatures_Model_PredictTrain > 0.5)

# Testing
SmartFeatures_Model_PredictTest = predict(SmartFeatures_Model, type="response", newdata=Sustainability_Test)
table(Sustainability_Test$Classification, SmartFeatures_Model_PredictTest > 0.5)

#  Construction Model Evaluation
library(ROCR)

ROCR_Construction_pred = prediction(Construction_Model_PredictTrain, Sustainability_Train$Classification)
ROC_Construction_Curve = performance(ROCR_Construction_pred, "tpr", "fpr")
plot(ROC_Construction_Curve, xlim = c(0, 1))
plot(ROC_Construction_Curve, colorize=TRUE, print.cutoffs.at=seq(0,1,1), text.adj=c(-0.2,0.7))

#  Electricity Model Evaluation
ROCR_Electricity_pred = prediction(Electricity_Model_PredictTrain, Sustainability_Train$Classification)
ROC_Electricity_Curve = performance(ROCR_Electricity_pred, "tpr", "fpr")
plot(ROC_Electricity_Curve, xlim = c(0, 1))
plot(ROC_Electricity_Curve, colorize=TRUE, print.cutoffs.at=seq(0,1,1), text.adj=c(-0.2,0.7))

#  Smart Features Model Evaluation
ROCR_SmartFeatures_pred = prediction(SmartFeatures_Model_PredictTrain, Sustainability_Train$Classification)
ROC_SmartFeatures_Curve = performance(ROCR_SmartFeatures_pred, "tpr", "fpr")
plot(ROC_SmartFeatures_Curve, xlim = c(0, 1))
plot(ROC_SmartFeatures_Curve, colorize=TRUE, print.cutoffs.at=seq(0,1,1), text.adj=c(-0.2,0.7))

# NOTE: Based on the results of all models evaluation, we have decided to classify the house as sustainable if probability is greater than 0.25

# Saving the models so that they can be loaded in shiny app
saveRDS(Construction_Model, "Construction_Model.rds")
saveRDS(Electricity_Model, "Electricity_Model.rds")
saveRDS(SmartFeatures_Model, "SmartFeatures_Model.rds")
