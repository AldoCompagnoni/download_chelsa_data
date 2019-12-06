# compadre coordinates
library(Rcompadre)
library(dplyr)

# get compadre metadata
cdb_metadata <- function(cdb) {
  cdb <- as_tibble(cdb) 
  i <- which(names(cdb) == "mat")
  if (length(i) == 0) stop("argument cdb does not contain a column 'mat'")
  cdb <- cdb[,-i]
  return(cdb)
}

# get compadre
compadre  <- cdb_fetch("compadre")
comp_meta <- cdb_metadata(compadre)

# compadre coordinates
comp_coor <- comp_meta %>% 
              dplyr::select( SpeciesAuthor, MatrixPopulation, 
                             Lat, Lon ) %>% 
              unique %>% 
              # remove NAs and keep all the rest!
              subset( !is.na(Lat) ) %>% 
              subset( !is.na(Lon) ) %>% 
              rename( lat = Lat,
                      lon = Lon ) %>% 
              mutate( project = 'compadre' )

# store!
write.csv(comp_coor, 'data/compadre_coord.csv', row.names=F)
