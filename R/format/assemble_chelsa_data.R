library(dplyr)
library(readxl)
options( stringsAsFactors = F )


# check that we have all slices
proj_ck <- list.files('C:/Users/ac22qawo/animal_review/output_2019.10') %>% 
              gsub('.csv','',.) %>% 
              gsub('array_clim-[0-9]{7}_clim_mon_proj_','',.) %>% 
              # gsub('array_vr-5403904_slice_','',.) %>% 
              as.numeric %>% 
              sort

# original chelsa data
orig_ck <- list.files('C:/Users/ac22qawo/animal_review/output_2019.10') %>% 
              grep('_7913_[0-9]{1,4}.csv',.,value=T) %>% 
              gsub('.csv','',.) %>% 
              gsub('array_clim-[0-9]{7}_7913_','',.) %>% 
              # gsub('array_vr-5403904_slice_','',.) %>% 
              as.numeric %>% 
              sort

# "cruts" chelsa data
cruts_ck <- list.files('C:/Users/ac22qawo/animal_review/output_2019.10') %>% 
              grep('_0916_[0-9]{1,4}.csv',.,value=T) %>% 
              gsub('.csv','',.) %>% 
              gsub('array_clim-[0-9]{7}_0916_','',.) %>% 
              # gsub('array_vr-5403904_slice_','',.) %>% 
              as.numeric %>% 
              sort


# assemble slices
sl_dir    <- 'C:/Users/ac22qawo/animal_review/output_2019.10'
in_dir    <- 'C:/Users/ac22qawo/Dropbox/sApropos/animal_review/climate_proj/'
# anim_stud <- read_xlsx( paste0( in_dir, 'climStudiesMammals_forAldo_june2019.xlsx' ) ) %>% 
#                 rename( Latitude     = lat,
#                         Longitude    = lon) %>% 
#                 select( Latitude, Longitude ) %>% 
#                 mutate( Latitude     = as.numeric(Latitude),
#                         Longitude    = as.numeric(Longitude) ) %>% 
#                 unique
anim_stud <- read.csv( paste0(in_dir, 'coord_update_2019.10.23/all_coord.csv') )

# chelsa time series: tMean
slices    <- paste0( sl_dir,
                     list.files('C:/Users/ac22qawo/animal_review/output') ) %>% 
                grep('_7913_[0-9]{1,4}.csv',.,value=T) 
chelsa_df  <- lapply(slices, read.csv) %>% bind_rows
chelsa_df  <- chelsa_df %>% 
                subset( !(variable %in% 'prec') ) %>% 
                mutate( value = (value / 10) - 273 ) %>% 
                bind_rows( subset(chelsa_df, variable == 'prec') )

write.csv( chelsa_df, 
           paste0(in_dir, 'output/chelsa_1979-2013_2.10.2019.csv'), 
           row.names = F )


# chelsa time series: tMean, tMin, tMax, precip 
slices    <- paste0( sl_dir,'/',
                     list.files( sl_dir ) ) %>% 
              grep('_7913_[0-9]{1,4}.csv',.,value=T) 
chelsa_df  <- lapply(slices, read.csv) %>% bind_rows
chelsa_df  <- chelsa_df %>% 
                subset( !(variable %in% 'prec') ) %>% 
                mutate( value = (value / 10) - 273 ) %>% 
                bind_rows( subset(chelsa_df, variable == 'prec') )

write.csv( chelsa_df, 
           paste0(in_dir, 'output/chelsa_1979-2013_29.10.2019.csv'), 
           row.names = F )


# cruts 
slices    <- paste0( sl_dir, '/',
                     list.files(sl_dir) ) %>% 
               grep('_0916_[0-9]{1,4}.csv',.,value=T) 
cruts_df  <- lapply(slices, read.csv) %>% bind_rows

write.csv( cruts_df, 
           paste0(in_dir, 'output/chelsa_monthly_1906-2016_29.10.2019.csv'), 
           row.names = F )

# projections 
slices    <- paste0( sl_dir, '/',
                     list.files(sl_dir) ) %>% 
               grep('clim_mon_proj_',.,value=T) 
proj_df   <- lapply(slices, read.csv) %>% bind_rows

write.csv( proj_df, 
           paste0(in_dir, 'output/proj_29.10.2019.csv'), 
           row.names = F )
  