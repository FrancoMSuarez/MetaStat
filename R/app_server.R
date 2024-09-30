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


  shinyjs::hide(selector = '#navbar li a[data-value="navdata"]')
  # shinyjs::hide(selector = '#navbar li a[data-value="navmodel"]')
  shinyjs::hide(selector = '#navbar li a[data-value="navcociente"]')
  shinyjs::hide(selector = '#navbar li a[data-value="navforest"]')

  observeEvent(selected_page(), {
    if (selected_page() == "continuos" ) {
      shinyjs::show(selector = '#navbar li a[data-value="navdata"]')
      # shinyjs::show(selector = '#navbar li a[data-value="navmodel"]')
      shinyjs::show(selector = '#navbar li a[data-value="navcociente"]')
      shinyjs::show(selector = '#navbar li a[data-value="navforest"]')

      updateTabsetPanel(session, "navbar", selected = "navdata")


    } else if (selected_page() == "discretos") {
    shinyjs::show(selector = '#navbar li a[data-value="navdata"]')
    # shinyjs::show(selector = '#navbar li a[data-value="navmodel"]')


    updateTabsetPanel(session, "navbar", selected = "navdata")
  }
  })

  file_data <- mod_fileInput_server("fileInput_1")

  output$file_preview <- renderTable({
    head(file_data(), 10)
  })

  model <- mod_cociente_medias_server("cociente_medias_1",file_data)

  mod_forestplot_server("forestplot_1", model)

}


