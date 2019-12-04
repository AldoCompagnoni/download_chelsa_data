# homogeneous grid across the USA 
library(raster)
library(dplyr)
library(leaflet)

# create a grid of roughly equidistant points
coord_df <- expand.grid( lat = seq(25,50,length.out = 50),
                         lon = seq(-124,-66, length.out = 90) )

# test it 
leaflet(data = coord_df ) %>% 
  addTiles() %>% 
  addCircleMarkers(~lon, ~lat,
                   radius=0.01)

# store the grid coordinates
write.csv(coord_df, 'data/grid_usa.csv', row.names=F)

