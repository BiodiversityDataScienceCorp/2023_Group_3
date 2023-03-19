#Occurrence Map
#03/18/2023
#Synthesized from team member's individual scripts
#Bailie Wynbelt, Hailey Park, Zoe Evans, Josie Graydon#Install packages and load libraries:

### SECTION 1: Install needed packages and query snail data from GBIF ###

install.packages("spocc")
install.packages("tidyverse") 
library(spocc)
library(tidyverse)

snailquery <- occ(query = "Ashmunella levettei", from = "gbif", limit = 4000)

# Drill down to get the data using "$", and show from Env window
snail <- snailquery$gbif$data$Ashmunella_levettei

# Deal with NAs
noNA <- snail %>% 
  filter(latitude != "NA", longitude != "NA")

# Remove duplicates
noDupSn <- noNA %>% mutate(location = paste(latitude, longitude, dateIdentified, sep = "/")) %>%
  distinct(location, .keep_all = TRUE)

# All required data cleaning in one chunk of code
cleanSnail <- snail %>% 
  filter(latitude != "NA", longitude != "NA") %>%
  mutate(location = paste(latitude, longitude, dateIdentified, sep = "/")) %>%
  distinct(location, .keep_all = TRUE)

### SECTION 2: Plot occurrences with ggplot ###

# Set longitude and latitude boundaires
xmax <- max(cleanSnail$longitude)
xmin <- min(cleanSnail$longitude)
ymax <- max(cleanSnail$latitude)
ymin <- min(cleanSnail$latitude)

wrld <- ggplot2::map_data("world")

# Plot occurrence data
ggplot() +
  geom_polygon(data=wrld, mapping=aes(x=long, y=lat, group=group), fill="grey75", colour="grey60")+
  geom_point(data=cleanSnail, mapping=aes(x=longitude, y=latitude), show.legend = FALSE) +
  labs(title="Species Occurences of A. levettei", x="longitude", y="latitude") +
  coord_fixed(xlim = c(xmin, xmax), ylim = c(ymin, ymax)) +
  scale_size_area() +
  borders("state")

ggsave(file="occurrencemap.jpg",
       plot=last_plot(), 
       path = "output", 
       width=1600, 
       height=1000, 
       units="px")
# Occurrence points are geographical observations noted within GBIF
# Spotted in southern Arizona mostly, but a few points noted in other parts of Arizona and New Mexico
# but very few, so not sure if accurate or not