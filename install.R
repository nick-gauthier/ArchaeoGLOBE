# Installs things for binder
system("apt-get install libudunits2-dev -y")
install.packages(c('tidyverse', 'sf', 'mgcv', 'caTools', 'bitops', 'dataverse'))
devtools::install_github('thomasp85/patchwork')
devtools::install_github('centerforopenscience/osfr')
devtools::install(".")
