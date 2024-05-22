#-------------------------------------------------------------------------------------------------------------------
# Program: C:/GoogleDrive/scripts/R-Shinyapp_data-gov-au_police/global.R
# Date created: 17-MAY-2024
# Author(s): Lun-Hsien Chang
# Modified from: C:/GoogleDrive/scripts/R-shinyapp_internet-speed-test/global.R
# Dependency:

## Dataset download
## [Offender Numbers—Qld—monthly from Jan 2001](https://open-crime-data.s3-ap-southeast-2.amazonaws.com/Crime%20Statistics/QLD_Reported_Offenders_Number.csv)

# Input: 
## 
# Output: https://luenhchang.shinyapps.io/data-in-everyday-lives/
# References
## [The awesomeness that is the global.R file. Or how to clean up your shiny app](https://mraess.rbind.io/2018/07/the-awesomeness-that-is-the-global-r-file-or-how-to-clean-up-your-shiny-app/)
## [How to separate shiny app to two files: UI and SERVER](https://stackoverflow.com/questions/72762120/how-to-separate-shiny-app-to-two-files-ui-and-server)
## [Shiny app disconnected from the server. No errors](https://stackoverflow.com/questions/64095798/shiny-app-disconnected-from-the-server-no-errors)
## [rounding times to the nearest hour in R [duplicate]](https://stackoverflow.com/questions/16444242/rounding-times-to-the-nearest-hour-in-r)
## [Converting year and month ("yyyy-mm" format) to a date?](https://stackoverflow.com/questions/6242955/converting-year-and-month-yyyy-mm-format-to-a-date)
## [Convert month's number to Month name](https://stackoverflow.com/questions/50607659/convert-months-number-to-month-name)
## Date       Changes:
##--------------------------------------------------------------------------------------------------------------
## 2024-05-20 Deployed app to https://luenhchang.shinyapps.io/data-gov-au_police/
## 2024-05-18 Run App not plot shows up. It is because menuItem(tabName = "tabCrime") and tabItem(tabName = "Crime") have unmatched tabName
## 2024-05-17 Run App not plot shows up
##------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------------------
# Load R packages
## Required uninstalled packages in local PC will cause errors library(pkg) is not available while deploying app to shinyapps.io
#------------------------------------------------------------------------------------------------------------------
library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(shinydashboardPlus)

library(googlesheets4)
library(stringr)
library(httr)
library(curl)
library(lubridate)
library(ggridges)
library(ggplot2)
library(labeling)
library(farver)
library(cowplot)
library(dplyr)
library(tidyr)
library(png)
library(jpeg)
library(RCurl)
library(grid)
library(DT)
library(treemapify)
library(webr)

library(cachem)
library(bslib)
library(crayon)
library(memoise)
library(tzdb)
library(vroom)
library(ggrepel)
library(readr)
library(forcats)
library(tidyverse)
library(ggbreak)
library(timeDate)
library(tsibble)
library(ggthemes)
library(markdown)
library(xfun)
library(ggtext)
library(pals)

library(utils)
library(scales)
library(gghighlight)

library(knitr)
library(rmarkdown)
library(fresh)
library(slickR)
library(here)

library(plotly)
library(zoo)
#------------------------------------------------------------------------
# Directory in local PC
## 
## www: Where all the images and other assets needed for the viewer
#------------------------------------------------------------------------
#dir.C <- "C:"
#dir.app <- file.path(dir.C, "GoogleDrive","scripts","R-Shinyapp_data-gov-au_police")
#dir.www <- file.path(dir.app,"www")
#dir.create(path = dir.www)
# dir.data <- file.path(dir.app,"data-gov-au_police")
 
#***************************************************
# Read data to use under menuItem "Offender numbers" 
## Input file: 
#***************************************************

#setwd(dir.app)
Offender.Numbers.Qld.monthly.from.Jan.2001 <- read.delim(
  file = file.path(getwd(),"data-gov-au_police","376475d2-321f-42e2-8ecb-19a59b939b11.tsv")
  ,header = TRUE
  ,sep = "\t"
  # Prevent special characters in header from being replaced with .
  ,check.names = FALSE ) |>
  dplyr::mutate(year.month=as.Date(zoo::as.yearmon(`Month Year`,"%b%y"))
                ,year=lubridate::year(year.month)
                ,month=lubridate::month(year.month, label=TRUE, abbr = FALSE)
                ) |>
  # Data for 2022 is collected until feb. Exclude this year
  dplyr::filter(year %in% c(2001:2021)) # dim(Offender.Numbers.Qld.monthly.from.Jan.2001) 1512 95

# Numeric month to full name month
#,month.name=month.name(month.numeric)
#,month.abb=month.abb(month.numeric)
# Sum up the count in by groups of age and sex. Wide-format data
count.offences.age.sex.wide <- Offender.Numbers.Qld.monthly.from.Jan.2001 |> 
  dplyr::group_by(Age, Sex) |>
  dplyr::summarise_at(dplyr::vars(`Homicide (Murder)`:`Other Offences`)
                      , sum
                      , na.rm=TRUE) # dim(count.offences.age.sex.wide) 6 90

# Reshape 90 crime count columns into two new columns crime.name and count
count.offences.age.sex.long <- tidyr::pivot_longer(data = count.offences.age.sex.wide
                                                   # Apply to all columns except for column 1, column 2
                                                   ,cols = c(-1,-2)
                                                   ,names_to = "crime.name"
                                                   ,values_to = "count") |>
  dplyr::arrange(crime.name, Age, Sex) |> 
  dplyr::ungroup() |>
  dplyr::group_by(crime.name) |>
  dplyr::mutate(total=sum(count)
                ,percent=count/total * 100
                ,count.percent=paste0(count," (", round(percent, digits = 2),"%",")")
                ,age.sex=paste(Age, Sex)
                ) |>
  # Sort data from most frequent crime to the least frequent crime
  dplyr::arrange(desc(total), Age, Sex) # dim(count.offences.age.sex.long) 528 8

# Find top 10 most frequently committed offences
## [Make a table showing the 10 largest values of a variable in R?](https://stackoverflow.com/questions/31939643/make-a-table-showing-the-10-largest-values-of-a-variable-in-r)
## [top_n() returning all the rows in R](https://stackoverflow.com/questions/66709677/top-n-returning-all-the-rows-in-r)
## [How to specify "does not contain" in dplyr filter](https://stackoverflow.com/questions/34444295/how-to-specify-does-not-contain-in-dplyr-filter)
top10.offences.exclu.Other <- count.offences.age.sex.long |> 
  dplyr::ungroup() |> # top_n returns all the rows if applied to grouped data
  dplyr::select(crime.name, total) |> 
  dplyr::distinct() |> 
  dplyr::arrange(desc(total)) |>
  # Exclude "Other xyz" crime types
  dplyr::filter(!stringr::str_detect(string=crime.name,pattern="Other")) |>
  # Subset rows using their positions
  dplyr::top_n(n=10, wt=total) # dim(top10.offences.exclu.Other) 10 2

top10.offences.count.age.sex.exclud.Other <- count.offences.age.sex.long |> 
  dplyr::filter(crime.name %in% top10.offences.exclu.Other$crime.name) |>
  dplyr::arrange(desc(total)) # dim(top10.offences.count.age.sex.exclud.Other) 60 8

#---------------------------------------------------
# Count offence cases in by groups of year, age, sex
#---------------------------------------------------
count.offences.year.age.sex.wide <- Offender.Numbers.Qld.monthly.from.Jan.2001 |> 
  dplyr::group_by(year, Age, Sex) |>
  dplyr::summarise_at(dplyr::vars(`Homicide (Murder)`:`Other Offences`)
                      , sum
                      , na.rm=TRUE) # dim(count.offences.year.age.sex.wide) 126 91

# Reshape 90 crime count columns into two new columns crime.name and count
count.offences.year.age.sex.long <- tidyr::pivot_longer(data = count.offences.year.age.sex.wide
                                                   # Apply to all columns except for column 1, column 2
                                                   ,cols = c(-1,-2,-3)
                                                   ,names_to = "crime.name"
                                                   ,values_to = "count") |>
  dplyr::arrange(crime.name, year, Age, Sex) |> 
  dplyr::ungroup() |>
  dplyr::group_by(crime.name, year) |>
  dplyr::mutate(total=sum(count)
                ,percent=count/total * 100
                ,count.percent=paste0(count," (", round(percent, digits = 2),"%",")")
                ,age.sex=paste(Age, Sex)
                ) |>
  # Sort data from most frequent crime to the least frequent crime
  dplyr::arrange(year, desc(total), Age, Sex) # dim(count.offences.year.age.sex.long) 11088 9

# Find 10 most frequently committed offences in each year
top10.offences.count.year.exclud.Other <- count.offences.year.age.sex.long |> 
  dplyr::ungroup() |>
  # Exclude "Other xyz" crime types
  dplyr::filter(!stringr::str_detect(string=crime.name, pattern="Other")) |>
  dplyr::select(year, crime.name, total) |> 
  dplyr::distinct() |> 
  dplyr::group_by(year) |> 
  dplyr::slice_max(order_by = total, n=10) # dim(top10.offences.count.year.exclud.Other) 210 3

#************************************************************************************************#
#---------------------------------This is the end of this file ----------------------------------#
#************************************************************************************************#