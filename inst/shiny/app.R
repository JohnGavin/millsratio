# Mills Ratio Interactive Dashboard
# Main Shiny Application

# Load required libraries
library(shiny)
library(bslib)
library(plotly)
library(DT)
library(millsratio)  # Load via library(), not devtools::load_all()
library(dplyr)
library(tidyr)
library(ggplot2)

# Use simplified UI and server for cleaner experience
source("ui_simple.R")
source("server_simple.R")

# Create and run the app
shinyApp(ui = ui, server = server)