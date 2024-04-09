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
    labels = "Habronattus americanus", 
    opacity = 1,
    title = "Species Occurrences from GBIF"
  )

map

mapshot2(map, file= "images/leafletTest.png")

