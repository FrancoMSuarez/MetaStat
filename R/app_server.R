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
  shinyjs::hide(selector = '#navbar li a[data-value="navcorrelaciones"]')
  shinyjs::hide(selector = '#navbar li a[data-value="navdif_medias"]')
  shinyjs::hide(selector = '#navbar li a[data-value="navdif_medias_st"]')
  shinyjs::hide(selector = '#navbar li a[data-value="navmedia"]')




  observeEvent(selected_page(), {
    if (selected_page() == "continuos" ) {
      shinyjs::show(selector = '#navbar li a[data-value="navdata"]')
      # shinyjs::show(selector = '#navbar li a[data-value="navmodel"]')
      shinyjs::show(selector = '#navbar li a[data-value="navcociente"]')
      shinyjs::show(selector = '#navbar li a[data-value="navforest"]')
      shinyjs::show(selector = '#navbar li a[data-value="navcorrelaciones"]')
      shinyjs::show(selector = '#navbar li a[data-value="navdif_medias"]')
      shinyjs::show(selector = '#navbar li a[data-value="navdif_medias_st"]')
      shinyjs::show(selector = '#navbar li a[data-value="navmedia"]')

      updateTabsetPanel(session, "navbar", selected = "navdata")


    } else if (selected_page() == "discretos") {
    shinyjs::show(selector = '#navbar li a[data-value="navdata"]')
    # shinyjs::show(selector = '#navbar li a[data-value="navmodel"]')


    updateTabsetPanel(session, "navbar", selected = "navdata")
  }
  })

  file_data <- mod_fileInput_server("fileInput_1")

  output$file_preview <- DT::renderDataTable({
    req(file_data())
    DT::datatable(file_data())
  })

  model <- mod_cociente_medias_server("cociente_medias_1",file_data)
  model <- mod_correlaciones_server("correlaciones_1", file_data)
  model <- mod_difdemedias_server("difdemedias_1", file_data)
  model <- mod_dm_estandar_server("dm_estandar_1",file_data)
  model <- mod_medias_server("medias_1",file_data)

  mod_forestplot_server("forestplot_1", model)

}


