#data aquisition cleaning 
#Zoe 03/07/23
#first draft of this file
# based on - https://docs.google.com/document/d/10ppTiiD_ogwr3o3ZQcsQ0EsqCYjJIGI_DxV5NYqupwk/edit

#installing packages and loading library

install.packages("spocc")
install.packages("tidyverse") #includes ggplot
install.packages("dismo")
install.packages("maptools")
install.packages("tidyverse")
install.packages("rJava")
install.packages("maps")
library(spocc)
library(tidyverse)
library(dismo)
library(maptools)
library(tidyverse)
library(rJava)
library(maps)

#getting snail data from gbif
snailquery<-occ(query = "Ashmunella levettei", from = "gbif", limit = 4000)
snailquery

#getting to snail data from gbif
snail<-snailquery$gbif$data$Ashmunella_levettei

#cleaning snail data
cleanSnail <- snail%>% 
  filter(latitude !="NA", longitude !="NA") %>% 
  mutate(location = paste(latitude, longitude,dateIdentified, sep = "/" ))%>% 
  distinct(location, .keep_all = TRUE)

#making the data a csv
write_csv(cleanSnail, file="data/snaildata.csv")

