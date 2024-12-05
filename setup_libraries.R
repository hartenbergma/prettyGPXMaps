# List of required packages
required_packages <- c(
  "leaflet",
  "mapview",
  "sf",
  "ggplot2"
  # "ggmap",
  # "geosphere",
  # "leafem",
  # "mapboxapi"
)

# Function to install and load packages
install_and_load <- function(package) {
  if (!require(package, character.only = TRUE)) {
    install.packages(package, dependencies = TRUE)
    library(package, character.only = TRUE)
  }
}

sapply(required_packages, install_and_load)

cat("All required libraries are installed and loaded.\n")