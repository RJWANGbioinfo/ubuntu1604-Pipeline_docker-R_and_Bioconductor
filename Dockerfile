FROM ubuntu:xenial

LABEL maintainer="Ruijia(Ray) Wang <Ruijia.Wang@umassmed.edu>"

ENV OS_IDENTIFIER ubuntu-1604

RUN set -x \
  && sed -i "s|# deb-src|deb-src|g" /etc/apt/sources.list \
  && export DEBIAN_FRONTEND=noninteractive \
  && apt-get update \
  && apt-get install -y libcurl4-openssl-dev libicu-dev libopenblas-base wget python-pip ruby ruby-dev \
  && apt-get build-dep -y r-base

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