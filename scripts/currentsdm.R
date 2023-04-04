#Current SDM Model
#03/18/2023
#Synthesized from team member's individual scripts
#Bailie Wynbelt, Hailey Park, Zoe Evans, Josie Graydon


### SECTION 1: Download/load required packages and read in clean snail data ###

install.packages("dismo")
install.packages("maptools")
install.packages("tidyverse")
install.packages("rJava")
install.packages("maps")
install.packages("spocc")

library(dismo)
library(maptools)
library(tidyverse)
library(rJava)
library(maps)
library(spocc)

cleanSnail <- read_csv("data/snaildata.csv")

### SECTION 2: Prepare data for plotting ###
snailDataNotCoords <- cleanSnail %>%  #select only longitude and latitude 
  select(longitude,latitude)

# Convert to spatial points, this is necessary for modelling and mapping
snailDataSpatialPts <- SpatialPoints(snailDataNotCoords, 
                                     proj4string = CRS("+proj=longlat")) 

# Obtain climate data required for plotting current SDM
currentEnv <- getData("worldclim", var="bio", res=2.5, path="data/") 

# Create a list of the files in wc2-5 folder so we can make a raster stack
climList <- list.files(path = "data/wc2-5/", pattern = ".bil$", 
                       full.names = T) #create a list of the files in wc2-5 folder so we can make a raster stack

# Stacking the bioclim variables to process them at one go
clim <- raster::stack(climList) 


### SECTION 3: Create pseudo-absence points and generate geographic extent for SDM model ###

# Mask is the raster object that determines the area where we are generating pts
mask <- raster(clim[[1]])

# Determine geographic extent of our data (so we generate random points reasonably nearby)
geographicExtent <- extent(x = snailDataSpatialPts) 

set.seed(45) # seed set so we get the same background points each time we run this code 
backgroundPoints <- randomPoints(mask = mask, 
                                 n = 1000, 
                                 ext = geographicExtent, 
                                 extf = 1.25, 
                                 warn = 0) 

colnames(backgroundPoints) <- c("longitude", "latitude") # add col names 

# Data for observation sites (presence and background), with climate data
occEnv <- na.omit(raster::extract(x = clim, y = snailDataNotCoords))
absenceEnv<- na.omit(raster::extract(x = clim, y = backgroundPoints))

# Create data frame with presence training data and background points (0 = abs, 1 = pres)
presenceAbsenceV <- c(rep(1, nrow(occEnv)), rep(0, nrow(absenceEnv)))
presenceAbsenceEnvDf <- as.data.frame(rbind(occEnv, absenceEnv)) 

# Create a new folder called maxent_outputs
snailSDM <- dismo::maxent(x = presenceAbsenceEnvDf, 
                          p = presenceAbsenceV, 
                          path=paste("output/maxent_outputs"), )

# Create geographic extent points
predictExtent <- 1.25 * geographicExtent

# Crop clim to the extent of the map
geographicArea <- crop(clim, predictExtent, snap = "in")

# Predict geographic area
snailPredictPlot <- raster::predict(snailSDM, geographicArea)

# Convert prediction into a data frame
raster.spdf <- as(snailPredictPlot, "SpatialPixelsDataFrame")
snailPredictDf <- as.data.frame(raster.spdf)

### SECTION 4: Plot current SDM in ggplot ###
wrld <- ggplot2::map_data("world")

# Produce latitude and longitude boundaries
xmax <- max(snailPredictDf$x)
xmin <- min(snailPredictDf$x)
ymax <- max(snailPredictDf$y)
ymin <- min(snailPredictDf$y)

##dev.off() #use if ggplot is not working, otherwise this is not needed
ggplot() +
  geom_polygon(data = wrld, mapping = aes(x = long, y = lat, group = group),
               fill = "grey75") +
  geom_raster(data = snailPredictDf, aes(x = x, y = y, fill = layer)) + 
  scale_fill_gradientn(colors = terrain.colors(10, rev = T)) +
  coord_fixed(xlim = c(xmin, xmax), ylim = c(ymin, ymax), expand = F) + # expand = F fixes weird margin
  scale_size_area() +
  borders("state") +
  labs(title = "SDM of A. levettei Under \nCurrent Climate Conditions",
       x = "longitude",
       y = "latitude",
       fill = "Environmental \nSuitability") + # \n is a line break
  theme(legend.box.background=element_rect(),legend.box.margin=margin(5,5,5,5)) 

ggsave(filename = "currentsnailSDM.jpg", 
       plot=last_plot(), 
       path = "output", 
       width=1600, 
       height=1000, 
       units="px")