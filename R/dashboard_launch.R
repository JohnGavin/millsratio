#' Launch Mills Ratio Interactive Dashboard
#'
#' @description
#' Launches an interactive Shiny dashboard for exploring Mills ratios
#' and tail thickness behavior across different distributions.
#'
#' @param port Port number for the Shiny app (default = NULL for auto-selection)
#' @param launch_browser Logical; if TRUE, opens dashboard in browser
#' @param host Host address (default = "127.0.0.1" for local access)
#'
#' @return Runs the Shiny application
#' @export
#'
#' @examples
#' \dontrun{
#' # Launch the dashboard
#' launch_dashboard()
#'
#' # Launch on specific port
#' launch_dashboard(port = 8080)
#' }
launch_dashboard <- function(port = NULL,
                           launch_browser = TRUE,
                           host = "127.0.0.1") {

  # Check if shiny is available
  if (!requireNamespace("shiny", quietly = TRUE)) {
    stop("Package 'shiny' is required to run the dashboard. Please install it.")
  }

  if (!requireNamespace("bslib", quietly = TRUE)) {
    stop("Package 'bslib' is required for the dashboard UI. Please install it.")
  }

  # Get the app directory
  app_dir <- system.file("shiny", package = "millsratio")

  if (app_dir == "") {
    # Development mode - use local path
    app_dir <- file.path(getwd(), "inst", "shiny")
    if (!dir.exists(app_dir)) {
      stop("Dashboard app directory not found. Please ensure the package is properly installed.")
    }
  }

  # Check if app.R exists
  app_file <- file.path(app_dir, "app.R")
  if (!file.exists(app_file)) {
    # If app.R doesn't exist, create it from ui.R and server.R
    ui_file <- file.path(app_dir, "ui.R")
    server_file <- file.path(app_dir, "server.R")

    if (file.exists(ui_file) && file.exists(server_file)) {
      message("Launching dashboard from ui.R and server.R...")
    } else {
      stop("Dashboard files not found. Creating default dashboard...")
    }
  }

  message("Launching Mills Ratio Dashboard...")
  message("Navigate to the displayed URL in your browser.")
  message("Press Ctrl+C or Esc to stop the dashboard.\n")

  # Handle browser launch more robustly
  browser_func <- if (isTRUE(launch_browser)) {
    # Check if browser option is valid
    browser_opt <- getOption("browser")
    if (is.null(browser_opt) ||
        (is.character(browser_opt) && nchar(browser_opt) == 0)) {
      # Browser option is empty, don't launch
      message("Note: Browser auto-launch disabled (no default browser set)")
      message("Please navigate manually to the URL shown above")
      FALSE
    } else {
      TRUE
    }
  } else {
    FALSE
  }

  # Run the app
  shiny::runApp(
    appDir = app_dir,
    port = port,
    launch.browser = browser_func,
    host = host
  )
}

#' Get Dashboard About Information
#'
#' @return List with dashboard metadata
#' @export
dashboard_about <- function() {
  list(
    title = "Mills Ratio Interactive Dashboard",
    version = utils::packageVersion("millsratio"),
    author = "John Gavin",
    description = "Interactive exploration of Mills ratios and tail thickness",
    reference = "Based on John D. Cook's blog post (2026-01-21)",
    url = "https://www.johndcook.com/blog/2026/01/21/mills-ratio/"
  )
}

#' Launch Dashboard Without Browser
#'
#' @description
#' Convenience function to launch dashboard without attempting to open browser.
#' Useful when browser settings are not configured.
#'
#' @param port Port number for the Shiny app (default = NULL for auto-selection)
#' @param host Host address (default = "127.0.0.1" for local access)
#'
#' @return Runs the Shiny application
#' @export
#'
#' @examples
#' \dontrun{
#' # Launch without browser
#' launch_dashboard_no_browser()
#' # Then manually open the displayed URL in your browser
#' }
launch_dashboard_no_browser <- function(port = NULL, host = "127.0.0.1") {
  launch_dashboard(port = port, launch_browser = FALSE, host = host)
}

#' Launch Simplified Dashboard
#'
#' @description
#' Launch the simplified, content-focused version of the Mills ratio dashboard.
#' This version emphasizes clarity and substance over visual effects.
#'
#' @param port Port number for the Shiny app (default = 4628)
#' @param launch_browser Launch browser? (default = FALSE)
#' @param host Host address (default = "127.0.0.1" for local access)
#'
#' @return Runs the simplified Shiny application
#' @export
#'
#' @examples
#' \dontrun{
#' # Launch simplified dashboard
#' launch_dashboard_simple()
#' }
launch_dashboard_simple <- function(port = 4628,
                                  launch_browser = FALSE,
                                  host = "127.0.0.1") {

  # Get the installed shiny directory
  app_dir <- system.file("shiny", package = "millsratio")

  if (app_dir == "") {
    stop("Could not find shiny app directory. Is the package installed?")
  }

  # Create temporary app.R that explicitly loads simplified version
  temp_dir <- tempfile()
  dir.create(temp_dir)

  # Copy all files to temp directory
  file.copy(list.files(app_dir, full.names = TRUE),
            temp_dir,
            recursive = TRUE)

  # Create new app.R that uses simplified version
  app_content <- '
# Simplified Mills Ratio Dashboard
library(shiny)
library(bslib)
library(plotly)
library(DT)
library(millsratio)
library(dplyr)
library(tidyr)
library(ggplot2)

# Source simplified UI and server
source("ui_simple.R")
source("server_simple.R")

# Run app
shinyApp(ui = ui, server = server)
'

  writeLines(app_content, file.path(temp_dir, "app_simple.R"))

  # Handle browser launch
  browser_func <- if (launch_browser) {
    browser_opt <- getOption("browser", "")
    if (browser_opt == "") {
      message("Note: Browser auto-launch disabled (no default browser set)")
      message("Please navigate manually to: http://", host, ":", port)
      FALSE
    } else {
      TRUE
    }
  } else {
    FALSE
  }

  # Run the app
  shiny::runApp(
    appDir = file.path(temp_dir, "app_simple.R"),
    port = port,
    launch.browser = browser_func,
    host = host
  )
}