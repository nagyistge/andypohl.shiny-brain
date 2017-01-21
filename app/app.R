## app.R ##
library(shinydashboard)
suppressMessages(library(fslr))
options(fsl.path="/usr/bin")

## UI PART

ui <- dashboardPage(
  dashboardHeader(title = "fslr + Shiny"),
  dashboardSidebar(selectInput(inputId="filename", label="File", choices=list.files("data/"))),
  dashboardBody(
    fluidRow(
         # Width in layout adds up to 12 for all the boxes
         box(title = "View", imageOutput("brainimages", height=600, width=200), width=3),
         box(title = "Controls", uiOutput("ui"), width=3),
         box(title = "Histogram", plotOutput("lineplot"), width=5)
    )
  )
)

## SERVER PART

server <- function(input, output)
{
  # Load the image at startup and when the sidebar selection changes.
  img <- reactive({ readNIfTI(paste("data", input$filename, sep="/")) })

  # Any time a slider moves, a new PNG is made and deleted.  The ortho2() function
  # is used to have better control over the brain pane layout (with mfrow)
  output$brainimages <- renderImage(
  {
      w <- NULL
      if (length(dim(img())) > 3)
         w <- input$slider_w
      width <- 200
      height <- width*3
      outfile <- tempfile(fileext = ".png")
      png(filename=outfile, width=width, height=height)
      ortho2(img(), xyz=c(input$slider_x, input$slider_y, input$slider_z), w=w, mfrow=c(3,1))
      suppressMessages(dev.off())
      return(list(src = outfile, contentType = "image/png"))
  }, deleteFile = TRUE)

  # The slider controls are dynamic, i.e. the max values depend on the image dimensions,
  # so they are set up on the server.
  output$ui <- renderUI({
      img_dim <- dim(img())
      max_x <- img_dim[1]
      max_y <- img_dim[2]
      max_z <- img_dim[3]
      max_w <- img_dim[4]
      # this seems like it could be more elegant, but the append function did something strange.
      if (length(img_dim) > 3)
           return(list(
             "slider_x" <- sliderInput(inputId="slider_x", label="x", min=1, max=max_x, value=max_x/2, step=1),
             "slider_y" <- sliderInput(inputId="slider_y", label="y", min=1, max=max_y, value=max_y/2, step=1),
             "slider_z" <- sliderInput(inputId="slider_z", label="z", min=1, max=max_z, value=max_z/2, step=1),
	           "slider_w" <- sliderInput(inputId="slider_w", label="w", min=1, max=max_w, value=1, step=1)
	          ))
      return(list(
             "slider_x" <- sliderInput(inputId="slider_x", label="x", min=1, max=max_x, value=max_x/2, step=1),
             "slider_y" <- sliderInput(inputId="slider_y", label="y", min=1, max=max_y, value=max_y/2, step=1),
             "slider_z" <- sliderInput(inputId="slider_z", label="z", min=1, max=max_z, value=max_z/2, step=1)
	     ))
  })

  # Here will go the plot code.  Something like:
  output$lineplot <- renderPlot(
  {
      # Collect data on w/z hyperplane, and make a histogram plot.  This is really dumb
      # but typical R array slicing doesn't seem to work on nifti image objects.
      x <- input$slider_x
      y <- input$slider_y
      xlab <- "z-plane data"
      data <- NULL
      imgg <- img()
      img_dim <- dim(imgg)
      if (length(img_dim) > 3)
      {
        xlab <- "z/w-hyperplane data"
        for (z in 1:img_dim[3]) 
          for (w in 1:img_dim[4])
            data <- append(data,imgg[x,y,z,w])
      }
      else
        for (z in 1:img_dim[3]) 
          data <- append(data,imgg[x,y,z])
      hist(data, main=NULL, xlab=xlab)
  })
}

## Required
shinyApp(ui, server)
