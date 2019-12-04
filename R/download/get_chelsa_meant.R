library(RCurl)
library(testthat)
library(raster)
library(dplyr)
library(measurements)
library(leaflet)


# different future projections. Links .nc_1_2041 refer to annual TEMPERATURE
# convert lat/lon in decimal form
conv_plot_coord <- function(lat_in, lon_in, from_unit){
  
  coord_df <- data.frame( lat = conv_unit(lat_in,  
                                          from = from_unit, 
                                          to = 'dec_deg'),
                          lon = conv_unit(lon_in, 
                                          from = from_unit, 
                                          to = 'dec_deg'),
                          stringsAsFactors = F) %>% 
    mutate(   lat = as.numeric(lat),
              lon = as.numeric(lon) )
  
  return(coord_df)
  
}

# # from degrees+minutes+seconds to decimal degrees





leaflet(data = conv_plot_coord('40 48 07', '-124 09 49', 'deg_min_sec') ) %>% 
  addTiles() %>% 
  addCircleMarkers(~lon, ~lat)




# leftie
mat  <- 'https://www.wsl.ch/lud/chelsa/data/bioclim/integer/CHELSA_bio10_01.tif'
        
# download data frame

# test that all links exist
mat %>% url.exists %>% print









# site coord MATRIX (to feed "raster")
coord_df   <- data.frame( place  =   c('lupine', 'eureka', 'porland', 'ashland', 'LA', 'Santa Cruz', 'Santa Barbara',
                                       'San Simeon','Morro Bay'),
                          Longitude = c( -122.959824, 
                                         conv_plot_coord( '40 48 07', '-124 09 49', 'deg_min_sec')[2] %>% as.numeric,
                                         conv_plot_coord( '45 31 12', '-122 40 55', 'deg_min_sec')[2] %>% as.numeric,
                                         conv_plot_coord( '42 11 29', '-122 42 03', 'deg_min_sec')[2] %>% as.numeric,
                                         conv_plot_coord( '34 03 00', '-118 15 00', 'deg_min_sec')[2] %>% as.numeric,
                                         conv_plot_coord( '36 58 19', '-122 1 35', 'deg_min_sec')[2] %>% as.numeric,
                                         conv_plot_coord( '34 25 00', '-119 42 00', 'deg_min_sec')[2] %>% as.numeric,
                                         conv_plot_coord( '35 38 38', '-121 11 23', 'deg_min_sec')[2] %>% as.numeric,
                                         conv_plot_coord( '35 21 57', '-120 51 00', 'deg_min_sec')[2] %>% as.numeric
                                         ),
                          Latitude  = c( 38.109108,
                                         conv_plot_coord( '40 48 07', '-124 09 49', 'deg_min_sec')[1] %>% as.numeric,
                                         conv_plot_coord( '45 31 12', '-122 40 55', 'deg_min_sec')[1] %>% as.numeric,
                                         conv_plot_coord( '42 11 29', '-122 42 03', 'deg_min_sec')[1] %>% as.numeric,
                                         conv_plot_coord( '34 03 00', '-118 15 00', 'deg_min_sec')[1] %>% as.numeric,
                                         conv_plot_coord( '36 58 19', '-122 1 35', 'deg_min_sec')[1] %>% as.numeric,
                                         conv_plot_coord( '34 25 00', '-119 42 00', 'deg_min_sec')[1] %>% as.numeric,
                                         conv_plot_coord( '35 38 38', '-121 11 23', 'deg_min_sec')[1] %>% as.numeric,
                                         conv_plot_coord( '35 21 57', '-120 51 00', 'deg_min_sec')[1] %>% as.numeric
                                         )
                        )
                          

site_coord <- matrix(c(coord_df$Longitude,
                        coord_df$Latitude),
                      dimnames = list(rep('value',nrow(coord_df)),
                                      c('Long','Lat') ),
                      byrow = FALSE, nrow = nrow(coord_df) )
         

# 3. Extract CHELSA DATA ------------------------------------------------------------------------

# extract year and monthly data
extract_year_month <- function(){
  
  # download file
  file_path <- mat
  download.file( file_path, destfile = 'temp.tif', mode = "wb")

  # get climate information 
  
  # read raster file
  raster_file <- grep('.tif',list.files(), value=T)
  repP        <- raster( raster_file )
  
  # extract info from raster file
  values_clim <- raster::extract(repP, site_coord, method = 'bilinear')

  # remove file you just downloaded
  file.remove( grep('.tif$',list.files(),value=T)[1] )
  
  return(values_clim)

}

mat_v <- extract_year_month()

data.frame( place = coord_df$place,
            mat = mat_v / 10 )

# extract data
clim_proj_df <- lapply(1:10, extract_year_month) %>% bind_rows

clim_proj_df <- clim_proj_df %>% bind_rows

# store values
write.csv(clim_proj_df, 'climate_projections.csv', row.names=F)


