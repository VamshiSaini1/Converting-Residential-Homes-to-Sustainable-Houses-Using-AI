library(shiny)
library(dplyr)
library(tidyr)
library(openxlsx)  

# Define UI
ui <- fluidPage(
  
  tags$head(
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
    
    .checkbox { margin-right: 10px; }
    .checkbox label { width: 50%; } /* Set the label width for better alignment */
    .checkbox-inline { width: 30%; display: inline-block; margin-bottom: 10px; margin-top: 10px; } /* Adjust width and margin */
    .checkbox-container { padding-top: 20px; } /* Add space before displaying checkboxes */
  "))
  ),
  
  # Application title
  div(class = "title-panel",
      titlePanel("Welcome to Green House Sustainability Classification", windowTitle = "Sustainable House Classification")
  ),
  
  sidebarLayout(
    sidebarPanel(
      class = "sidebar",
      selectInput("options", "Select the Aspect of Sustainability:", 
                  choices = c("Choose..." = "", "Construction" = "Construction", "Electricity" = "Electricity", "Smart Features" = "Smart Features")),
      actionButton("submit", "Submit", class = "action-button"),
      br(), # Line break for better separation
      hr(), # Horizontal rule for visual separation
      #p("Select the category and features of your house to predict its sustainability."),
      HTML(paste0("Select the category and features of the house to predict its sustainability. Please navigate to <a href='https://greenifyai.com/article2_1.php' target='_blank'>Green Expectations</a> to find out more about features."))
    ),
    mainPanel(
      h4("Prediction Result:"),
      verbatimTextOutput("predictionResult"),
      hr()
    )
  ),
  
  div(class = "checkbox-container", uiOutput("checkboxes"))  # Add space before displaying checkboxes
)

# Define server logic
server <- function(input, output, session) {
  
  # Load the dataset
  dataset <- reactive({
    req(file.exists("Sustainability_Features_Dataset_With_Weights.xlsx"))
    read.xlsx("Sustainability_Features_Dataset_With_Weights.xlsx")
  })
  
  # Dynamically create checkbox options based on selected category
  output$checkboxes <- renderUI({
    req(input$options != "")  # Require a selection to proceed
    choices <- dataset() %>% 
      filter(Category == input$options) %>%
      pull(Feature)
    checkboxGroupInput("checkboxes", "Select features (multiple allowed):", choices = choices, inline = TRUE)
  })
  
  observeEvent(input$submit, {
    req(input$options, input$checkboxes)  # Ensure inputs are selected
    
    # Load the selected model based on category
    model_path <- switch(input$options,
                         "Construction" = "Construction_Model.rds",
                         "Electricity" = "Electricity_Model.rds",
                         "Smart Features" = "SmartFeatures_Model.rds")
    
    if (!file.exists(model_path)) {
      output$predictionResult <- renderText("Model file is missing.")
      return()
    }
    
    selected_model <- readRDS(model_path)
    
    # Prepare data for prediction
    data_for_prediction <- dataset() %>%
      filter(Feature %in% input$checkboxes) %>%
      group_by(Sub_Category) %>%
      summarise(Total_Score = sum(Calc_weights, na.rm = TRUE)) %>%
      spread(key = Sub_Category, value = Total_Score, fill = 0)
    
    # Ensure all expected columns are present for the model
    expected_columns <- names(selected_model$coefficients)[-1]
    missing_columns <- setdiff(expected_columns, names(data_for_prediction))
    data_for_prediction[missing_columns] <- 0
    
    # Replace spaces with underscores in column names
    names(data_for_prediction) <- gsub(" ", "_", names(data_for_prediction))
    
    # Prediction
    prediction <- predict(selected_model, newdata = data_for_prediction, type = "response")
    
    # Output the prediction
    output$predictionResult <- renderText({
      if (prediction > 0.2) "The house is classified as: Sustainable" else "The house is classified as: Not Sustainable"
    })
  })
}

# Run the application
shinyApp(ui = ui, server = server)