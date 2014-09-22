## ui.R
library(shiny)
library(raadtools)
fs <- icefiles()
mindate <- as.Date(min(fs$date))
maxdate <- as.Date(max(fs$date))
shinyUI(pageWithSidebar(
  headerPanel("NSIDC daily sea ice"),
  sidebarPanel(dateRangeInput("dateRange", "Dates:",
                              start = maxdate - 365.25 / 2, end = maxdate, 
                              min = mindate, max = maxdate, separator = "and")
  ),
  mainPanel(plotOutput("rasterPlot"))))


## server.R                                                           
library(shiny)
library(raadtools)
strf <- "NSIDC_%d_%b_%Y"
shinyServer(function(input, output) {
  output$rasterPlot <- renderPlot({
    dates <- input$dateRange
    x <- readice(dates)
    names(x) <- format(getZ(x), strf)
    plot(x)
  })})
