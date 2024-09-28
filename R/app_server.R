#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  # Your application server logic

  shinyjs::useShinyjs()

  selected_page <- mod_home_server("home_1")

  # ##tabs_added <- reactiveVal(FALSE)
  shinyjs::hide(selector = '#navbar li a[data-value="navdata"]')
  shinyjs::hide(selector = '#navbar li a[data-value="navmodel"]')
  shinyjs::hide(selector = '#navbar li a[data-value="navcociente"]')

  observeEvent(selected_page(), {
    if (selected_page() == "continuos" ) {
      shinyjs::show(selector = '#navbar li a[data-value="navdata"]')
      shinyjs::show(selector = '#navbar li a[data-value="navmodel"]')
      shinyjs::show(selector = '#navbar li a[data-value="navcociente"]')

      updateTabsetPanel(session, "navbar", selected = "navdata")


      # Agregar la pestaña "Data preparation" cuando se selecciona "Datos Continuos"
      # appendTab(
      #   inputId = "navbar",
      #   bslib::nav_panel(
      #     title = "Data preparation",
      #     value = "navdata",
      #     icon = icon("tasks"),
      #     sidebarLayout(
      #       sidebarPanel(
      #         mod_fileInput_ui("fileInput_1")
      #       ),
      #       mainPanel(
      #         tableOutput("file_preview")
      #       )
      #     )
      #   )
      # )

      # Agregar la pestaña "Modelo"
      # appendTab(
      #   inputId = "navbar",
      #   bslib::nav_panel(
      #     title = "Modelo",
      #     value = "navmodel",
      #     icon = icon("chart-line"),
      #     h2("Aquí podrás ajustar tus modelos")
      #   )
      # )

      # # Cambiar automáticamente a la pestaña "Data preparation"
      # updateNavbarPage(session, "navbar", selected = "navdata")
      #
      # tabs_added(TRUE)
    } else if (selected_page() == "discretos") {
    shinyjs::show(selector = '#navbar li a[data-value="navdata"]')
    shinyjs::show(selector = '#navbar li a[data-value="navmodel"]')

    # Cambiar automáticamente a la pestaña "Data preparation"
    updateTabsetPanel(session, "navbar", selected = "navdata")
  }
  })

  file_data <- mod_fileInput_server("fileInput_1")

  output$file_preview <- renderTable({
    head(file_data(), 10)
  })

  mod_cociente_medias_server("cociente_medias_1",file_data)


}


