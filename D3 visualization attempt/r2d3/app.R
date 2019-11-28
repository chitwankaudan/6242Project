library(shiny)
library(r2d3)
library(dplyr)

setwd("~/Documents/GTA\ docs/6242/6242Project/D3\ visualization\ attempt/ourchord/")

migration <- read.csv('sortedsubset.csv')

# Define UI for application that draws a histogram
ui <- fluidPage(
  # Application title
  titlePanel("Interactive D3 Bar Chart"),
  inputPanel(
    numericInput("year", label = "Year:",
                 min = min(migration$year) , max = max(migration$year), value = min(migration$year), step = 1)
  ),
  d3Output("d3")
)


server <- function(input, output) {
  
  observeEvent(input$year, {
    cat(file=stderr(), "year selected: ", input$year, "\n")
   
  })
  
  observeEvent(input$year, {
    year_flows <<- migration %>%
                      filter(year == input$year) %>%
                      arrange(desc(flow)) %>%
                      top_n(50, flow)
    
    #print(year_flows)
    
    output$d3 <- renderD3(
      r2d3(data = year_flows, 'our_chord_tooltip.js', d3_version = "4", dependencies = 'd3.min.js', width=1000, height = 1500)
    )
    
  })
  
  observeEvent(input$source_target, {
    print(input$source_target)
  })
  
  observeEvent(input$both_unselected, {
    #remove waterfall plot
    print("both unselected")
  })
  
  flow <- reactiveValues(src=NULL, tgt=NULL)
  
  observeEvent(input$flow_clicked, {
    
    flow_info <<- req(input$flow_clicked)
    print(flow_info)
    #source_id <- as.numeric(flow_info[1])
    #target_id <- as.numeric(flow_info[2])
    #start_index <- 11
    #target_index <- start_index + target_id 
    #source_index <- start_index + source_id

    #flow$src <- flow_info[source_index]
    #flow$tgt <- flow_info[target_index]
    
    #cat("source:" , flow$src, '\n')
    #cat("target:", flow$tgt)
    
  })
  
  #observeEvent(input$matrix_names, {
    
  #  names <- req(input$matrix_names)
 #   
    
 # })
  

  
}


shinyApp(ui = ui, server = server)
