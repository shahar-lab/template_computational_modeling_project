library(shiny)
library(ggplot2)
library(splines)
library(tidyr)
library(dplyr)

ui <- fluidPage(
  titlePanel("Spline Basis Functions Viewer"),
  
  sidebarLayout(
    sidebarPanel(
      numericInput("num_obs", "Number of Observations:", value = 100, min = 10),
      numericInput("num_knots", "Number of Knots:", value = 4, min = 1),
      actionButton("update", "Update Plot")
    ),
    
    mainPanel(
      plotOutput("basisPlot")
    )
  )
)

server <- function(input, output) {
  
  basis_data <- reactive({
    input$update  # trigger only when button is clicked
    
    isolate({
      x <- seq(0, 1, length.out = input$num_obs)
      basis_matrix <- bs(x, df = input$num_knots)
      
      basis_df <- as.data.frame(basis_matrix)
      basis_df$x <- x
      
      # Convert to long format for ggplot
      basis_long <- basis_df %>%
        pivot_longer(-x, names_to = "basis", values_to = "value")
      
      basis_long
    })
  })
  
  output$basisPlot <- renderPlot({
    ggplot(basis_data(), aes(x = x, y = value, color = basis)) +
      geom_line(size = 1) +
      theme_minimal() +
      labs(title = "Spline Basis Functions",
           x = "x",
           y = "Basis Value",
           color = "Basis")
  })
}

shinyApp(ui, server)
