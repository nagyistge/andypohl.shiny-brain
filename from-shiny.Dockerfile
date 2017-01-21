FROM rocker/shiny

MAINTAINER "Andy Pohl" andy.pohl@wisc.edu

RUN apt-get update \
    && apt-get install -y -t unstable \
        gnupg2 \
        apt-transport-https \
        libvtk6.3 \
    && wget -O- http://neuro.debian.net/lists/sid.de-m.full | tee /etc/apt/sources.list.d/neurodebian.sources.list \
    && apt-key adv --recv-keys --keyserver hkp://pgp.mit.edu:80 0xA5D32F012649A5A9 \
    && apt-get install -y fsl-complete
# This line above isn't working.  libvtk5.10 seems to be the only thing fsl-complete can use
# and it seems to be unavailable in debian sid.  Thus making the whole thing from 
# ubuntu xenial is the way for now.

ENV FSLDIR=/usr/lib/fsl/5.0
ENV FSLOUTPUTTYPE=NIFTI_GZ
ENV PATH=$PATH:$FSLDIR 
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$FSLDIR
