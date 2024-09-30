#' forestplot UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
#'
mod_forestplot_ui <- function(id) {
  ns <- NS(id)
  tagList(

    bslib::card(
    style = "overflow-y: auto; height: 600px;",
    div(
      style = "overflow-y: auto;",
    uiOutput(ns("dynamic_plot_ui"))
    ),

    downloadButton(ns("download_plot"), "Descargar Forest plot"))

  )
}

#' forestplot Server Functions
#'
#' @noRd
mod_forestplot_server <- function(id, model){
  moduleServer(id, function(input, output, session){

    ns <- session$ns

    output$dynamic_plot_ui <- renderUI({
      req(model())
      total_studies <- length(model()$studlab)
      # Calcular la altura del gráfico basada en la cantidad de estudios
      plot_height <- 300 + total_studies * 20  # Ajustar valores si es necesario
      plotOutput(ns("forest_plot"), height = paste0(plot_height, "px"))
    })

    output$forest_plot <- renderPlot({
      req(model())
      par(mar = c(4, 4, 2, 1))
      meta::forest(model(),
                   col.diamond = "blue",  # Color del diamante
                   col.square = "black",  # Color de los cuadrados
                   col.square.lines = "black")  # Color de las líneas
    })

    # Descargar el forest plot en PNG
    output$download_plot <- downloadHandler(
      filename = function() {
        paste("forest_plot_", Sys.Date(), ".png", sep = "")
      },
      content = function(file) {
        req(model())  # Verificar que el modelo esté disponible
        save_forest_plot_png(model(), file)  # Generar el archivo PNG
      },
      contentType = "image/png"
    )

  })
}
m$sm

