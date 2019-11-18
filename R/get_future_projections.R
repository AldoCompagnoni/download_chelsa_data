library(RCurl)
library(testthat)
library(raster)
library(dplyr)

# different future projections. Links .nc_1_2041 refer to annual TEMPERATURE

# leftie
left  <- 'CHELSA_bio_mon_NorESM1-M_rcp45_r1i1p1_g025.nc_1_2041-2060_V1.2.tif'
          
# second to left 
left2 <- 'CHELSA_bio_mon_MPI-ESM-LR_rcp45_r1i1p1_g025.nc_1_2041-2060_V1.2.tif'

# center
cntr  <- 'CHELSA_bio_mon_GISS-E2-R_rcp45_r1i1p1_g025.nc_1_2041-2060_V1.2.tif'

# second to right
right2<- 'CHELSA_bio_mon_CMCC-CM_rcp45_r1i1p1_g025.nc_1_2041-2060_V1.2.tif'

# right
right <- 'CHELSA_bio_mon_CESM1-BGC_rcp45_r1i1p1_g025.nc_1_2041-2060_V1.2.tif'


# put all links together. Add nc_12_2041: they refer PRECIPITATION
links <- c( c(left, left2, cntr, right2, right),
            gsub( 'nc_1_2041', 'nc_12_2041', 
                  c(left, left2, cntr, right2, right) ) )

# download data frame
dwnl_df <- data.frame( model    = rep( c('NorESM1-M', 'MPI-ESM-LR', 
                                         'GISS-E2-R', 'CMCC-CM', 
                                         'CESM1-BGC'), 2 ) ,
                       clim_var = c( rep('airt', 5), 
                                     rep('prec', 5) ),
                       url      = paste0( 'https://www.wsl.ch/lud/chelsa/data/cmip5/2041-2060/bio/',
                                          links ),
                       stringsAsFactors = F )

# test that all links exist

for(ii in 1:nrow(dwnl_df)){
  dwnl_df$url[ii] %>% url.exists %>% print
}


# site coord MATRIX (to feed "raster")
coord_df   <- read.csv('all_coord.csv') %>% select(-start.year,-end.year)
site_coord <- matrix(c(coord_df$Longitude,
                        coord_df$Latitude),
                      dimnames = list(rep('value',nrow(coord_df)),
                                      c('Long','Lat') ),
                      byrow = FALSE, nrow = nrow(coord_df) )
         

# 3. Extract CHELSA DATA ------------------------------------------------------------------------

# extract year and monthly data
extract_year_month <- function(ii){
  
  # download file
  file_path <- dwnl_df$url[ii]
  download.file( file_path, destfile = 'temp.tif', mode = "wb")

  # get climate information 
  
  # read raster file
  raster_file <- grep('.tif',list.files(), value=T)
  repP        <- raster( raster_file )
  
  # extract info from raster file
  values_clim <- raster::extract(repP, site_coord, method = 'bilinear')
  clim_df     <- coord_df %>% 
                    mutate( variable = dwnl_df$clim_var[ii],
                            model    = dwnl_df$model[ii],
                            value    = values_clim / 10
                            )

  # remove file you just downloaded
  file.remove( grep('.tif$',list.files(),value=T)[1] )
  
  # notify progress
  print(ii)
  
  return(clim_df)

}

# extract data
clim_proj_df <- lapply(1:10, extract_year_month) %>% bind_rows

clim_proj_df <- clim_proj_df %>% bind_rows

# store values
write.csv(clim_proj_df, 'climate_projections.csv', row.names=F)


