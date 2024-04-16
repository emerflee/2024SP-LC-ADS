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

# update .gitignore to prevent huge files getting pushed to github

#Here are the meanings of the bioclimatic variables (bio1 to bio19) provided by WorldClim:
#bio1: Mean annual temperature
#bio2: Mean diurnal range (mean of monthly (max temp - min temp))
#bio3: Isothermality (bio2/bio7) (* 100)
#bio4: Temperature seasonality (standard deviation *100)
#bio5: Max temperature of warmest month
#bio6: Min temperature of coldest month
#bio7: Temperature annual range (bio5-bio6)
#bio8: Mean temperature of wettest quarter
#bio9: Mean temperature of driest quarter
#bio10: Mean temperature of warmest quarter
#bio11: Mean temperature of coldest quarter
#bio12: Annual precipitation
#bio13: Precipitation of wettest month
#bio14: Precipitation of driest month
#bio15: Precipitation seasonality (coefficient of variation)
#bio16: Precipitation of wettest quarter
#bio17: Precipitation of driest quarter
#bio18: Precipitation of warmest quarter
#bio19: Precipitation of coldest quarter

climList <- list.files(path = "data/wc2.1_2.5m/", 
                       pattern = ".tif$", 
                       full.names = T)
currentClimRasterStack <- raster::stack(climList)

plot(currentClimRasterStack[[1]]) 

plot(occurrenceSpatialPts, add = TRUE)

#2. Create pseudo-absence points


mask <- raster(climList[[1]]) 

geographicExtent <- extent(x = occurrenceSpatialPts)

set.seed(45)

backgroundPoints <- randomPoints(mask = mask, 
                                 n = nrow(occurrenceCoords), #same n 
                                 ext = geographicExtent, 
                                 extf = 1.25, # draw a slightly larger area 
                                 warn = 0) 
colnames(backgroundPoints) <- c("longitude", "latitude")

# 3. Convert occurrence and environmental data into format for model

# Data for observation sites (presence and background), with climate data



occEnv <- na.omit(raster::extract(x = currentClimRasterStack, y = occurrenceCoords))

absenceEnv<- na.omit(raster::extract(x = currentClimRasterStack, y = backgroundPoints))

presenceAbsenceV <- c(rep(1, nrow(occEnv)), rep(0, nrow(absenceEnv)))

presenceAbsenceEnvDf <- as.data.frame(rbind(occEnv, absenceEnv))

# 4. Create Current SDM with maxent


# If you get a Java error, restart R, and reload the packages
bombusCurrentSDM <- dismo::maxent(x = presenceAbsenceEnvDf, ## env conditions
                                       p = presenceAbsenceV,   ## 1:presence or 0:absence
                                       path=paste("maxent_outputs"), #maxent output dir 
)

# 5. Plot the current SDM with ggplot



predictExtent <- 1.25 * geographicExtent 

geographicArea <- crop(currentClimRasterStack, predictExtent, snap = "in")

bombusPredictPlot <- raster::predict(bombusCurrentSDM, geographicArea) 

raster.spdf <- as(bombusPredictPlot, "SpatialPixelsDataFrame")

bombusPredictDf <- as.data.frame(raster.spdf)

wrld <- ggplot2::map_data("world")

xmax <- max(bombusPredictDf$x)
xmin <- min(bombusPredictDf$x)
ymax <- max(bombusPredictDf$y)
ymin <- min(bombusPredictDf$y)

ggplot() +
  geom_polygon(data = wrld, mapping = aes(x = long, y = lat, group = group),
               fill = "grey75") +
  geom_raster(data = bombusPredictDf, aes(x = x, y = y, fill = layer)) + 
  scale_fill_gradientn(colors = terrain.colors(10, rev = T)) +
  coord_fixed(xlim = c(xmin, xmax), ylim = c(ymin, ymax), expand = F) +#expand=F fixes margin
  scale_size_area() +
  borders("state") +
  borders("world", colour = "black", fill = NA) + 
  labs(title = "SDM of Bombus occidentalis Under Current Climate Conditions",
       x = "longitude",
       y = "latitude",
       fill = "Environmental Suitability")+ 
  theme(legend.box.background=element_rect(),legend.box.margin=margin(5,5,5,5)) 

ggsave("output/bombusCurrentSdm.jpg",  width = 8, height = 6)


#### End Current SDM #########

#### Start tidier Current SDM #########

# 1. Get occurrence Data 

# start with our data

## First we need to pare down the observations to fewer than 2000 observations so that the raster can actually run

tidierCleanData<- cleanData %>%
  filter(stateProvince %in% c("Washington", "Oregon"))
# this has 1470
write.csv(tidierCleanData, "data/tidierCleanData.csv")
tidierOccCoords<-read_csv("data/tidierCleanData.csv") %>%
  dplyr::select(decimalLongitude, decimalLatitude)

tidierOccSpatialPts <- SpatialPoints(tidierOccCoords, proj4string = CRS("+proj=longlat"))


# occurrenceCoords<-read_csv("data/cleanData.csv") %>%
#   dplyr::select(decimalLongitude, decimalLatitude)
# 
# occurrenceSpatialPts <- SpatialPoints(occurrenceCoords, proj4string = CRS("+proj=longlat"))

# now get the climate data
# make sure RAM is bumped up

worldclim_global(var="bio", res=2.5, path="data/", version="2.1")

# update .gitignore to prevent huge files getting pushed to github

#Here are the meanings of the bioclimatic variables (bio1 to bio19) provided by WorldClim:
#bio1: Mean annual temperature
#bio2: Mean diurnal range (mean of monthly (max temp - min temp))
#bio3: Isothermality (bio2/bio7) (* 100)
#bio4: Temperature seasonality (standard deviation *100)
#bio5: Max temperature of warmest month
#bio6: Min temperature of coldest month
#bio7: Temperature annual range (bio5-bio6)
#bio8: Mean temperature of wettest quarter
#bio9: Mean temperature of driest quarter
#bio10: Mean temperature of warmest quarter
#bio11: Mean temperature of coldest quarter
#bio12: Annual precipitation
#bio13: Precipitation of wettest month
#bio14: Precipitation of driest month
#bio15: Precipitation seasonality (coefficient of variation)
#bio16: Precipitation of wettest quarter
#bio17: Precipitation of driest quarter
#bio18: Precipitation of warmest quarter
#bio19: Precipitation of coldest quarter

climList <- list.files(path = "data/wc2.1_2.5m/", 
                       pattern = ".tif$", 
                       full.names = T)
currentClimRasterStack <- raster::stack(climList)

plot(currentClimRasterStack[[1]]) 

plot(tidierOccSpatialPts, add = TRUE)

#2. Create pseudo-absence points


mask <- raster(climList[[1]]) 

geographicExtent <- extent(x = occurrenceSpatialPts)

set.seed(45)

tidierBackgroundPoints <- randomPoints(mask = mask, 
                                 n = nrow(tidierOccCoords), #same n 
                                 ext = geographicExtent, 
                                 extf = 1.25, # draw a slightly larger area 
                                 warn = 0) 
colnames(tidierBackgroundPoints) <- c("longitude", "latitude")

# 3. Convert occurrence and environmental data into format for model

# Data for observation sites (presence and background), with climate data



tidierOccEnv <- na.omit(raster::extract(x = currentClimRasterStack, y = tidierOccCoords))

tidierAbsenceEnv<- na.omit(raster::extract(x = currentClimRasterStack, y = tidierBackgroundPoints))

tidierPresenceAbsenceV <- c(rep(1, nrow(tidierOccEnv)), rep(0, nrow(tidierAbsenceEnv)))

tidierPresenceAbsenceEnvDf <- as.data.frame(rbind(tidierOccEnv, tidierAbsenceEnv))

# 4. Create Current SDM with maxent


# If you get a Java error, restart R, and reload the packages
bombusTidierCurrentSDM <- dismo::maxent(x = tidierPresenceAbsenceEnvDf, ## env conditions
                                  p = tidierPresenceAbsenceV,   ## 1:presence or 0:absence
                                  path=paste("maxent_outputs"), #maxent output dir 
)

# 5. Plot the current SDM with ggplot



predictExtent <- 1.25 * geographicExtent 

geographicArea <- crop(currentClimRasterStack, predictExtent, snap = "in")

bombusTidierPredictPlot <- raster::predict(bombusTidierCurrentSDM, geographicArea) 

raster.spdf <- as(bombusTidierPredictPlot, "SpatialPixelsDataFrame")

bombusTidierPredictDf <- as.data.frame(raster.spdf)

wrld <- ggplot2::map_data("world")

xtmax <- max(bombusTidierPredictDf$x)
xtmin <- min(bombusTidierPredictDf$x)
ytmax <- max(bombusTidierPredictDf$y)
ytmin <- min(bombusTidierPredictDf$y)

ggplot() +
  geom_polygon(data = wrld, mapping = aes(x = long, y = lat, group = group),
               fill = "grey75") +
  geom_raster(data = bombusTidierPredictDf, aes(x = x, y = y, fill = layer)) + 
  scale_fill_gradientn(colors = terrain.colors(10, rev = T)) +
  coord_fixed(xlim = c(xmin, xmax), ylim = c(ymin, ymax), expand = F) +#expand=F fixes margin
  scale_size_area() +
  borders("state") +
  borders("world", colour = "black", fill = NA) + 
  labs(title = "SDM of Bombus occidentalis in Washington, Oregon, and California Under Current Climate Conditions",
       x = "longitude",
       y = "latitude",
       fill = "Environmental Suitability")+ 
  theme(legend.box.background=element_rect(),legend.box.margin=margin(5,5,5,5)) 

ggsave("output/bombusTidierCurrentSdm.jpg",  width = 8, height = 6)


#### End tidier Current SDM #########


#### Start Future SDM ########



# 6. Get Future Climate Projections

# CMIP6 is the most current and accurate modeling data
# More info: https://pcmdi.llnl.gov/CMIP6/

futureClimateRaster <- cmip6_world("CNRM-CM6-1", "585", "2061-2080", var = "bioc", res=2.5, path="data/cmip6")
futureClimateRaster

# 7. Prep for the model


names(futureClimateRaster)=names(currentClimRasterStack)

geographicAreaFutureC6 <- crop(futureClimateRaster, predictExtent)


# 8. Run the future SDM

bombusFutureSDM <- raster::predict(bombusTidierCurrentSDM, geographicAreaFutureC6)


# 9. Plot the future SDM


bombusFutureSDMDf <- as.data.frame(bombusFutureSDM, xy=TRUE)


