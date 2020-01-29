FROM ubuntu:16.04

LABEL maintainer="Ruijia(Ray) Wang <Ruijia.Wang@umassmed.edu>"

# Add user to 'staff' group, granting them write privileges to /usr/local/lib/R/site.library
RUN useradd docker \
	&& mkdir /home/docker \
	&& chown docker:docker /home/docker \
	&& addgroup docker staff

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
	    apt-utils \
		software-properties-common \
		ed \
		less \
		locales \
		vim-tiny \
		wget \
		ca-certificates \
		apt-transport-https \
		gsfonts \
		gnupg2 \
	&& rm -rf /var/lib/apt/lists/*

# Configure default locale, see https://github.com/rocker-org/rocker/issues/19
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
	&& locale-gen en_US.utf8 \
	&& /usr/sbin/update-locale LANG=en_US.UTF-8

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

RUN add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/'

# note the proxy for gpg
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9

ENV R_BASE_VERSION 3.6.2

# Now install R and littler, and create a link for littler in /usr/local/bin
# Also set a default CRAN repo, and make sure littler knows about it too
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		littler \
        r-cran-littler \
		r-base=${R_BASE_VERSION}* \
		r-base-dev=${R_BASE_VERSION}* \
		r-recommended=${R_BASE_VERSION}* \
        && echo 'options(repos = c(CRAN = "https://cloud.r-project.org/"), download.file.method = "libcurl")' >> /etc/R/Rprofile.site \
        && echo 'source("/etc/R/Rprofile.site")' >> /etc/littler.r \
	&& ln -s /usr/share/doc/littler/examples/install.r /usr/local/bin/install.r \
	&& ln -s /usr/share/doc/littler/examples/install2.r /usr/local/bin/install2.r \
	&& ln -s /usr/share/doc/littler/examples/installGithub.r /usr/local/bin/installGithub.r \
	&& ln -s /usr/share/doc/littler/examples/testInstalled.r /usr/local/bin/testInstalled.r \
	&& install.r docopt \
	&& rm -rf /tmp/downloaded_packages/ /tmp/*.rds \
	&& rm -rf /var/lib/apt/lists/*  

RUN pip install -U setuptools
RUN R --slave -e "install.packages(c('BiocManager','devtools', 'gplots', 'R.utils', 'Seurat', 'rmarkdown', 'RColorBrewer', 'Cairo','dplyr','tidyr','magrittr','matrixStats','readr','openxlsx','PerformanceAnalytics','pheatmap','gridExtra','dendextend','scales','ggrepel'), dependencies = TRUE, repos='https://cloud.r-project.org')"
RUN R --slave -e "BiocManager::install(c('BiocParallel','GenomicAlignments', 'GenomicRanges','rtracklayer', 'Rsamtools','limma','edgeR','org.Mm.eg.db','org.Hs.eg.db','org.Ce.eg.db','org.Dm.eg.db','ChIPseeker','clusterProfiler','Rsubread','SummarizedExperiment','DESeq2','APAlyzer'))"   
RUN mkdir -p /nl
RUN mkdir -p /project
RUN mkdir -p /share
#X11 display fix
#Xvfb :0 -ac -screen 0 1960x2000x24 &