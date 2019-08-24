# get the base image, the rocker/verse has R, RStudio and pandoc
FROM rocker/geospatial:3.6.0

# required
MAINTAINER Nick Gauthier <ngauthier91@gmail.com>

COPY . /archaeoglobe


# go into the repo directory
RUN . /etc/environment \

  # install GitHub-only depedendencies
  && sudo R -e "devtools::install_github(c('thomasp85/patchwork', 'centerforopenscience/osfr')) " \

  # build this compendium package
  && sudo R -e "devtools::install('/archaeoglobe', dep=TRUE)" \
  
  # make project directory writable to save images and other output
  && sudo chmod a+rwx -R archaeoglobe \

 # render the manuscript into a html output
  && sudo R -e "setwd('/archaeoglobe/analysis'); rmarkdown::render('archaeoglobe.Rmd')"
  
  

