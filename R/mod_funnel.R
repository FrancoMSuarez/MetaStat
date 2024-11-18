#' funnel UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_funnel_ui <- function(id) {
  ns <- NS(id)
  tagList(
    bslib::card(
      style = "overflow-y: auto; height: 600px;",

      checkboxInput(ns("show_studlab"), "Mostrar estudios", value = TRUE),

      div(
        style = "overflow-y: auto;",
        plotOutput(ns("funnel_plot"))
      ),

      downloadButton(ns("download_plot"), "Descargar Funnel plot"),


      div(style = "overflow-y: auto;",
          plotOutput(ns("baujat_plot"))),


      downloadButton(ns("download_plot2"), "Descargar Baujat plot"),



  ))
}

#' funnel Server Functions
#'
#' @noRd
mod_funnel_server <- function(id, model){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

    output$funnel_plot <- renderPlot({
      req(model())

      print(model())

      par(mar = c(4, 4, 2, 1))
      meta::funnel(model(), studlab = input$show_studlab)
    })


    output$baujat_plot <- renderPlot({
      req(model())

      print(model())

      par(mar = c(4, 4, 2, 1))
      meta::baujat(model(), studlab = input$show_studlab)
    })

    output$download_plot <- downloadHandler(
      filename = function() {
        paste("funnel_plot_", Sys.Date(), ".png", sep = "")
      },
      content = function(file) {
        req(model())  # Verificar que el modelo esté disponible
        save_funnel_plot_png(model(), file)  # Generar el archivo PNG
      },
      contentType = "image/png"
    )

    output$download_plot2 <- downloadHandler(
      filename = function() {
        paste("baujat_plot_", Sys.Date(), ".png", sep = "")
      },
      content = function(file) {
        req(model())  # Verificar que el modelo esté disponible
        save_baujat_plot_png(model(), file)  # Generar el archivo PNG
      },
      contentType = "image/png"
    )



  })
}

## To be copied in the UI
# mod_funnel_ui("funnel_1")

## To be copied in the server
# mod_funnel_server("funnel_1")
