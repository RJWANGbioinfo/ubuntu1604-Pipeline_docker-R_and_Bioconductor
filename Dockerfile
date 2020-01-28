FROM ubuntu:xenial

LABEL maintainer="Ruijia(Ray) Wang <Ruijia.Wang@umassmed.edu>"

ENV OS_IDENTIFIER ubuntu-1604

RUN set -x \
  && sed -i "s|# deb-src|deb-src|g" /etc/apt/sources.list \
  && export DEBIAN_FRONTEND=noninteractive \
  && apt-get update \
  && apt-get install -y software-properties-common apt-transport-https ca-certificates apt-utils\
  && add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/' \
  && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 \    
  && apt-get update \  
  && apt-get install -y r-base-core r-base r-base-dev r-recommended \
  && apt-get install -y libc6 libcurl4-openssl-dev libicu-dev libopenblas-base wget python-pip ruby ruby-dev

RUN pip install awscli

RUN gem install fpm

RUN chmod 0777 /opt

# Override the default pager used by R
ENV PAGER /usr/bin/pager

# Install packages
RUN apt-get update && apt-get install -y --no-install-recommends \
                ghostscript \
                lmodern \
                pandoc-citeproc \
                qpdf \
                pandoc \
                r-cran-formatr \
                r-cran-ggplot2 \
                r-cran-runit \
                r-cran-testthat \
                texinfo \
                texlive-fonts-extra \
                texlive-fonts-recommended \
                texlive-latex-extra \
                texlive-latex-recommended \
                texlive-luatex \
                texlive-science \
                texlive-xetex \
		unzip libsqlite3-dev libbz2-dev libssl-dev python python-dev \
                python-pip git libxml2-dev software-properties-common wget tree vim sed \
                subversion g++ gcc gfortran curl zlib1g-dev build-essential \
		libffi-dev  

RUN pip install -U setuptools
RUN R --slave -e "install.packages(c('BiocManager','devtools', 'gplots', 'R.utils', 'Seurat', 'rmarkdown', 'RColorBrewer', 'Cairo','dplyr','tidyr','magrittr','matrixStats','readr','openxlsx','PerformanceAnalytics','pheatmap','gridExtra','dendextend','scales','ggrepel'), dependencies = TRUE, repos='https://cloud.r-project.org')"
RUN R --slave -e "BiocManager::install(c('BiocParallel','GenomicAlignments', 'GenomicRanges','rtracklayer', 'Rsamtools','limma','edgeR','org.Mm.eg.db','org.Hs.eg.db','org.Ce.eg.db','org.Dm.eg.db','ChIPseeker','clusterProfiler','Rsubread','SummarizedExperiment','DESeq2','APAlyzer'))"   
RUN mkdir -p /nl
RUN mkdir -p /project
RUN mkdir -p /share
#X11 display fix
#Xvfb :0 -ac -screen 0 1960x2000x24 &