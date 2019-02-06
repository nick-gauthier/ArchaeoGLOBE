# get the base image, the rocker/verse has R, RStudio and pandoc
FROM rocker/verse:3.5.2

# required
MAINTAINER Ben Marwick <benmarwick@gmail.com>

COPY . /archaeoglobe


# go into the repo directory
RUN . /etc/environment \

  # Install linux depedendencies here
  # e.g. need this for ggforce::geom_sina
  && sudo apt-get update \
  && sudo apt-get install libudunits2-dev libgdal-dev gdal-bin libproj-dev proj-data proj-bin libgeos-dev xvfb xorg-dev  mesa-common-dev libglu1-mesa-dev freeglut3-dev  xorg-dev libcgal-dev libx11-dev libftgl2 libjq-dev libprotobuf-dev protobuf-compiler  curl gnupg  gnupg2 gnupg1 -y \
  && curl -sL https://deb.nodesource.com/setup_11.x | sudo -E bash - 
  
RUN sudo apt-get install -y nodejs \
  && sudo npm -g phantomjs-prebuilt -y \
  
  # install GitHub-only depedendencies
  && sudo R -e "devtools::install_github(c('thomasp85/patchwork', 'centerforopenscience/osfr')) " \

  # build this compendium package
  && sudo R -e "devtools::install('/archaeoglobe', dep=TRUE)" \
  
  # make project directory writable to save images and other output
  && sudo chmod a+rwx -R archaeoglobe \

 # render the manuscript into a html output
  && sudo R -e "setwd('/archaeoglobe/analysis'); rmarkdown::render('archaeoglobe.Rmd')"
  
  

