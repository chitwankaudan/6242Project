library(shiny)
library(r2d3)
library(dplyr)

migration <- read.csv('test_migration_set.csv')

# Define UI for application that draws a histogram
ui <- fluidPage(
  # Application title
  titlePanel("Chord Diagram"),
  inputPanel(
    numericInput("year", label = "Year:",
                 min = min(migration$year0) , max = max(migration$year0), value = min(migration$year0), step = 1)
  ),
  d3Output("d3")
)


server <- function(input, output) {
  
  observeEvent(input$year, {
    cat(file=stderr(), "year selected: ", input$year, "\n")
   
  })
  
  observeEvent(input$year, {
    year_flows <<- migration %>%
                      filter(year0 == input$year) %>%
                      arrange(desc(flow)) %>%
                      top_n(50, flow)
    
    #print(year_flows)
    
    output$d3 <- renderD3(
      r2d3(data = year_flows, 'our_chord.js', d3_version = "4", css = 'styles.css')
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
