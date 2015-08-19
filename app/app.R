## app.R ##
library(shinydashboard)
suppressMessages(library(fslr))
options(fsl.path="/usr/bin")

ui <- dashboardPage(
  dashboardHeader(title = "fslr + Shiny"),
  dashboardSidebar(selectInput(inputId="filename", label="File", choices=list.files("data/"))),
  dashboardBody(
    # Boxes need to be put in a row (or column)
    fluidRow(
         box(imageOutput("brainimages", height=600, width=200), width=3),
         box(title = "Controls", uiOutput("ui"), width=3)
    )
  )
)

server <- function(input, output) {
  # Load the image once.  If we make this selectable, then it'd
  # be a reactive load
  img <- readNIfTI("data/4d.nii.gz")

  output$brainimages <- renderImage({
      w <- NULL
      if (length(dim(img)) > 3)
         w <- input$slider_w
      width <- 200
      height <- width*3
      outfile <- tempfile(fileext = ".png")
      png(filename=outfile, width=width, height=height)
      ortho2(img, xyz=c(input$slider_x, input$slider_y, input$slider_z), w=w, mfrow=c(3,1))
      suppressMessages(dev.off())
      return(list(src = outfile, contentType = "image/png"))
  }, deleteFile = FALSE)

  output$ui <- renderUI({
      img_dim = dim(img)
      max_x = img_dim[1]
      max_y = img_dim[2]
      max_z = img_dim[3]
      max_w = img_dim[4]
      if (length(dim(img)) > 3)
           return(list(
             "slider_x" <- sliderInput(inputId="slider_x", label="x", min=1, max=max_x, value=max_x/2, step=1),
             "slider_y" <- sliderInput(inputId="slider_y", label="y", min=1, max=max_y, value=max_y/2, step=1),
             "slider_z" <- sliderInput(inputId="slider_z", label="z", min=1, max=max_z, value=max_z/2, step=1),
	     "slider_w"<- sliderInput(inputId="slider_w", label="w", min=1, max=max_w, value=1, step=1)
	     ))
      return(list(
             "slider_x" <- sliderInput(inputId="slider_x", label="x", min=1, max=max_x, value=max_x/2, step=1),
             "slider_y" <- sliderInput(inputId="slider_y", label="y", min=1, max=max_y, value=max_y/2, step=1),
             "slider_z" <- sliderInput(inputId="slider_z", label="z", min=1, max=max_z, value=max_z/2, step=1)
	     ))
  })
}

shinyApp(ui, server)
