# ArchaeoGLOBE Research Compendium

[![Circle CI](https://circleci.com/gh/benmarwick/ArchaeoGLOBE.svg?style=shield&circle-token=:circle-token)](https://circleci.com/gh/benmarwick/ArchaeoGLOBE)  [![Binder](http://mybinder.org/badge.svg)](http://beta.mybinder.org/v2/gh/benmarwick/ArchaeoGLOBE/master?urlpath=rstudio)


This repository contains the working files of data and code for our paper:

> Authors, (YYYY). *Title of paper*. Name of journal/book
> <https://doi.org/xxx/xxx>

Our pre-print is online here:

> Authors, (YYYY). *Title of paper*. Name of journal/book, Accessed 15
> Nov 2018. Online at <https://doi.org/xxx/xxx>

The files that produced the published results are also archived at <https://doi.org/xxx/xxx>

### How to cite

Please cite this compendium using the archival URL (and not a GitHub URL):

> Authors, (2018). *Compendium of R code and data for ‘Title of paper’*.
> Accessed 15 Nov 2018. Online at <https://doi.org/xxx/xxx>

### How to view, run, download

You can view the results of the analysis online here: <https://benmarwick.github.io/ArchaeoGLOBE/analysis/archaeoglobe.pdf>

You can run the code in your browser (no download or install required) by [launching Binder](http://beta.mybinder.org/v2/gh/benmarwick/ArchaeoGLOBE/master?urlpath=rstudio)

You can download the compendium as a zip from from this URL:
<https://github.com/benmarwick/ArchaeoGLOBE/archive/master.zip>

You can get the complete computational environment used for this project with our Docker container. To launch the Docker container for this project, first, install Docker on your computer. At the Docker prompt, enter:

```
$ docker run -dp 8787:8787 -e PASSWORD=rstudio -e ROOT=TRUE benmarwick/archaeoglobe
```

Then open your web browser at `localhost:8787` or or run `docker-machine ip default` in the shell to find the correct IP address, and log in with rstudio/rstudio. More information about using RStudio in Docker is avaiable at the [Rocker wiki](https://github.com/rocker-org/rocker/wiki/Using-the-RStudio-image) pages.


### Licenses

**Text and figures :**
[CC-BY-4.0](http://creativecommons.org/licenses/by/4.0/)

**Code :** See the [DESCRIPTION](DESCRIPTION) file

**Data :** [CC-0](http://creativecommons.org/publicdomain/zero/1.0/)
attribution requested in reuse

### Contributions

We welcome contributions from everyone. Before you get started, please
see our [contributor guidelines](CONTRIBUTING.md). Please note that this
project is released with a [Contributor Code of Conduct](CONDUCT.md). By
participating in this project you agree to abide by its terms.

