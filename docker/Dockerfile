FROM rocker/shiny:latest

MAINTAINER Andy Pohl "apohl@morgridge.org"



RUN wget -O- http://neuro.debian.net/lists/jessie.us-ca.full | tee /etc/apt/sources.list.d/neurodebian.sources.list && \
    apt-key adv --recv-keys --keyserver hkp://pgp.mit.edu:80 0xA5D32F012649A5A9 && \
    apt-get update && \
    apt-get install -y --no-install-recommends freeglut3 freeglut3-dev fsl-complete

RUN Rscript -e "install.packages('shinydashboard')" && \
    Rscript -e "install.packages('rgl');" && \
    Rscript -e "install.packages('misc3d');" && \
    Rscript -e "install.packages('oro.nifti');" && \
    Rscript -e "install.packages('brainR');" && \
    Rscript -e "install.packages('fslr');" 

CMD ["/usr/bin/shiny-server.sh"]
