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
      h1(style = "text-align: center",
       'Bienvenidos a MetaStat')),

    div(
      style = "text-align: center;",
      actionButton(
        ns("startContinuos"),
        "Datos Continuos",
        icon = icon("play-circle"),
        class = "btn-success",
        style = 'text-align: center; font-size:110%;'
      ),

      actionButton(
        ns("startDiscretos"),
        "Datos Discretos",
        icon = icon("play-circle"),
        class = "btn-primary",
        style = 'text-align: center; font-size:110%;'
      )
      )

    )

}

#' home Server Functions
#'
#' @noRd
mod_home_server <- function(id){
  moduleServer(id, function(input, output, session) {

    reactive({
      if (input$startContinuos > 0) {
        return("continuos")
      } else if (input$startDiscretos > 0) {
        return("discretos")
      }
    })
  })
}

## To be copied in the UI
# mod_home_ui("home_1")

## To be copied in the server
# mod_home_server("home_1")
