FROM rocker/binder:3.6.0
LABEL maintainer='Nick Gauthier'
USER root
COPY . ${HOME}
RUN chown -R ${NB_USER} ${HOME}
USER ${NB_USER}

RUN wget https://github.com/nick-gauthier/ArchaeoGLOBE/raw/master/DESCRIPTION && R -e "options(repos = list(CRAN = 'http://mran.revolutionanalytics.com/snapshot/2019-08-24/')); devtools::install_deps()"

# make project directory writable to save images and other output
RUN chmod a+rwx -R archaeoglobe

# render the manuscript into a html output
RUN R -e "setwd('/archaeoglobe/analysis'); rmarkdown::render('archaeoglobe.Rmd')"

RUN rm DESCRIPTION.1
