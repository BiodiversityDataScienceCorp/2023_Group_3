#Homework 6
#Bailie Wynbelt


## SECTION 1: Download and manipulate correct files for snail species

install.packages("spocc")
install.packages("tidyverse") 
install.packages("readr")
library(spocc)
library(tidyverse)
library(readr)

#Pulling data from gbif
snailquery <- occ(query = "Ashmunella levettei", 
                  from = "gbif", 
                  limit = 4000)


#Drill down to get the data 
snail <- snailquery$gbif$data$Ashmunella_levettei

#Deal with NAs
noNA <- snail %>% 
  filter(latitude != "NA",
         longitude != "NA")

#Remove duplicates
noDupSn <- noNA %>% 
  mutate(location = paste(latitude, 
                          longitude,
                          dateIdentified,
                          sep = "/")) %>% 
  distinct(location, .keep_all = TRUE)

#Finalize the clean data
cleanSnail <- snail %>% 
  filter(latitude != "NA", 
         longitude !="NA") %>% 
  mutate(location = paste(latitude, 
                          longitude, 
                          dateIdentified, 
                          sep = "/")) %>% 
  distinct(location, .keep_all = TRUE)


##SECTION 2: Create current SDM

#packages
install.packages("dismo")
install.packages("maptools")
install.packages("tidyverse")
install.packages("rJava")
install.packages("maps")

library(dismo)
library(maptools)
library(tidyverse)
library(rJava)
library(maps)

### Section 2.1: Obtaining and Formatting Occurence / Climate Data ### 

#read occurrence data 
snailDataNotCoords <- cleanSnail %>% 
  dplyr::select(longitude,latitude)

# convert to spatial points, necessary for modelling and mapping
snailDataSpatialPts <- SpatialPoints(snailDataNotCoords, 
                                    proj4string = CRS("+proj=longlat"))

# obtain climate data: use get data only once
currentEnv <- getData("worldclim", var="bio", res=2.5, path="data/") # current data


# create a list of the files in wc2-5 filder so we can make a raster stack
climList <- list.files(path = "data/wc2-5/", pattern = ".bil$", 
                       full.names = T)  # '..' leads to the path above the folder where the .rmd file is located

# stacking the bioclim variables to process them at one go
clim <- raster::stack(climList)

plot(clim[[12]]) # show one env layer 
plot(snailDataSpatialPts, add = TRUE) # looks good, we can see where our data is


### Section 1.2: Adding Pseudo-Absence Points ### 

mask <- raster(clim[[1]]) # mask is the raster object that determines the area where we are generating pts

# determine geographic extent of our data 
geographicExtent <- extent(x = snailDataSpatialPts)

#IMPORTANT! There should be at least 1000 background points.
#If your data set has fewer than 1000 background points, replace 'n'
# below, so it reads 'n=1000'

set.seed(45) # seed set so we get the same background points each time we run this code 
backgroundPoints <- randomPoints(mask = mask, 
                                 n = nrow(snailDataNotCoords), # n should be at least 1000 (even if your sp has fewer than 1000 pts)
                                 ext = geographicExtent, 
                                 extf = 1.25, # draw a slightly larger area than where our sp was found (ask katy what is appropriate here)
                                 warn = 0) # don't complain about not having a coordinate reference system

# add col names (can click and see right now they are x and y)
colnames(backgroundPoints) <- c("longitude", "latitude")

### Section 1.3: Collate Env Data and Point Data into Proper Model Formats ### 
# Data for observation sites (presence and background), with climate data
occEnv <- na.omit(raster::extract(x = clim, y = snailDataNotCoords))
absenceEnv<- na.omit(raster::extract(x = clim, y = backgroundPoints))

# Create data frame with presence training data and background points (0 = abs, 1 = pres)
presenceAbsenceV <- c(rep(1, nrow(occEnv)), rep(0, nrow(absenceEnv)))
presenceAbsenceEnvDf <- as.data.frame(rbind(occEnv, absenceEnv)) 


### Section 1.4: Create SDM with Maxent ### 
# create a new folder called maxent_outputs
snailSDM <- dismo::maxent(x = presenceAbsenceEnvDf, ## env conditions
                         p = presenceAbsenceV,   ## 1:presence or 0:absence
                         path=paste("output/maxent_outputs"), ## folder for maxent output; 
                         # if we do not specify a folder R will put the results in a temp file, 
                         # and it gets messy to read those. . .
                         
)


### Section 5: Plot the Model ###

predictExtent <- 3.25 * geographicExtent # choose here what is reasonable for your pts (where you got background pts from)
geographicArea <- crop(clim, predictExtent, snap = "in") # 
# look at what buffers are, maybe this is where mapping problem is
# crop clim to the extent of the map you want
snailPredictPlot <- raster::predict(snailSDM, geographicArea) # predict the model to 

# for ggplot, we need the prediction to be a data frame 
raster.spdf <- as(snailPredictPlot, "SpatialPixelsDataFrame")
snailPredictDf <- as.data.frame(raster.spdf)

# plot in ggplot
wrld <- ggplot2::map_data("world")

xmax <- max(snailPredictDf$x)
xmin <- min(snailPredictDf$x)
ymax <- max(snailPredictDf$y)
ymin <- min(snailPredictDf$y)

dev.off()
ggplot() +
  geom_polygon(data = wrld, mapping = aes(x = long, y = lat, group = group),
               fill = "grey75") +
  geom_raster(data = snailPredictDf, aes(x = x, y = y, fill = layer)) + 
  scale_fill_gradientn(colors = terrain.colors(10, rev = T)) +
  coord_fixed(xlim = c(xmin, xmax), ylim = c(ymin, ymax), expand = F) + # expand = F fixes weird margin
  scale_size_area() +
  borders("state") +
  labs(title = "SDM of R. boylii Under Current Climate Conditions",
       x = "longitude",
       y = "latitude",
       fill = "Environmental \nSuitability") + # \n is a line break
  theme(legend.box.background=element_rect(),legend.box.margin=margin(5,5,5,5)) 

#Live code ggsave here:
ggsave(filename = "currentSDM.jpg", 
       plot=last_plot(), 
       path="output", 
       width=1600, 
       height=800, 
       units="px")



