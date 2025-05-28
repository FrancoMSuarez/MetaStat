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
#
mod_forestplot_ui <- function(id) {
  ns <- NS(id)
  tagList(
    bslib::card(
      style = "overflow: auto; width: 100%; height: auto;",  # Permite el autoajuste, # Quitar bordes, sombra y relleno
      div(
        style = "overflow-y: auto;",
        uiOutput(ns("dynamic_controls_ui"))
      ),
      div(
        style = "overflow-y: auto; ",
        uiOutput(ns("dynamic_plot_ui"))
      ),
      downloadButton(ns("download_plot"), "Descargar Forest plot"),
      downloadButton(ns("download_plot2"), "Descargar Forest plot pdf")
    )
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
#browser()
      total_studies <- length(model()$studlab)
      # Calcular la altura del gráfico basada en la cantidad de estudios
      plot_height <- max(700, 10 + total_studies * 17)  # Ajustar valores si es necesario
      div(
        style = "flex-grow: 1; overflow-y: auto; border: 1px solid #ccc; padding: 2px;",
        div(
          style = "min-height: 100%;  justify-content: center;",
          plotOutput(ns("forest_plot"), height = paste0(plot_height, "px"))
        )
      )

    })

    # output$forest_plot <- renderPlot({
    #   req(model())
    #
    #   #print(model())
    #
    #   browser()
    #
    #   par(mar = c(1, 1, 2, 1))
    #   model <- model()
    #   meta::forest(model(),
    #                col.diamond = "blue",  # Color del diamante
    #                col.square = "black",  # Color de los cuadrados
    #                col.square.lines = "black")  # Color de las líneas
    # })

    output$forest_plot <- renderPlot({
      req(model())
      par(mar = c(5, 4, 5, 2))
      generate_forest_plot(model())
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


    output$download_plot2 <- downloadHandler(
      filename = function() {
        paste("forest_plot_", Sys.Date(), ".pdf", sep = "")
      },
      content = function(file) {
        req(model())  # Verificar que el modelo esté disponible
        message("Descarga iniciada, generando archivo PDF en: ", file)
        save_forest_plot_pdf(model(), file)  # Generar el archivo PNG
        message("Archivo PDF generado correctamente.")
      },
      contentType = "application/pdf"
    )




  })







}


## To be copied in the UI
# mod_forestplot_ui("forestplot_1")

## To be copied in the server
# mod_forestplot_server("forestplot_1")


#
# mod_forestplot_ui <- function(id) {
#   ns <- NS(id)
#   tagList(
#     bslib::card(
#       style = "overflow: auto; width: 100%; height: auto;",  # Permite el autoajuste, # Quitar bordes, sombra y relleno
#       div(
#         style = "overflow-y: auto;",
#         uiOutput(ns("dynamic_controls_ui"))
#       ),
#       div(
#         style = "overflow-y: auto; ",
#         uiOutput(ns("dynamic_plot_ui"))
#       ),
#       downloadButton(ns("download_plot"), "Descargar Forest plot"),
#       downloadButton(ns("download_plot2"), "Descargar Forest plot pdf")
#     )
#   )
# }


# mod_forestplot_server <- function(id, model) {
#   moduleServer(id, function(input, output, session) {
#     ns <- session$ns
#
#     # Generar opciones dinámicas basadas en las columnas del modelo
#     output$dynamic_controls_ui <- renderUI({
#       req(model())
#       all_columns <- names(model()$data) # Asume que las columnas están en model()$data
#       available_columns <- grep("^\\.", all_columns, value = TRUE, invert = F)
#
#       tagList(
#         tags$style(HTML(
#           sprintf(
#             "#%s .checkbox { display: inline-block; margin-right: 60px; }",
#             ns("columns_to_display")
#           )
#         )),
#         checkboxGroupInput(
#           ns("columns_to_display"),
#           "Seleccionar columnas para mostrar:",
#           choices = available_columns,
#           selected = available_columns # Preseleccionar todas
#         )
#       )
#     })
#
#     # Generar el gráfico dinámico
#     output$dynamic_plot_ui <- renderUI({
#       req(model())
#
#       total_studies <- length(model()$studlab)
#       # Calcular la altura del gráfico basada en la cantidad de estudios
#       plot_height <- 10 + total_studies * 50  # Ajustar valores si es necesario
#       plotOutput(ns("forest_plot"), height = paste0(plot_height, "px"))
#     })
#
#     output$forest_plot <- renderPlot({
#       req(model(), input$columns_to_display)
#
#       # Filtrar las columnas seleccionadas
#       selected_columns <- input$columns_to_display
#       filtered_model_data <- model()$data[, selected_columns, drop = FALSE]
#
#       # Crear un modelo temporal con los datos filtrados
#       temp_model <- model()
#       temp_model$data <- filtered_model_data
#
#       # Graficar con las columnas seleccionadas
#       par(mar = c(1, 1, 2, 1))
#       meta::forest(temp_model,
#                    col.diamond = "blue",  # Color del diamante
#                    col.square = "black",  # Color de los cuadrados
#                    col.square.lines = "black",
#                    leftcols = selected_columns)  # Color de las líneas
#     })
#
#     # Descargar el forest plot en PNG
#     output$download_plot <- downloadHandler(
#       filename = function() {
#         paste("forest_plot_", Sys.Date(), ".png", sep = "")
#       },
#       content = function(file) {
#         req(model(), input$columns_to_display)
#         selected_columns <- input$columns_to_display
#         filtered_model_data <- model()$data[, selected_columns, drop = FALSE]
#
#         temp_model <- model()
#         temp_model$data <- filtered_model_data
#         save_forest_plot_png(temp_model, file)  # Generar el archivo PNG
#       },
#       contentType = "image/png"
#     )
#
#     # Descargar el forest plot en PDF
#     output$download_plot2 <- downloadHandler(
#       filename = function() {
#         paste("forest_plot_", Sys.Date(), ".pdf", sep = "")
#       },
#       content = function(file) {
#         req(model(), input$columns_to_display)
#         selected_columns <- input$columns_to_display
#         filtered_model_data <- model()$data[, selected_columns, drop = FALSE]
#
#         temp_model <- model()
#         temp_model$data <- filtered_model_data
#         save_forest_plot_pdf(temp_model, file)  # Generar el archivo PDF
#       },
#       contentType = "application/pdf"
#     )
#   })
# }
