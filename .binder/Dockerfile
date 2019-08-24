FROM rocker/binder:3.6.0
LABEL maintainer='Nick Gauthier'
USER root
COPY . ${HOME}
RUN chown -R ${NB_USER} ${HOME}
USER ${NB_USER}

RUN installGithub.r centerforopenscience/osfr thomasp85/patchwork

RUN wget https://github.com/nick-gauthier/ArchaeoGLOBE/raw/master/DESCRIPTION && R -e "options(repos = list(CRAN = 'http://mran.revolutionanalytics.com/snapshot/2019-08-24/')); devtools::install_deps()"

RUN rm DESCRIPTION.1
