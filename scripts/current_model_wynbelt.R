#Homework 6
#Bailie Wynbelt

## Install Packages

install.packages("spocc")
install.packages("tidyverse") 
install.packages("readr")
library(spocc)
library(tidyverse)
library(readr)

## Pulling data from gbif
snailquery <- occ(query = "Ashmunella levettei", 
                  from = "gbif", 
                  limit = 4000)


## Drill down to get the data 
snail <- snailquery$gbif$data$Ashmunella_levettei

write.csv(snail, file = "raw_snail_data.csv", row.names = TRUE)

## Deal with NAs
noNA <- snail %>% 
  filter(latitude != "NA",
         longitude != "NA")

## Remove duplicates
noDupSn <- noNA %>% 
  mutate(location = paste(latitude, 
                          longitude,
                          dateIdentified,
                          sep = "/")) %>% 
  distinct(location, .keep_all = TRUE)

## Finalize the clean data
cleanSnail <- snail %>% 
  filter(latitude != "NA", 
         longitude !="NA") %>% 
  mutate(location = paste(latitude, 
                          longitude, 
                          dateIdentified, 
                          sep = "/")) %>% 
  distinct(location, .keep_all = TRUE)

## Save clean data
write.csv(snail, file = "clean_snail_data.csv", row.names = TRUE)


