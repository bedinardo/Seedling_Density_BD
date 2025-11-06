# Install and load required packages
install.packages("terra")
library(terra)
install.packages("amadeus")
library("amadeus")

# Set directory where climate data will be downloaded
dir <- ("C:/Users/Bryce/Desktop")

# Download gridMET minimum temperature data for 2020
# (saved locally since OneDrive path caused issues)
download_data("gridmet",
              variable = "Minimum Near-Surface Air Temperature",
              year = 2020,
              directory_to_save = dir,
              acknowledgement = TRUE,
              download = TRUE,
              remove_command = TRUE,
              hash = TRUE)

# Check that the downloaded files are present
list.files("C:/Users/Bryce/Desktop/tmmn")


# Process the downloaded covariates into a terra raster object
tmmn <- process_covariates(
  covariate = "gridmet",
  variable = "Minimum Near-Surface Air Temperature",
  date = c("2020-02-04"),
  path = file.path("C:/Users/Bryce/Desktop/tmmn")
)

# Inspect raster object and plot one layer (values are in Kelvin)
tmmn
terra::plot(tmmn[[1]])

# Install and load tigris for US Census boundaries
install.packages("tigris")
library(tigris)

# Pull all US state boundaries (2024 TIGER/Line shapefile)
state_boundries <- states(year = 2024)

# Filter just Oregon
oregon <- state_boundries[state_boundries$NAME == "Oregon", ]
plot(oregon)

# Define Oregon state boundary object for later use
or_state <- tigris::states(year = 2024)
or_state <- or_state[or_state$NAME == "Oregon", ]

# Calculate covariates (summarized gridMET values) for Oregon polygon
OR_tmmn <- amadeus::calculate_covariates(
  covariate = "gridmet",
  from = tmmn,
  locs = or_state,
  locs_id = "NAME",
  radius = 0,
  geom = "terra"
)

# Plotting OR_tmmn shows just the outline (attributes hold the covariates)
terra::plot(OR_tmmn)
OR_tmmn
names(OR_tmmn)
head(OR_tmmn)

# Mask raster to Oregon boundary (clip values to polygon)
tmmn_or <- terra::mask(tmmn[[1]], terra::vect(or_state))
terra::plot(tmmn_or)

# Crop raster to Oregon extent (zoom in so Oregon fills the plot)
tmmn_or_crop <- terra::crop(tmmn, terra::vect(or_state))
terra::plot(tmmn_or_crop)

# Convert covariate output to sf/tibble for tidy workflows
library("sf")
or_tmmn_sf <- sf::st_as_sf(OR_tmmn)
or_tmmn_tbl <- as_tibble(or_tmmn_sf)

#can I get the whole year

#feeding a range of of dates, should grab all rasters within date range
tmmn2020 <- process_covariates(
  covariate = "gridmet",
  variable = "Minimum Near-Surface Air Temperature",
  date = c("2020-01-01", "2020-12-31"),
  path = file.path("C:/Users/Bryce/Desktop/tmmn")
)
str(tmmn2020) #data as SpatRaster
head(tmmn2020)
nlyr(tmmn2020) #confirming we download all days of the year, n=366 (leap year)
#Calc mean tmmn for 2020 using terra as spatraster

