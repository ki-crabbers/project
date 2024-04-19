## code to prepare `individual` dataset goes here ##

## Setting up  ----
library(dplyr)

source(here::here('R', 'geolocate.R'))

## Combine individual tables ## ----

## Creating paths to inputs ## ----

raw_data_path <- here::here('data-raw',
                            'wood-survey-data-master')

individual_paths <- fs::dir_ls(fs::path(raw_data_path, "individual")) ## Creating a vector of the individual file paths in individual ##

individual_df_num_1 <- readr::read_csv(individual_paths[1]) ## this individual_paths vector can be used to read in files in the individual directory ##

## reading in all individual tables into one - confusing need to go over ##

individual <- purrr::map(
  individual_paths,
  ~ readr::read_csv(
    file = .x,
    col_types = readr::cols(.default = "c"),
    show_col_types = FALSE
  )
) %>%
  purrr::list_rbind() %>%
  readr::type_convert()

individual %>%
  readr::write_csv(file = fs::path(raw_data_path, "vst_individuals.csv"))

## Combine NEON data tables ## ----

## Reading in additional tables ##

maptag <- readr::read_csv(
  fs::path(raw_data_path, 
           "vst_mappingandtagging.csv")  
) %>%
  select(-eventID) ## importing mapping and tagging data and removing column  ##

perplot <- readr::read_csv(
  fs::path(raw_data_path, 
           'vst_perplotperyear.csv'),
  show_col_types = FALSE
) %>%
  select(-eventID) ## importing in per plot per year data and removing column  ##

names(individual)[names(individual) %in% names(maptag)]

## Left joining imported tables to individual ##

 individual %<>%                           
  dplyr::left_join(maptag, 
                   by = 'individualID',
                   suffix = c('', '_map')
                   ) %>%
  left_join(perplot,
            by = 'plotID',
            suffix = c('', '_ppl')
                   ) %>%
  assertr::assert(
    assertr::not_na, stemDistance, stemAzimuth, pointID, decimalLatitude, decimalLongitude
  )

## Geolocation of individual twigs or something ## ---- 
 
 individual <- individual %>% mutate(
   stemLat = get_stem_location(
     decimalLongitude, 
     decimalLatitude,
     stemAzimuth, 
     stemDistance
   )$lat,
   stemLon = get_stem_location(
     decimalLongitude, 
     decimalLatitude,
     stemAzimuth, 
     stemDistance
   )$lon
 ) %>% 
   janitor::clean_names()

 fs::dir_create('data')
 
 individual %>% 
   readr::write_csv(
     here::here('data', 'individual.csv')
   )
 