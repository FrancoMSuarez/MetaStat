#' home UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_home_ui <- function(id) {
  ns <- NS(id)
  tagList(
    div(
      id = "content",
      class = "app-header",
      style = "display: flex; flex-direction: column; align-items: center;",
      h1(style = "text-align: center; margin-bottom: 10px;",
       'Bienvenidos a MetaStat'),
      img(
        id = "logo",
        class = "ribbon",
        height = "150",
        width = 'auto',
        alt = '',
        src="www/Imagen1.png"
      )
    ),

    div(
      style = "text-align: center; margin-top: 20px; margin-bottom: 20px;",
      actionButton(
        ns("startContinuos"),
        "Datos Continuos",
        icon = icon("play-circle"),
        class = "btn-primary",
        style = 'text-align: center; font-size:110%;'
      ),

      actionButton(
        ns("startDiscretos"),
        "Datos Discretos",
        icon = icon("play-circle"),
        class = "btn-secondary",
        style = 'text-align: center; font-size:110%;'
      )
      ),
    fluidRow(
      class = "gap-3",
      bslib::accordion(
        id = "acc",
        open = FALSE,
        class = "mb-3",
        bslib::accordion_panel(
          title = "Herramientas",
          div(
            class = "mt-3 mb-1",
            fluidRow(

              # Texto de ancho completo (12 columnas)
              column(
                width = 12,
                HTML(
                  "<p>MetaStat te permite realizar metaanálisis de datos <strong>continuos</strong> y <strong>discretos</strong> con modelos de <em>efectos fijos</em> o <em>aleatorios</em>.<br>
              También podés explorar <strong>subgrupos</strong>, crear <em>forest plots</em>, <em>funnel plots</em> y realizar <strong>metarregresiones</strong>.</p>"
                )
              ),

              # Columnas de herramientas
              column(
                width = 6,
                h5("Datos continuos"),
                tags$ul(
                  tags$li("Cociente de medias"),
                  tags$li("Correlaciones"),
                  tags$li("Diferencia de medias"),
                  tags$li("Diferencia de medias estandarizada"),
                  tags$li("Media")
                )
              ),
              column(
                width = 6,
                h5("Datos discretos"),
                tags$ul(
                  tags$li("Cociente de chances"),
                  tags$li("Diferencia de arcoseno"),
                  tags$li("Diferencia de riesgo"),
                  tags$li("Estimación de una proporción"),
                  tags$li("Riesgo relativo")
                )
              )
            )
          )
        ),
        bslib::accordion_panel(
          title = "Contacto",
          div(
            HTML(
              paste0(
                "<p>Si tenés alguna consulta, podés comunicarte escribiendo a ",
                "<i class='fa fa-envelope'></i> <a href='mailto:cebruno@agro.unc.edu.ar'><strong>cebruno@agro.unc.edu.ar</strong></a> o a ",
                "<i class='fa fa-envelope'></i> <a href='mailto:suarezfranco@agro.unc.edu.ar'><strong>suarezfranco@agro.unc.edu.ar</strong></a>.</p>",

                "<p><i class='fa fa-book'></i> Además, podés acceder a una <strong>guía tutorial</strong> a través del siguiente ",
                "<a href='https://www.ejemplo.com/tutorial' target='_blank'>enlace</a>.</p>",

                "<p><strong>Cómo citar este software:</strong><br>Suarez y Bruno. (2025). ",
                "<em>MetaStat: Software Estadístico para Metaanálisis</em>. Estadística y Biometría. FCA.UNC. CONICET. Argentina. ",
                "Patente de invención. Registro N°44020721. ",
                "<a href='https://francosuarez.shinyapps.io/metastat/' target='_blank'>https://francosuarez.shinyapps.io/metastat/</a></p>"
              )
          )
        )
      )



    )




)
)

}

#' home Server Functions
#'
#' @noRd
mod_home_server <- function(id){
  moduleServer(id, function(input, output, session) {

    selected_page <- reactiveVal(NULL)

    observeEvent(input$startContinuos, {
      selected_page("continuos")
    })

    observeEvent(input$startDiscretos, {
      selected_page("discretos")
    })

    # observeEvent(input$navbar, {
    #   browser()
    #   selected_page(NULL)
    # })

    observeEvent(input$navbar, {
      if (input$navbar == "navhome") {
        selected_page(NULL)
      }
    })


    return(selected_page)
  })



  #   selected_page <- reactive({
  #     if (input$startContinuos > 0) {
  #       return("continuos")
  #     } else if (input$startDiscretos > 0) {
  #       return("discretos")
  #     } else  {
  #       return(NULL)
  #     }
  #   })
  #
  #   return(selected_page)
  # })
}

## To be copied in the UI
# mod_home_ui("home_1")

## To be copied in the server
# mod_home_server("home_1")


