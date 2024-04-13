library(shiny)
library(bslib)

ui <- fluidPage(
  titlePanel("Green Expectations", windowTitle = "Green Expectations"),
  theme = bs_theme(bootswatch = "minty"), # Using a Bootstrap theme for better visual appearance
  
  tags$head(
    tags$style(HTML("
      body {
        font-family: 'Arial', sans-serif;
        margin: 0;
        padding: 0;
        box-sizing: border-box;
        color: #333;
      }
      .header {
        background-color: #4CAF50;
        color: #fff;
        padding: 20px;
        text-align: center;
        font-size: 24px;
      }
      .content {
        padding: 20px;
        background-color: #f0f9f0;
        line-height: 1.6;
      }
      .btn-container {
        display: flex;
        justify-content: center;
        align-items: center; /* Center the content vertically */
        height: 250px; /* Height of the background */
        width: 100%; /* Make background full width */
        margin-top: 40px;
        gap: 30%;
        background: linear-gradient(rgba(255, 255, 255, 0.5), rgba(255, 255, 255, 0.5)), url('https://ecoreports.com.au/wp-content/uploads/2021/09/pic-eco-friendly-home.jpg') no-repeat center center fixed; 
        background-size: cover;
        padding: 20px;
      }
      .btn {
        padding: 10px 20px;
        font-size: 18px;
        border: none;
        border-radius: 5px;
        color: white;
        cursor: pointer;
        text-decoration: none; /* remove underline from links */
      }
      .recommend-btn {
        background-color: #4CAF50;
      }
      .classify-btn {
        background-color: #2196F3;
      }
    "))
  ),
  
  div(class = "header", "Welcome to Green Expectations"),
  div(class = "content",
      h1("Why Sustainability is Important"),
      p("Sustainability is crucial for ensuring that we have and will continue to have, the water, materials, and resources to protect human health and our environment. Sustainable homes play a pivotal role in this by minimizing waste, reducing consumption, and preserving nature. They not only contribute to a healthier planet but also offer economic benefits by lowering energy costs and creating more durable and long-lasting living environments."),
      p("By focusing on sustainable development, we're not just investing in our planet's future but also in our own. The concept of sustainability introduces innovative technologies and practices that can make our lives more efficient, reduce our carbon footprint, and promote a balance with nature. Embracing sustainability in our homes is a step towards a more responsible and environmentally conscious way of living."),
      div(class = "btn-container",
          a(href = "https://greenexpectationsteam5.shinyapps.io/greenexpectationsteam5/", class = "btn recommend-btn", "Get Sustainability Recommendations"),
          a(href = "https://greenexpectationsteam5.shinyapps.io/greenexpectationsteam5_classification/", class = "btn classify-btn", "Classify Your House")
      )
  )
)

server <- function(input, output, session) {}

shinyApp(ui = ui, server = server)


