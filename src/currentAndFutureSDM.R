#### Start Current SDM ######
# 0. Load packages
source("src/packages.R")

# 1. Get occurrence Data 

# start with our data


occurrenceCoords<-read_csv("data/cleanData.csv") %>%
  dplyr::select(decimalLongitude, decimalLatitude)

occurrenceSpatialPts <- SpatialPoints(occurrenceCoords, proj4string = CRS("+proj=longlat"))

# now get the climate data
# make sure RAM is bumped up

worldclim_global(var="bio", res=2.5, path="data/", version="2.1")

