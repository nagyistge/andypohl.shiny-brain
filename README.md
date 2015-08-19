# shiny-brain
Example of an RStudio Shiny app navigating MRI images.

## Strategy:
- Augment rocker/shiny docker image with R brain imaging libraries like BrainR, fslr, etc.
- Shiny docker container run like:
```
$ docker run -d -v /Users/andy/shiny-brain/app:/srv/shiny-server/shiny-brain -p 3838:3838 andypohl/shiny-brain
```
(going to http://docker-ip:3838/shiny-brain runs the app)
- the app/ subdirectory contains everything for the app apart from data.
- the data (NIfTI images), should go in the app/data directory.
