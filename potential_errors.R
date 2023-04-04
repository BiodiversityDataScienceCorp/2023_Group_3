#Potential Errors
#04/04/2023
#Bailie Wynbelt, Hailey Park, Zoe Evans, Josie Graydon

#This file contains a list of potential errors that could happen when running the script

### GGPLOT ERRORS ###

##If ggplot is not working run the following before running the ggplot code for future and current sdm

#dev.off() 
#Use if ggplot is not working, otherwise this is not needed
#This function closes the specified plot (by default the current device)

### CURRENT AND FUTURE SDM ERRORS ###

#The following code results in a warning message, this is okay! Do not worry.
#currentEnv <- getData("worldclim", var="bio", res=2.5, path="data/") 

#Warning message:
  #In getData("worldclim", var = "bio", res = 2.5, path = "data/") :
  #getData will be removed in a future version of raster
  #Please use the geodata package instead

#The following lines of code are RAM heavy, make sure to run these individual and wait until they appear in the environment to continue

#occEnv <- na.omit(raster::extract(x = clim, y = snailDataNotCoords))
#absenceEnv<- na.omit(raster::extract(x = clim, y = backgroundPoints))

#The following line of code could result in the following error

#snailSDM <- dismo::maxent(x = presenceAbsenceEnvDf, 
                          #p = presenceAbsenceV, 
                          #path=paste("output/maxent_outputs"), )
#Error in .jcheck(silent = TRUE) : 
  #No running JVM detected. Maybe .jinit() would help.

#This means that Java is no longer working in R, to help solve this issue go to "Session", "Clear Workspace", and restart R.
#You might need to do this everytime you run the code.
