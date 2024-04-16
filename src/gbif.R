# gbif.R::
# query species occurrence data from GBIF
# clean up the data
# save it as a csv file
# create a map to display the species occurrence points

source("src/packages.R")

# git config --global user.email "you@example.com"
# git config --global user.name "Your Name"

## Querying from GBIF

usethis::edit_r_environ() 

beeBackbone<-name_backbone(name='Bombus occidentalis')
speciesKey<-beeBackbone$speciesKey 

occ_download(pred("taxonKey", speciesKey), format = "SIMPLE_CSV")

# Your download is being processed by GBIF:
#   https://www.gbif.org/occurrence/download/0129750-240321170329656
# Most downloads finish within 15 min.
# Check status with
# occ_download_wait('0129750-240321170329656')
# After it finishes, use
# d <- occ_download_get('0129750-240321170329656') %>%
#   occ_download_import()
# to retrieve your download.
# Download Info:
#   Username: eosullivan
# E-mail: emilyosullivan@lclark.edu
# Format: SIMPLE_CSV
# Download key: 0129750-240321170329656
# Created: 2024-04-09T17:52:22.428+00:00
# Citation Info:  
#   Please always cite the download DOI when using this data.
# https://www.gbif.org/citation-guidelines
# DOI: 10.15468/dl.9suead
# Citation:
#   GBIF Occurrence Download https://doi.org/10.15468/dl.9suead Accessed from R via rgbif (https://github.com/ropensci/rgbif) on 2024-04-09

occ_download_wait('0129750-240321170329656')

d <- occ_download_get('0129750-240321170329656') %>%  occ_download_import()

write_csv(d, "data/rawData.csv")

#cleaning the data 
cleanData <- d%>% 
  filter(!is.na(decimalLatitude), !is.na(decimalLongitude)) %>%
  filter(countryCode %in% c("US", "MX", "CA")) %>%
  filter(!basisOfRecord %in% c("FOSSIL_SPECIMEN", "LIVING_SPECIMEN")) %>%
  cc_sea(lon = "decimalLongitude", lat = "decimalLatitude") %>% 
  distinct(decimalLongitude, decimalLatitude, speciesKey, datasetKey, .keep_all = TRUE)

write.csv(cleanData, "data/cleanData.csv")

tidierCleanData<- cleanData %>%
  filter(stateProvince %in% c("Washington", "Oregon", "California"))
write.csv(tidierCleanData, "data/tidierCleanData.csv")


