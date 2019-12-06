#read and format coordinates
all_coord <- read.csv('C:/CODE/plant_review_analyses/results/coord/all_coord.csv') %>% 
               rename( lat = Lat,
                       lon = Lon ) %>% 
               mutate( project = 'plant_rev' )

# store it
write.csv(all_coord, 'data/plant_rev_coord.csv', row.names=F)
