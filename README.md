# Repository for Making Species Occurrence and Distribution maps for the Huachuca Woodland Snail (_Ashmunella levettei_)

## Zoe Evans, Josie Graydon, Hailey Park, and Bailie Wynbelt

<img src="photos/huachuca.jpeg"  width="50%">

## 🐌 Overview
The __Huachuca Woodland Snail__ (_Ashmunella levettei_), is a snail species primarily found in the Huachuca Mountains in Arizona, USA. It has also historically been found in parts of New Mexico and northwestern Texas (Pilsbry and Ferriss, 1909; Reeder, 1945; Fairbanks, 1979). _A. levettei_ is within the phylum Mollusca, class Gastropoda, subclass Heterobranchia, order Stylommatophora, and family Polygyridae.

_A. levettei_ is primarily distinguished from other mountain range snails by its shell, which is heliciform, umbilicate, and unbanded (Pilsbry, 1940; Fairbanks, 1979). The last whorl on the shell is fine, and the spiral lines are hardly distinguishable (Pilsbry, 1940). They can also be distinguished from other species based on the equal portions of the upper and lower penis (Reeder, 1945).

_A. levettei_ is an endangered species that is potentially up for a Species Status Assessment by the US Fish & Wildlife Service. This repository serves as a source for examining occurrences and generating current and future distribution models for _A. levettei_. Data gathered from the Global Biodiversity Information Facility (GBIF), an open-access source of biodiversity data from sources including iNaturalist, USGS, and museum collections, was utilized in this project. This project was done in collaboration between students of Lewis & Clark College and University of Arizona.

## 📦 Dependencies
The project uses the following additional R packages (will be installed with file when needed):
+ dismo
+ maps
+ maptools
+ readr
+ rJava
+ spocc
+ tidyverse

## 📁 Structure

### data
+ `snaildata.csv`: data harvested from [GBIF](https://www.gbif.org/) and [iNaturalist](https://www.inaturalist.org) for _Ashmunella levettei_. 

### homework
+ organization of each of our homeworks
+ HW 3: group testing out collaborating on Posit, using Command-Push-Pull to write each of our names and favorite species within an R Markdown file.
+ HW 4: creating occurrence maps for _A. levettei_.
+ HW 6: creating current and future SDMs for _A. levettei_.

### output
+ maxent_outputs
  + `maxent.log`
+ `cleansnail.csv`: a cleaned up version of `snaildata.csv`
+ currentsnailSDM.jpg: a picture of the current _A. levettei_ species distribution model we generated.
+ futureSnailSDM.jpg: a picture of the future _A. levettei_ species distribution model we generated for 70 years from now.
+ occurrencemap.jpg: a picture of the occurrence map for _A. levettei_ that we generated.

### photos
+ huachuca.jpeg: the _A. levettei_ image featured in the README file.

### scripts
+ `currentsdm.R`: code for generating the current species distribution model for _A. levettei_.
+ `dataacquisitioncleaning.R`: code for obtaining the GBIF data for _A. levettei_.
+ `futuresdm.R`: code for generating the future species distribution model for _A. levettei_, 70 years from now.
+ `occurrencemap.R`: to create the occurrence map of the GBIF data for _A. levettei_.

## Running the code
Run the sceripts in the following order:
1. `dataacquisitioncleaning.R`
2. `occurrencemap.R`
3. `currentsdm.R`
4. `futuresdm.R`