#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
library(dplyr)
library(plotly)
library(r2d3)
library(shiny)
library(shinyjs)
library(shinythemes)

Countries <- list(
  "AFG" = "Afghanistan",
  "AGO" = "Angola",
  "ALB" = "Albania",
  "ARG" = "Argentina",
  "ARM" = "Armenia",
  "AUS" = "Australia",
  "AUT" = "Austria",
  "AZE" = "Azerbaijan",
  "BDI" = "Burundi",
  "BEL" = "Belgium",
  "BEN" = "Benin",
  "BFA" = "Burkina Faso",
  "BGD" = "Bangladesh",
  "BGR" = "Bulgaria",
  "BHR" = "Bahrain",
  "BLR" = "Belarus",
  "BRA" = "Brazil",
  "BWA" = "Botswana",
  "CAF" = "Central African Republic",
  "CAN" = "Canada",
  "CHE" = "Switzerland",
  "CHL" = "Chile",
  "CHN" = "China",
  "CMR" = "Cameroon",
  "COD" = "Democratic Republic of the Congo",
  "COL" = "Colombia",
  "CRI" = "Costa Rica",
  "CUB" = "Cuba",
  "CYP" = "Cyprus",
  "CZE" = "Czechia",
  "DEU" = "Germany",
  "DJI" = "Djibouti",
  "DNK" = "Denmark",
  "DOM" = "Dominican Republic",
  "DZA" = "Algeria",
  "ECU" = "Ecuador",
  "EGY" = "Egypt",
  "ERI" = "Eritrea",
  "ESP" = "Spain",
  "EST" = "Estonia",
  "ETH" = "Ethiopia",
  "FIN" = "Finland",
  "FRA" = "France",
  "GEO" = "Georgia",
  "GHA" = "Ghana",
  "GIN" = "Guinea",
  "GNB" = "Guinea-Bissau",
  "GRC" = "Greece",
  "GTM" = "Guatemala",
  "HND" = "Honduras",
  "HRV" = "Croatia",
  "HTI" = "Haiti",
  "IDN" = "Indonesia",
  "IND" = "India",
  "IRQ" = "Iraq",
  "ISR" = "Israel",
  "ITA" = "Italy",
  "JOR" = "Jordan",
  "JPN" = "Japan",
  "KAZ" = "Kazakhstan",
  "KEN" = "Kenya",
  "KHM" = "Cambodia",
  "KWT" = "Kuwait",
  "LBN" = "Lebanon",
  "LBY" = "Libya",
  "LKA" = "Sri Lanka",
  "LSO" = "Lesotho",
  "LTU" = "Lithuania",
  "LUX" = "Luxembourg",
  "LVA" = "Latvia",
  "MAR" = "Morocco",
  "MDG" = "Madagascar",
  "MEX" = "Mexico",
  "MKD" = "North Macedonia",
  "MLI" = "Mali",
  "MNG" = "Mongolia",
  "MOZ" = "Mozambique",
  "MRT" = "Mauritania",
  "MWI" = "Malawi",
  "MYS" = "Malaysia",
  "NAM" = "Namibia",
  "NER" = "Niger",
  "NGA" = "Nigeria",
  "NIC" = "Nicaragua",
  "NLD" = "Netherlands",
  "NPL" = "Nepal",
  "NZL" = "New Zealand",
  "OMN" = "Oman",
  "PAK" = "Pakistan",
  "PAN" = "Panama",
  "PER" = "Peru",
  "PHL" = "Philippines",
  "PNG" = "Papua New Guinea",
  "POL" = "Poland",
  "PRT" = "Portugal",
  "PRY" = "Paraguay",
  "QAT" = "Qatar",
  "ROU" = "Romania",
  "RWA" = "Rwanda",
  "SAU" = "Saudi Arabia",
  "SEN" = "Senegal",
  "SLE" = "Sierra Leone",
  "SLV" = "El Salvador",
  "SVK" = "Slovakia",
  "SVN" = "Slovenia",
  "SWE" = "Sweden",
  "TCD" = "Chad",
  "THA" = "Thailand",
  "TJK" = "Tajikistan",
  "TKM" = "Turkmenistan",
  "TUN" = "Tunisia",
  "TUR" = "Turkey",
  "UGA" = "Uganda",
  "UKR" = "Ukraine",
  "UZB" = "Uzbekistan",
  "ZAF" = "South Africa",
  "ZMB" = "Zambia",
  "ZWE" = "Zimbabwe")

# Define UI for application that draws a histogram
ui <- fluidPage(theme = shinytheme("spacelab"),
  
  useShinyjs(),
   
   # Application title
   titlePanel(h1("Migration Flow Visualization", align = "center")),
   br(),
   # Sidebar with a slider input for number of bins 
   sidebarLayout(
      sidebarPanel(
        h3("Instructions:"),
        h5("1. Select the year you would like to visualize."),
        h5("2. First on the corresponding chord diagram select one country from the base as a source. Then select another country as a target."),
        h5("3. A valid selection will render a waterfall chart below the chord diagram."),
        h5("4. Each column, ordered by magnitude, represents the contribution of a variable to this flows prediction."),
        h5("5. Another country selection will render the diagram in its orginal state."),
        br(),
        numericInput("year",
                     "Please select the year you would like to visualize (1960 to 2014, inclusive):",
                     min = min(master_table$year),
                     max = max(master_table$year),
                     step = 1, 
                     value = character(0)),
        h3("Selected Countries:"),
        textOutput("no_selection"),
        tags$head(tags$style("#no_selection{color: black;
                             font-size: 16px;
                             }"
                         )
        ),
        textOutput("source"),
        tags$head(tags$style("#source{color: black;
                             font-size: 14px;
                             }"
                         )
        ),
        br(),
        textOutput("target"),
        tags$head(tags$style("#target{color: black;
                             font-size: 14px;
                             }"
                         )
        ),
        br(),
        textOutput("actual_value"),
        tags$head(tags$style("#actual_value{color: black;
                             font-size: 14px;
                             }"
                         )
        ),
        br(),
        textOutput("pred_value"),
        tags$head(tags$style("#pred_value{color: black;
                             font-size: 14px;
                             }"
                         )
        ),
        width = 4
      ),
      
      # Show a plot of the generated distribution
      mainPanel(
        d3Output("d3", width = "100%", height = "600px")
      )
   ),
  br(),
  fluidRow(
    column(12, align = "center", textOutput("bad")),
    tags$head(tags$style("#bad{color: black;
                         font-size: 20px;
                         }"
                         )
    )
    ),
  fluidRow(
    column(12, align = "center", plotlyOutput("waterfallPlot"))
  ),
  br()
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  observeEvent(input$year, {
    data <- subset(master_table, year == input$year)
    if(dim(data)[1] != 0) {
      year_flows <- data %>%
        arrange(desc(flow_prediction)) %>%
        top_n(40, flow_prediction)
      
      output$d3 <- renderD3(
        r2d3(data = year_flows, '~/Documents/DVA/our_chord.js', d3_version = "4", css = 'styles.css')
      )
      output$no_selection <- renderText("No countries have been selected.")
      shinyjs::show("no_selection")
      shinyjs::hide("waterfallPlot")
      shinyjs::hide("source")
      shinyjs::hide("target")
      shinyjs::hide("pred_value")
      shinyjs::hide("actual_value")
    }
  })
  
  observeEvent(input$source_target, {
    output$source <- renderText(paste("Source: ", Countries[input$source_target[1]]))
    output$target <- renderText(paste("Target: ", Countries[input$source_target[2]]))
    output$pred_value <- renderText(paste("Predicted value: ", round(subset(master_table, year == input$year & src_abb == input$source_target[1] & tgt_abb == input$source_target[2])$flow_prediction, 2), " migrants"))
    output$actual_value <- renderText(paste("Actual value: ", round(subset(master_table, year == input$year & src_abb == input$source_target[1] & tgt_abb == input$source_target[2])$flow, 2), " migrants"))
    shinyjs::hide("no_selection")
    shinyjs::hide("no_selection")
    shinyjs::show("source")
    shinyjs::show("target")
    shinyjs::show("pred_value")
    shinyjs::show("actual_value")
    data <- subset(master_table, year == input$year)
    if(dim(data)[1] != 0) {
      data <- subset(data, src_abb == input$source_target[1])
      data <- subset(data, tgt_abb == input$source_target[2])
      data <- data[1,]
      if(dim(data)[1] != 0){
        values <- data[45:82]
        labels <- names(values)
        values <- round(unlist(unname(values)), digits = 2)
        absv <- abs(values)
        df = data.frame(labels, values, absv)
        df <- df[order(-absv),]
        df$absv <- NULL
        y <- df$values
        y <- c(data[1,83], y)
        y <- c(y, sum(y))
        x <- labels
        x <- c("Intercept", x, "Predicted Flow Estimate")
        datap <- data.frame(x=factor(x,levels=x),y)
        ax <- list(
          title = "Individual Source and Target Factors",
          zeroline = FALSE,
          showline = TRUE,
          showticklabels = FALSE,
          showgrid = TRUE
        )
        p <- plot_ly(datap, type = "waterfall", x = ~x, y = ~y, measure = ~c(rep(c("relative"), 39), "total"),
                     decreasing = list(marker = list(color = "navy")),
                     increasing = list(marker = list(color = "teal")),
                     totals = list(marker = list(color = "maroon")),
                     text = paste("Variable: ", x,
                                  "<br>Log Value: ", round(y, 2)),
                     hoverinfo = 'text') %>%
          layout(title = "Waterfall Chart for Log Predicted Values", xaxis = ax, yaxis = list(title = "Log of Prediction Factor Values"),
                 autosize = F, width = 800, height = 400)
        output$waterfallPlot <- renderPlotly({
          p
        })
        shinyjs::show("waterfallPlot")
        shinyjs::hide("bad")
      } else {
        output$bad <-renderText("There is no data for this selection. Try switching your source and target or choose a new set of countries.")
        shinyjs::show("bad")
        shinyjs::hide("waterfallPlot")
      }
    }
  })
  
  observeEvent(input$both_unselected, {
    output$no_selection <- renderText("No countries have been selected.")
    shinyjs::show("no_selection")
    shinyjs::hide("source")
    shinyjs::hide("target")
    shinyjs::hide("pred_value")
    shinyjs::hide("actual_value")
    shinyjs::hide("waterfallPlot")
  })

   #output$waterfallPlot <- renderPlot({
   #})
}

# Run the application 
shinyApp(ui = ui, server = server)

