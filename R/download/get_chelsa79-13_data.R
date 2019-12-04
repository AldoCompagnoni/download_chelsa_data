# semi-automatic download of CHELSA's climate data
# this need be run on the cluster
# 1. Set up lat/lon data
# 2. Set up variables to download chelsa data directly
# 3. Extract chelsa data
library(dplyr)
library(tidyr)
library(readxl)
library(leaflet)
# devtools::install_github("jimhester/archive")
library(archive)
library(raster)

# pipe-able Reduce_rbind and grep functions
rbind_l     <- function(df_list){ Reduce(function(...) rbind(...), df_list) }


# 1. set up lat/lon data ------------------------------------------------------

coord_f  <- 'data/grid_usa.csv'

# coord
coord_df <- read.csv( coord_f ) %>% 
              dplyr::select( c('lat', 'lon') ) %>% 
              unique %>% 
              mutate( Longitude = as.numeric(lon),
                      Latitude  = as.numeric(lat) )  %>% 
              dplyr::select(-lat,-lon)

# check coordinates are correct
leaflet(data = coord_df ) %>%
  addTiles() %>%
  addCircleMarkers(~Longitude, ~Latitude,
                   radius=0.01)


# site coord MATRIX (to feed "raster")
site_coord <-  matrix(c(coord_df$Longitude,
                        coord_df$Latitude),
                      dimnames = list(rep('value',nrow(coord_df)),
                                      c('Long','Lat') ),
                      byrow = FALSE, nrow = nrow(coord_df) )
              

# 2. Set up variables to download chelsa data directly --------------------------

# what do I need from CHELSA?
chelsa_df <- expand.grid( variable = c('tmean','prec'),
                          year     = c(1979:2013),
                          month    = c(paste0('0',1:9),
                                       10,11,12),
                          stringsAsFactors = F) %>%
                arrange(variable, year, month)

# set up reading
read_dir  <- 'https://www.wsl.ch/lud/chelsa/data/timeseries/'

# produce file name based on index 'ii'
produce_file_name <- function(ii){
  
  paste0(chelsa_df$variable[ii],
         '/CHELSA_',
         chelsa_df$variable[ii],'_',
         chelsa_df$year[ii],'_',
         chelsa_df$month[ii],'_',
         'V1.2.1.tif')
  
}

# get all file links (from file name)
file_names <- sapply(1:nrow(chelsa_df), produce_file_name) 
file_links <- paste0(read_dir, file_names)
file_dest  <- paste0( getwd(), gsub("tmean|prec","",file_names) )


# 3. Extract CHELSA DATA ------------------------------------------------------------------------

# extract year and monthly data
extract_year_month <- function(ii){
  
  # download file
  file_path <- file_links[ii]
  download.file( file_path, destfile = file_dest[ii], mode = "wb")

  # get climate information 
  
  # read raster file
  raster_file <- grep('.tif',list.files(), value=T)
  repP        <- raster( raster_file )
  
  # extract info from raster file
  values_clim <- raster::extract(repP, site_coord, method = 'bilinear')
  clim_df     <- coord_df %>% 
                    mutate( variable = chelsa_df$variable[ii],
                            year     = chelsa_df$year[ii],
                            month    = chelsa_df$month[ii],
                            value    = values_clim)

  # remove file you just downloaded
  file.remove( grep('.tif$',list.files(),value=T)[1] )
  
  # notify progress
  print(ii)
  
  return(clim_df)

}

start <- Sys.time()
# range_clim  <- 1
climate_all <- lapply(1:5, extract_year_month)
Sys.time() - start


# climate_df <- climate_all %>% rbind_l
# 
# write.csv(climate_df, 
#           paste0(sA_dir, 'data/chelsa/climate_chelsa_',min(range_clim), '_',max(range_clim),'.csv'), 
#           row.names=F)
