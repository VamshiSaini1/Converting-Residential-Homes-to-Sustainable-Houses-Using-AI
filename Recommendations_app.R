
library(shiny)
library(openxlsx)
library(tidyverse)
library(dplyr)
library(purrr)
library(utils)

# Define UI for application
ui <- fluidPage(
  
  # Additional CSS styles for color theme and sidebar
  tags$style(HTML("
    body {
      background-color: #f0f9f0; /* Light green background */
      font-family: Arial, sans-serif; /* Modern font */
    }
    
    .title-panel {
      text-align: center;
      color: #008000; /* Dark green text color */
      margin-bottom: 20px; /* Add some space below title */
    }
    
    .sidebar {
      background-color: #ffffff; /* White sidebar background */
      border-right: 1px solid #ddd; /* Light gray border */
      box-shadow: 0 0 10px rgba(0,0,0,0.1); /* Shadow effect */
      padding: 20px; /* Add some padding */
    }
    
    .sidebar .form-group {
      margin-bottom: 20px; /* Add space between inputs */
    }
    
    .sidebar select {
      width: 100%; /* Make select inputs full width */
      border: 1px solid #ccc; /* Light gray border */
      border-radius: 5px; /* Rounded corners */
      padding: 8px; /* Add padding */
      font-size: 16px; /* Increase font size */
    }
    
    .sidebar .help-block {
      color: #666666; /* Gray color for help text */
      font-size: 14px; /* Decrease font size for help text */
    }
    
    .sidebar .action-button {
      width: 100%; /* Make button full width */
      background-color: #008000; /* Dark green button background */
      color: #ffffff; /* White button text color */
      border: none; /* Remove button border */
      border-radius: 5px; /* Rounded corners */
      padding: 10px; /* Add padding */
      font-size: 16px; /* Increase font size */
      cursor: pointer; /* Add pointer cursor */
    }
    
    .sidebar .action-button:hover {
      background-color: #006400; /* Dark green background on hover */
    }
    
    .recommendation-card {
      margin: 10px;
      padding: 20px;
      border: 1px solid #ccc; /* Light gray border */
      border-radius: 5px; /* Rounded corners */
      background-color: #ffffff; /* White background */
      box-shadow: 0 4px 8px 0 rgba(0, 0, 0, 0.1); /* Shadow effect */
    }
    
    .recommendation-card h3 {
      color: #008000; /* Dark green heading color */
    }
    
    .recommendation-card p {
      color: #333333; /* Dark gray paragraph color */
    }
    
    .recommendation-card a {
      color: #006400; /* Dark green link color */
    }
  ")),
  
  # Application title
  div(class = "title-panel",
      titlePanel("Sustainable House Feature Recommendations", windowTitle = "Sustainable House Features")
  ),
  
  # Main layout divided into two parts: sidebarPanel and mainPanel
  sidebarLayout(
    
    # Sidebar panel for inputs
    sidebarPanel(
      class = "sidebar", # Add class to sidebar
      
      # Question 1: Select the category
      selectInput("category", "Select the Category:",
                  choices = c("Chemicals", "Construction", "Electricity", "Safety", "Smart Features")),
      
      # Question 2: Select the sub category
      uiOutput("sub_category"),
      
      # Question 3: Select the cost factor
      selectInput("Cost_Factor", "Select the Cost Rating:",
                  choices = c(1, 2, 3)),
      helpText("The higher the value, the more expensive and better sustainable features are recommended."),
      
      # Submit button
      actionButton("submit", "Submit", class = "action-button")
    ),
    
    # Main panel for displaying output
    mainPanel(
      # Output for displaying concatenated responses
      uiOutput("feature_recommendations")
    )
  )
)

# Define server logic
server <- function(input, output) {
  
  # Reactive expression for generating options for sub category based on selected category
  output$sub_category <- renderUI({
    category <- input$category
    choices <- switch(category,
                      "Chemicals" = c("Hygiene", "Power generation"),
                      "Construction" = c("Structure", "Water management", "Insulation", "Hygiene", "Airflow", "Gardening", "Power management", "Structure", "Sustainable material", "Waste management"),
                      "Electricity" = c("Power management", "Temperature Management", "Power generation"),
                      "Safety" = c("Filtration", "Flood control"),
                      "Smart Features" = c("Connectivity")
    )
    
    selectInput("sub_category", "Select the Sub Category:",
                choices = choices)
  })
  
  # Read Excel data outside observeEvent
  sustainability_features_final_data <- tryCatch({
    read.xlsx("Sustainability_Features_Dataset_With_Weights.xlsx", sheet=1)
  }, error = function(e) {
    NULL
  })
  
  # Reactive expression to store and concatenate user responses
  observeEvent(input$submit, {
    if(is.null(sustainability_features_final_data)) {
      output$feature_recommendations <- renderUI({
        HTML("Error: Unable to read the data file.")
      })
      return()
    }
    
    recommendation_function <- function(userCategory, userSubCategory, userCostFactorVal){
      filteredCostFactor <- c()
      filteredImplementation <- c()
      filteredPriority <- c("Very High", "High")
      
      if (userCostFactorVal == 1) {
        filteredCostFactor <- c("Low", "Moderate")
        filteredImplementation <- c("Easy", "Moderate")
      } else if (userCostFactorVal == 2) {
        filteredCostFactor <- c("Moderate", "Expensive")
        filteredImplementation <- c("Easy", "Moderate", "Hard")
      } else if (userCostFactorVal == 3) {
        filteredCostFactor <- c("Expensive", "Very Expensive")
        filteredImplementation <- c("Easy", "Moderate", "Hard", "Very Hard")
      }
      
      result <- NULL  # Initialize result to NULL
      for (priority in c("Very High", "High", "Moderate", "Low")) {
        result <- sustainability_features_final_data %>%
          filter(Category == userCategory &
                   Sub_Category == userSubCategory &
                   Cost_Factor %in% filteredCostFactor &
                   Priority == priority &  # Set priority to current level
                   Implementation %in% filteredImplementation)
        if (nrow(result) > 0) {
          break  # If non-empty result is found, exit the loop
        }
        else {
          # Filter the top 5 weighted features based on Calc_weights
          result <- sustainability_features_final_data %>%
            filter(Category == userCategory &
                     Sub_Category == userSubCategory) %>%
            arrange(desc(Calc_weights)) %>%
            slice_head(n = 5)
        }
      }
      return(result)
    }
    
    features_output <- recommendation_function(input$category, input$sub_category, input$Cost_Factor)
    if (nrow(features_output) == 0) {
      output_to_display <- winDialog(type = "message", message = "Sorry, we could not find the matching recommendations, please try using different filters")
    } else {
      output_to_display <- lapply(1:nrow(features_output), function(i) {
        div(
          class = "recommendation-card", # Add class to card
          h3(features_output$Feature[i]),
          p(features_output$Description[i]),
          p(HTML(paste("<b>Cost: </b>", features_output$Cost_Factor[i]))),
          p(HTML(paste("<b>Implementation Difficulty: </b>", features_output$Implementation[i]))),
          HTML(paste("Click <a href='", features_output$link[i], "' target='_blank'>here</a> to find out more"))
        )
      })
    }
    
    output$feature_recommendations <- renderUI({
      output_to_display
    })
    
  })
}

# Run the application
shinyApp(ui = ui, server = server)
