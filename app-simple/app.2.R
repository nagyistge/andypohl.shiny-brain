## app.R ##
library(shinydashboard)
suppressMessages(library(fslr))
options(fsl.path="/usr/bin")

## UI PART

ui <- dashboardPage(
  dashboardHeader(title = "fslr + Shiny"), 
  dashboardSidebar(NULL, disable=TRUE),
  dashboardBody(
    fluidRow(
         box(title = "View", imageOutput("brainimages", height=600, width=200), width=3),
         box(title = "Controls", uiOutput("sliders"), width=3),
         box(title = "Histogram", plotOutput("histplot"), width=5)
    )
  )
)

## SERVER PART

server <- function(input, output)
{
  # Load the image at startup and when the sidebar selection changes.
  brain_img <- readNIfTI("data/3d.nii.gz")

  # Any time a slider moves, a new PNG is made and deleted.  The ortho2() function
  # is used to have better control over the brain pane layout (with mfrow)
  output$brainimages <- renderImage(
  {
      width <- 200
      height <- width*3
      outfile <- tempfile(fileext = ".png")
      png(filename=outfile, width=width, height=height)
      ortho2(brain_img, xyz=c(input$slider_x, input$slider_y, input$slider_z), NULL, mfrow=c(3,1))
      suppressMessages(dev.off())
      return(list(src = outfile, contentType = "image/png"))
  }, deleteFile = TRUE)

  output$ui <- renderUI({
      img_dim <- dim(brain_img)
      max_x <- img_dim[1]
      max_y <- img_dim[2]
      max_z <- img_dim[3]
      return(list(
             "slider_x" <- sliderInput(inputId="slider_x", label="x", min=1, max=max_x, value=max_x/2, step=1),
             "slider_y" <- sliderInput(inputId="slider_y", label="y", min=1, max=max_y, value=max_y/2, step=1),
             "slider_z" <- sliderInput(inputId="slider_z", label="z", min=1, max=max_z, value=max_z/2, step=1)
	     ))
  })
  
  # Here will go the plot code.  Something like:
  output$histplot <- renderPlot(
  {
      # Collect data on z plane, and make a histogram plot.  This is really dumb
      # but typical R array slicing doesn't seem to work on nifti image objects.
      x <- input$slider_x
      y <- input$slider_y
      xlab <- "z-plane data"
      data <- NULL
      img_dim <- dim(brain_img)
      for (z in 1:img_dim[3]) 
          data <- append(data,brain_img[x,y,z])
      hist(data, main=NULL, xlab=xlab)
  })
}

## Required
shinyApp(ui, server)
