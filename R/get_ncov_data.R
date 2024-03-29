# Hello World
# Code for CDC Tracker Power BI file
# this code is called by R scripts that are run in a Power Query that feeds into a Power BI Report
# all packages must already be installed on the version of R that is called by Power BI
# it returns a cleaned file for analysis in Power BI with country-level case and death data from WHO and the Johns Hopkins Coronavirus Resource Center
# it requires an object called "rfunctions.dir" which is the directory where the other codes, "get_jhu_date.R" and "get_who_data.R", is stored

function(rfunctions.dir, df_jhu, df_who){

  # Pulling in the load package function R file
  # Load function to install list of packages
  # ldpkg <- dget(paste0(rfunctions.dir, "ldpkg.R"))
  # ldpkg("tidyverse")
  
  # If JHU dataframe is missing as input, then call the script to generate it
  if (missing(df_jhu)) {
    # Function to get JHU data
    fun_jhu <- dget(paste0(rfunctions.dir, "get_jhu_data.R"))
    df_jhu <- fun_jhu(rfunctions.dir)
  }
  
  # If WHO dataframe is missing as input, then call the script to generate it
  if (missing(df_who)) {
    # Function to get WHO data
    fun_who <- dget(paste0(rfunctions.dir, "get_who_data.R"))
    df_who <- fun_who(rfunctions.dir)
  }
  
  
  df_jhu$data_source = "JHU"
  
  df_who$data_source = "WHO"
  
  df <- rbind(df_jhu, df_who) %>% 
    rename( Country             =   "country"    ,
            Date                =   "date"       ,
            `New Cases`          =   "cases_new"  ,
            `Cumulative Cases`   =   "cases_cum"  ,
            `New Deaths`         =   "deaths_new" ,
            `Cumulative Deaths`  =   "deaths_cum" ,
            `WHO Region`         =   "who_region" ,
            `Population 2020`    =   "pop_2020yr" ,
            `Country Code`       =   "iso3code") %>%
    mutate(ou_date_src_match = paste(ou_date_match, data_source, sep="_")) %>% 
    mutate(country_code = `Country Code`) %>%
    mutate(`Population 2018.x` = `Population 2020`) %>%
    select(Country, Date, 
           `New Cases`,
           `Cumulative Cases`,
           `New Deaths`,
           `Cumulative Deaths`,
           `WHO Region`,
           `Population 2020`,
           `Population 2018.x`,
           `Country Code`,
           country_code,
           ou_date_match,
           ou_date_src_match,
           data_source,
           iso2code
    ) %>%  
    mutate_if(is.numeric, ~replace(., is.na(.), 0))
  
  
  return(df)
}