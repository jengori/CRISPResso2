############################################################
# Dockerfile to build CRISPResso2
############################################################

#FROM continuumio/miniconda3
FROM condaforge/miniforge3

# File Author / Maintainer
MAINTAINER Kendell Clement
RUN apt-get update && apt-get install gcc g++ bowtie2 samtools libsys-hostname-long-perl \
  -y --no-install-recommends \
  && apt-get clean \
  && apt-get autoremove -y \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /usr/share/man/* \
  && rm -rf /usr/share/doc/* \
  && conda install -c conda-forge -c bioconda -y -n base --debug fastp numpy cython jinja2 tbb=2020.2 pyparsing=2.3.1 scipy matplotlib-base pandas plotly seaborn\
  && conda clean --all --yes

# install ms fonts (from Buster archive)
RUN echo "deb [trusted=yes] http://archive.debian.org/debian buster main contrib" > /etc/apt/sources.list \
  && echo "deb [trusted=yes] http://archive.debian.org/debian-security buster/updates main contrib" >> /etc/apt/sources.list \
  && apt-get -o Acquire::Check-Valid-Until=false update \
  && echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | debconf-set-selections \
  && apt-get install -y ttf-mscorefonts-installer \
  && apt-get clean \
  && apt-get autoremove -y \
  && rm -rf /var/lib/apt/lists/* /usr/share/man/* /usr/share/doc/* /usr/share/zoneinfo

# install crispresso
COPY . /CRISPResso2
WORKDIR /CRISPResso2
RUN python setup.py install \
  && CRISPResso -h \
  && CRISPRessoBatch -h \
  && CRISPRessoPooled -h \
  && CRISPRessoWGS -h \
  && CRISPRessoCompare -h


ENTRYPOINT ["python","/CRISPResso2/CRISPResso2_router.py"]