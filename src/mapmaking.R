data<- read.csv("data/cleanData.csv")

map<- leaflet() %>% 
  #add a tile layer (you can choose different tile providers)
  #full list: https://leaflet-extras.github.io/leaflet-providers/preview
  addProviderTiles("Esri.WorldTopoMap") %>%
  #add circle markers for each point using latitude and longitude coordinates
  addCircleMarkers(data=cleanData, 
                   lng = ~decimalLongitude, 
                   lat = ~decimalLatitude, 
                   color = "navy", 
                   radius = 3, 
                   fillOpacity = 0.7, 
                   stroke = FALSE) %>%
  addLegend(
    position = "topright", 
    color = "navy", 
    labels = "Bombus Occidentalis", 
    opacity = 1,
    title = "Species Occurrences from GBIF"
  )

map

mapshot2(map, file= "images/leafletTest.png")

tidierMap<- leaflet() %>% 
  #add a tile layer (you can choose different tile providers)
  #full list: https://leaflet-extras.github.io/leaflet-providers/preview
  addProviderTiles("Esri.WorldTopoMap") %>%
  #add circle markers for each point using latitude and longitude coordinates
  addCircleMarkers(data=tidierCleanData, 
                   lng = ~decimalLongitude, 
                   lat = ~decimalLatitude, 
                   color = "navy", 
                   radius = 3, 
                   fillOpacity = 0.7, 
                   stroke = FALSE) %>%
  addLegend(
    position = "topright", 
    color = "navy", 
    labels = "Bombus Occidentalis in WA, OR, CA", 
    opacity = 1,
    title = "Species Occurrences from GBIF"
  )

tidierMap

mapshot2(tidierMap, file= "images/tidierLeafletTest.png")

