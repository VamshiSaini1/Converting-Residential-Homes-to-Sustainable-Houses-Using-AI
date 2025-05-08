# Convert Residential Houses into Sustainable Homes Using AI

## 🧠 Motivation and Overview

Our project aims to transform how individuals assess and improve the sustainability of their homes using AI. Initially considering a chatbot approach, we pivoted to a modern web-based application due to data constraints and academic requirements. The result is a functional, user-friendly platform that offers customized, impactful recommendations to help users enhance the environmental efficiency of their residences.

---

## 🔍 Related Work

This project builds on the growing recognition that data, when used correctly, can drive large-scale societal change. By applying AI and data analytics techniques to sustainability, we aimed to create a tool that is both meaningful and actionable.

---

## ❓ Initial Research Question

**"How can we guide users to make their homes more sustainable?"**

Originally, a chatbot was proposed using R. However, due to the lack of structured data and limitations of the R ecosystem for NLP-based applications, we switched to building a more structured AI-driven recommendation application.

---

## 🗂️ Data Collection

### Data Sources
- Glossary website recommended by the project admin.
- Manual extraction of 100 features related to sustainable housing.

### Data Enhancement
- Categorized features into main and sub-categories.
- Added metadata such as Priority, Implementation, Cost Factor, and Usage.
- Created synthetic data using statistical sampling techniques.

---

## 📊 Exploratory Data Analysis

### Step 1: Manual Data Gathering
Manual review and entry of 100 key features from the glossary site into an Excel spreadsheet.

### Step 2: Feature Structuring
Each feature classified under:
- **Priority**
- **Implementation**
- **Cost Factor**
- **Usage**

Research from trusted sources (websites, videos, articles) was conducted to justify each classification.

### Step 3: Feature Weight Calculation

Weights were assigned as follows:
- **Priority:** Very High (0.3333), High (0.2222), Medium (0.1111), Low (0)
- **Implementation:** Easy (0.3333), Moderate (0.2222), Hard (0.1111), Very Hard (0)
- **Cost Factor:** Low (0.3333), Moderate (0.2222), Expensive (0.1111), Very Expensive (0)

R code was written to compute the final weight per feature.

### Step 4: Generating a Synthetic Dataset

- **Dataset Size:** 10,000 houses
- Each house: Binary presence (`yes`/`no`) of each of the 100 features
- Stored in: `Sustainability_Houses_Dataset.xlsx`

### Step 5: Calculating Sustainability Scores

Using the calculated weights, each house is scored:
- **Total Sustainability Score**
- **Individual Sub-category Scores**

These scores drive the AI-based recommendation engine.

---

## 🧾 Tools and Technologies

- **Language:** R
- **Libraries:** `openxlsx`, `dplyr`, `purrr`, `tidyverse`
- **File Formats:** `.xlsx`
- **Data Generation:** Sampling functions for synthetic data
- **Development Platform:** RStudio

---

## 📁 Files
  - **Sustainability\_Features\_Data.xlsx**: This file contains the raw data extracted from the glossary site, prior to any data analysis or manipulation
  - **Sustainability\_Houses\_Dataset.xlsx**: This file holds the randomly generated houses data, before any additional processing or modifications.
  - **Sustainability\_Features\_Dataset\_With\_Weights.xlsx**: This file contains the features dataset with weights assigned based on their priority, implementation, cost factor, and usage.
  - **Sustainability\_Houses\_Dataset\_With\_Scores.xlsx**: This file includes the houses dataset, with calculated sustainability scores and individual subcategory scores.
  - **Sustainability\_Houses\_Classification\_Dataset.xlsx**: This dataset contains the houses data after normalization and classification, labeling the houses based on sustainability levels.
  - **Team5\_Sustainable\_Houses\_main.R**: This R script file handles the primary data analysis operations.
  - **SustainableHousesClassification.R**: This R script is dedicated to model building for classifying houses based on their sustainability.
  - **HomeApp.R**, **ClassificationApp.R**, **Recommendations\_app.R**: These files correspond to the Shiny App components, with each app serving a specific function related to home sustainability, classification, and recommendations.


## 🏁 Conclusion
This project demonstrates the potential of AI and structured data in tackling sustainability challenges. Despite data limitations and platform restrictions, our pivot from chatbot to recommendation engine allowed us to deliver a solution that is scalable, educational, and impactful.
