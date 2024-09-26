#' cociente_medias UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
#' @import meta
mod_cociente_medias_ui <- function(id) {
  ns <- NS(id)
  tagList(
    selectInput(ns("author"),
                "Seleccionar autor",
                choices = NULL),

    selectInput(ns("año"),
                "Seleccionar año",
                choices = NULL),

    selectInput(ns("N_e"),
                "Seleccionar Ne (N de experimento)",
                choices = NULL),

    selectInput(ns("M_e"),
                "Seleccionar Me (Media de experimento)",
                choices = NULL),

    selectInput(ns("S_e"),
                "Seleccionar Se (Desvio estandar de experimento)",
                choices = NULL),

    selectInput(ns("N_c"),
                "Seleccionar Nc (N de control)",
                choices = NULL),

    selectInput(ns("M_c"),
                "Seleccionar Mc (Media de control)",
                choices = NULL),

    selectInput(ns("S_c"),
                "Seleccionar Sc (Desvio estandar de control)",
                choices = NULL),

    selectInput(ns("Sub"),
                "Seleccionar sub-grupos",
                choices = c("",NULL),
                selected = ""),

    actionButton(ns("run_model"), "Correr modelo"),


    uiOutput(ns("model_summary")),

    uiOutput(ns("forest_plot"))
  )



}

#' cociente_medias Server Functions
#'
#' @noRd
mod_cociente_medias_server <- function(id, file_data){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

    observe({
      df <- file_data()
      req(df)

      updateSelectInput(session, "author", choices = names(df))
      updateSelectInput(session, "año", choices = names(df))
      updateSelectInput(session, "N_e", choices = names(df))
      updateSelectInput(session, "M_e", choices = names(df))
      updateSelectInput(session, "S_e", choices = names(df))
      updateSelectInput(session, "N_c", choices = names(df))
      updateSelectInput(session, "M_c", choices = names(df))
      updateSelectInput(session, "S_c", choices = names(df))
      updateSelectInput(session, "Sub", choices = c("",names(df)))

    })

    model <- eventReactive(input$run_model, {
      df <- file_data
      req(df)
      req(input$N_e, input$M_e, input$S_e, input$N_c, input$M_c, input$S_c)

      metaanalisis_df <- data.frame(
        Ne = df[[input$N_e]],
        Me = df[[input$M_e]],
        Se = df[[input$S_e]],
        Nc = df[[input$N_c]],
        Mc = df[[input$M_c]],
        Sc = df[[input$S_c]],
        Subgroup = if (!is.null(input$Sub)) df[[input$Sub]] else NULL,
        Author = if (!is.null(input$author)) df[[input$author]] else NULL
      )
      print(metaanalisis_df)

      m <- meta::metacont(
        Ne = metaanalisis_df$Ne,
        Me = metaanalisis_df$Me,
        Se = metaanalisis_df$Se,
        Nc = metaanalisis_df$Nc,
        Mc = metaanalisis_df$Mc,
        Sc = metaanalisis_df$Sc,
        sm = "ROM",  # Cociente de medias
        studlab = metaanalisis_df$Author,  # Etiquetas de estudios (autores)
        comb.fixed = TRUE,  # Combinar con efectos fijos
        comb.random = FALSE,  # No usar efectos aleatorios en este ejemplo
        outclab = "Metaanálisis de Efectos Fijos para Cociente de Medias",
        method.tau = "DL",  # Método de DerSimonian-Laird para la heterogeneidad
        backtransf = TRUE,  # Transformación inversa para el cociente
        subgroup = metaanalisis_df$Subgroup  # Subgrupo si existe
      )

      return(m)

    })

    output$model_summary <- renderPrint({
      req(model())  # Requerimos que el modelo esté generado
      summary(model())  # Mostrar el resumen del modelo ajustado
      model_summary
    })

    output$forest_plot <- renderPlot({
      req(model())  # Requerimos el modelo ajustado
      meta::forest(model())  # Gráfico forest para el metaanálisis
    })

  })
}

## To be copied in the UI
# mod_cociente_medias_ui("cociente_medias_1")

## To be copied in the server
# mod_cociente_medias_server("cociente_medias_1")
