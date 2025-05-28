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

  observeEvent(input$navbar, {
    if (input$navbar == "navhome") {
      selected_page(NULL)  # <- Esto es clave
    }
  })

  shinyjs::hide(selector = '#navbar li a[data-value="navdata"]')
  shinyjs::hide(selector = '#navbar li a[data-value="navcociente"]')
  shinyjs::hide(selector = '#navbar li a[data-value="navcorrelaciones"]')
  shinyjs::hide(selector = '#navbar li a[data-value="navdif_medias"]')
  shinyjs::hide(selector = '#navbar li a[data-value="navdif_medias_st"]')
  shinyjs::hide(selector = '#navbar li a[data-value="navmedia"]')
  shinyjs::hide(selector = '#navbar li a[data-value="navforest"]')
  shinyjs::hide(selector = '#navbar li a[data-value="navchance"]')
  shinyjs::hide(selector = '#navbar li a[data-value="navarcoseno"]')
  shinyjs::hide(selector = '#navbar li a[data-value="navdifriesgo"]')
  shinyjs::hide(selector = '#navbar li a[data-value="navprop"]')
  shinyjs::hide(selector = '#navbar li a[data-value="navrr"]')
  shinyjs::hide(selector = '#navbar li a[data-value="navfunel"]')
  shinyjs::hide(selector = '#navbar li a[data-value="navmetareg"]')

  observeEvent(input$navbar, {
    if (input$navbar == "navhome") {
      shinyjs::hide(selector = '#navbar li a[data-value="navdata"]')
      shinyjs::hide(selector = '#navbar li a[data-value="navcociente"]')
      shinyjs::hide(selector = '#navbar li a[data-value="navcorrelaciones"]')
      shinyjs::hide(selector = '#navbar li a[data-value="navdif_medias"]')
      shinyjs::hide(selector = '#navbar li a[data-value="navdif_medias_st"]')
      shinyjs::hide(selector = '#navbar li a[data-value="navmedia"]')
      shinyjs::hide(selector = '#navbar li a[data-value="navforest"]')
      shinyjs::hide(selector = '#navbar li a[data-value="navchance"]')
      shinyjs::hide(selector = '#navbar li a[data-value="navarcoseno"]')
      shinyjs::hide(selector = '#navbar li a[data-value="navdifriesgo"]')
      shinyjs::hide(selector = '#navbar li a[data-value="navprop"]')
      shinyjs::hide(selector = '#navbar li a[data-value="navrr"]')
      shinyjs::hide(selector = '#navbar li a[data-value="navfunel"]')
      shinyjs::hide(selector = '#navbar li a[data-value="navmetareg"]')
    }
  })

  observeEvent(selected_page(), {
    if (is.null(selected_page())) return()


    shinyjs::hide(selector = '#navbar li a[data-value="navdata"]')
    shinyjs::hide(selector = '#navbar li a[data-value="navcociente"]')
    shinyjs::hide(selector = '#navbar li a[data-value="navcorrelaciones"]')
    shinyjs::hide(selector = '#navbar li a[data-value="navdif_medias"]')
    shinyjs::hide(selector = '#navbar li a[data-value="navdif_medias_st"]')
    shinyjs::hide(selector = '#navbar li a[data-value="navmedia"]')
    shinyjs::hide(selector = '#navbar li a[data-value="navforest"]')
    shinyjs::hide(selector = '#navbar li a[data-value="navchance"]')
    shinyjs::hide(selector = '#navbar li a[data-value="navarcoseno"]')
    shinyjs::hide(selector = '#navbar li a[data-value="navdifriesgo"]')
    shinyjs::hide(selector = '#navbar li a[data-value="navprop"]')
    shinyjs::hide(selector = '#navbar li a[data-value="navrr"]')
    shinyjs::hide(selector = '#navbar li a[data-value="navfunel"]')
    shinyjs::hide(selector = '#navbar li a[data-value="navmetareg"]')

    if (selected_page() == "continuos" ) {
      shinyjs::show(selector = '#navbar li a[data-value="navdata"]')
      shinyjs::show(selector = '#navbar li a[data-value="navcociente"]')
      shinyjs::show(selector = '#navbar li a[data-value="navcorrelaciones"]')
      shinyjs::show(selector = '#navbar li a[data-value="navdif_medias"]')
      shinyjs::show(selector = '#navbar li a[data-value="navdif_medias_st"]')
      shinyjs::show(selector = '#navbar li a[data-value="navmedia"]')
      shinyjs::show(selector = '#navbar li a[data-value="navforest"]')
      shinyjs::show(selector = '#navbar li a[data-value="navfunel"]')
      shinyjs::show(selector = '#navbar li a[data-value="navmetareg"]')

      updateTabsetPanel(session, "navbar", selected = "navdata")


    } else if (selected_page() == "discretos") {
      shinyjs::show(selector = '#navbar li a[data-value="navdata"]')
      shinyjs::show(selector = '#navbar li a[data-value="navchance"]')
      shinyjs::show(selector = '#navbar li a[data-value="navarcoseno"]')
      shinyjs::show(selector = '#navbar li a[data-value="navdifriesgo"]')
      shinyjs::show(selector = '#navbar li a[data-value="navprop"]')
      shinyjs::show(selector = '#navbar li a[data-value="navrr"]')
      shinyjs::show(selector = '#navbar li a[data-value="navforest"]')
      shinyjs::show(selector = '#navbar li a[data-value="navfunel"]')
      shinyjs::show(selector = '#navbar li a[data-value="navmetareg"]')


      updateTabsetPanel(session, "navbar", selected = "navdata")
    }
  })

  file_data <- mod_fileInput_server("fileInput_1")

  output$file_preview <- DT::renderDataTable({
    req(file_data())
    DT::datatable(file_data())
  })




  observeEvent(input$navbar, {
    if (input$navbar == "navcociente") {
      model <- mod_cociente_medias_server("cociente_medias_1",file_data)
      mod_forestplot_server("forestplot_1", model)
      mod_funnel_server("funnel_1", model)
      mod_metaregresion_server("metaregresion_1", model, file_data)
    }
    else if (input$navbar == "navcorrelaciones") {
      model <- mod_correlaciones_server("correlaciones_1", file_data)
      mod_forestplot_server("forestplot_1", model)
      mod_funnel_server("funnel_1", model)
      mod_metaregresion_server("metaregresion_1", model, file_data)
    }
    else if (input$navbar == "navdif_medias") {
      model <- mod_difdemedias_server("difdemedias_1", file_data)
      mod_forestplot_server("forestplot_1", model)
      mod_funnel_server("funnel_1", model)
      mod_metaregresion_server("metaregresion_1", model, file_data)
    }
    else if (input$navbar == "navdif_medias_st") {
      model <- mod_dm_estandar_server("dm_estandar_1",file_data)
      mod_forestplot_server("forestplot_1", model)
      mod_funnel_server("funnel_1", model)
      mod_metaregresion_server("metaregresion_1", model, file_data)
    }
    else if (input$navbar == "navmedia") {
      model <- mod_medias_server("medias_1",file_data)
      mod_forestplot_server("forestplot_1", model)
      mod_funnel_server("funnel_1", model)
      mod_metaregresion_server("metaregresion_1", model, file_data)
    }

    else if (input$navbar == "navchance") {
      model <-  mod_chance_server("chance_1", file_data)
      mod_forestplot_server("forestplot_1", model)
      mod_funnel_server("funnel_1", model)
      mod_metaregresion_server("metaregresion_1", model, file_data)
    }
    else if (input$navbar == "navarcoseno") {
      model <- mod_Arcoseno_server("Arcoseno_1",file_data)
      mod_forestplot_server("forestplot_1", model)
      mod_funnel_server("funnel_1", model)
      mod_metaregresion_server("metaregresion_1", model, file_data)
    }
    else if (input$navbar == "navdifriesgo") {
      model <- mod_dif_risk_server("dif_risk_1",file_data)
      mod_forestplot_server("forestplot_1", model)
      mod_funnel_server("funnel_1", model)
      mod_metaregresion_server("metaregresion_1", model, file_data)
    }
    else if (input$navbar == "navprop") {
      model <- mod_proporcion_server("proporcion_1", file_data)
      mod_forestplot_server("forestplot_1", model)
      mod_funnel_server("funnel_1", model)
      mod_metaregresion_server("metaregresion_1", model, file_data)
    }
    else if (input$navbar == "navrr") {
      model <- mod_risk_rel_server("risk_rel_1",file_data)
      mod_forestplot_server("forestplot_1", model)
      mod_funnel_server("funnel_1", model)
      mod_metaregresion_server("metaregresion_1", model, file_data)
    }
  })


}
