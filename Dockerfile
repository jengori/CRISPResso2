############################################################
# Dockerfile to build CRISPResso2
############################################################

#FROM continuumio/miniconda3
FROM mambaorg/micromamba:1.5.8

USER root

# File Author / Maintainer
MAINTAINER Kendell Clement
RUN apt-get update && apt-get install -y --no-install-recommends \
      gcc g++ bowtie2 samtools libsys-hostname-long-perl \
      curl bzip2 \
  && apt-get clean \
  && apt-get autoremove -y \
  && rm -rf /var/lib/apt/lists/* /usr/share/man/* /usr/share/doc/*

# install Python + CRISPResso2 Python dependencies using Micromamba
RUN micromamba install -y -n base -c conda-forge -c bioconda \
      python=3.11 \
      fastp numpy cython jinja2 tbb=2020.2 pyparsing=2.3.1 \
      scipy matplotlib-base pandas plotly seaborn \
  && micromamba clean --all --yes

# install ms fonts (from Buster archive)
RUN echo "deb http://archive.debian.org/debian buster main contrib" > /etc/apt/sources.list \
  && echo "deb http://archive.debian.org/debian-security buster/updates main contrib" >> /etc/apt/sources.list \
  && apt-get update -o Acquire::Check-Valid-Until=false \
  && echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | debconf-set-selections \
  && apt-get install -y ttf-mscorefonts-installer \
  && apt-get clean \
  && apt-get autoremove -y \
  && rm -rf /var/lib/apt/lists/* /usr/share/man/* /usr/share/doc/* /usr/share/zoneinfo

# install crispresso
COPY . /CRISPResso2
WORKDIR /CRISPResso2

# Install CRISPResso2 using micromamba run
RUN micromamba run -n base python setup.py install \
  && micromamba run -n base CRISPResso -h \
  && micromamba run -n base CRISPRessoBatch -h \
  && micromamba run -n base CRISPRessoPooled -h \
  && micromamba run -n base CRISPRessoWGS -h \
  && micromamba run -n base CRISPRessoCompare -h

ENTRYPOINT ["micromamba", "run", "-n", "base", "python", "/CRISPResso2/CRISPResso2_router.py"]