# get the base image, the rocker/verse has R, RStudio and pandoc
FROM rocker/verse:3.5.1

# required
MAINTAINER Ben Marwick <benmarwick@gmail.com>

COPY . /archaeoglobe


# go into the repo directory
RUN . /etc/environment \

  # Install linux depedendencies here
  # e.g. need this for ggforce::geom_sina
  && sudo apt-get update \
  && sudo apt-get install libudunits2-dev libgdal-dev gdal-bin libproj-dev proj-data proj-bin libgeos-dev xvfb xorg-dev  mesa-common-dev libglu1-mesa-dev freeglut3-dev  xorg-dev libcgal-dev libx11-dev -y \
  
  # install GitHub-only depedendencies
  && R -e "devtools::install_github(c('thomasp85/patchwork', 'centerforopenscience/osfr')) " \

  # build this compendium package
  && R -e "devtools::install('/archaeoglobe', dep=TRUE)" \

 # render the manuscript into a html output
  && R -e "setwd('/archaeoglobe/analysis') 
  && R -e "rmarkdown::render('/archaeoglobe.Rmd')"
  
  

