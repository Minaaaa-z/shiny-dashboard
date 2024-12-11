# Load required packages
required_packages <- c(
  "shiny", "shinydashboard", "ggplot2", "dplyr", 
  "leaflet", "plotly", "gtable", "grid"
)

# Check and install missing packages
needed <- required_packages[!sapply(required_packages, require, character.only = TRUE)]
if (length(needed) > 0) {
  install.packages(needed, repos = "https://cloud.r-project.org")
}

# Load required libraries
lapply(required_packages, library, character.only = TRUE)

library(rsconnect)

# Set ShinyApps.io account info
rsconnect::setAccountInfo(
  name = "mianyuzhou", 
  token = "B9F0F3E23B2EF8D9368933DBBADD8475", 
  secret = "Yfl+vazT1Vz/awEoV4NTJq+OUEcdS31uCAkO1c9s"
)
rsconnect::deployApp() # Replace with your app's path

# Debugging messages
message("Starting app...")

# Define GitHub URLs for datasets
github_urls <- list(
  country1 = "https://github.com/Minaaaa-z/shiny-app-data/raw/refs/heads/main/1.%20country_inflow_outflow.rds",
  country2 = "https://github.com/Minaaaa-z/shiny-app-data/raw/refs/heads/main/2.%20country_inflow_outflow_ind.rds",
  country3 = "https://github.com/Minaaaa-z/shiny-app-data/raw/refs/heads/main/3.%20country_inflow_outflow_skill.rds",
  pairwise4 = "https://github.com/Minaaaa-z/shiny-app-data/raw/refs/heads/main/4.%20pairwise_flows.rds",
  pairwise5 = "https://github.com/Minaaaa-z/shiny-app-data/raw/refs/heads/main/5.%20pairwise_flows_ind.rds",
  pairwise6 = "https://github.com/Minaaaa-z/shiny-app-data/raw/refs/heads/main/6.%20pairwise_flows_skill.rds"
)

# Function to load datasets from GitHub
load_github_data <- function(url) {
  temp_file <- tempfile()
  tryCatch({
    download.file(url, temp_file, mode = "wb")
    data <- readRDS(temp_file)
    unlink(temp_file) # Clean up temporary file
    return(data)
  }, error = function(e) {
    message(paste("Error loading data from URL:", url, "\n", e))
    return(NULL)
  })
}

# Define UI
ui <- dashboardPage(
  dashboardHeader(title = "Test App"),
  dashboardSidebar(disable = TRUE),
  dashboardBody(
    fluidRow(
      box(title = "Welcome", width = 12, status = "primary", "App loaded successfully!")
    ),
    fluidRow(
      box(title = "Dataset Status", width = 12, status = "info",
          verbatimTextOutput("dataset_status"))
    )
  )
)

# Define Server
server <- function(input, output, session) {
  message("Server started")
  
  # Reactive values to store datasets
  datasets <- reactiveValues(
    country1 = NULL,
    country2 = NULL,
    country3 = NULL,
    pairwise4 = NULL,
    pairwise5 = NULL,
    pairwise6 = NULL
  )
  
  # Load datasets reactively
  observe({
    datasets$country1 <- load_github_data(github_urls$country1)
    datasets$country2 <- load_github_data(github_urls$country2)
    datasets$country3 <- load_github_data(github_urls$country3)
    datasets$pairwise4 <- load_github_data(github_urls$pairwise4)
    datasets$pairwise5 <- load_github_data(github_urls$pairwise5)
    datasets$pairwise6 <- load_github_data(github_urls$pairwise6)
    message("Datasets loaded successfully.")
  })
  
  # Output dataset loading status
  output$dataset_status <- renderPrint({
    lapply(datasets, function(data) {
      if (is.null(data)) {
        return("Dataset failed to load.")
      }
      paste("Dataset loaded with", nrow(data), "rows and", ncol(data), "columns.")
    })
  })
}

# Create Shiny App
shinyApp(ui = ui, server = server)
