# combine all coordinates - get ALL climate data at once!
library(dplyr)

# combine and format data
file_v    <- setdiff(paste0('data/',list.files('data')), 'data/all_coord.csv' )
coord_l   <- lapply( file_v, read.csv, stringsAsFactor=F )
coord_df  <- coord_l %>% bind_rows

# store data
write.csv(coord_df, 'data/all_coord.csv', row.names=F)
