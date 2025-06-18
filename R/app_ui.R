#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_ui <- function(request) {
  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    shinyjs::useShinyjs(),

    # Your application UI logic
    bslib::page_navbar(
      title = "MetaStats",
      id = "navbar",
      theme = bslib::bs_theme(bootswatch = "minty"),

      # Inicio
      bslib::nav_panel(
        title = "",
        icon = icon("home"),
        value = "navhome",
        mainPanel(
          style = "margin: 0 auto",
          mod_home_ui("home_1")
        )
      ),

      #Pagina para cargar datos
      bslib::nav_panel(
        title = "Datos",
        value = "navdata",
        icon = icon("tasks"),
        #hidden = T,
        bslib::layout_sidebar(
          sidebar = bslib::sidebar(
            mod_fileInput_ui("fileInput_1")
          ),
          bslib::layout_columns(
            fillable = TRUE,
            DT::dataTableOutput("file_preview")
          )
        )
      ),

      bslib::nav_menu(  #####
        "Meta-análisis",
        value = "metCont", ######
        icon = icon("chart-line"), #######

        # Cociente de Medias
        bslib::nav_panel(
          title = "Cociente de medias",
          value = "navcociente",
          icon = icon("chart-line"),
          mod_cociente_medias_ui("cociente_medias_1")
        ), ### Continuo

        bslib::nav_panel(
          title = "Correlaciones",
          value = "navcorrelaciones",
          icon = icon("chart-line"),
          mod_correlaciones_ui("correlaciones_1")
        ), ### Continuo

        bslib::nav_panel(
          title = "Diferencias de medias",
          value = "navdif_medias",
          icon = icon("chart-line"),
          mod_difdemedias_ui("difdemedias_1")
        ), ### Continuo

        bslib::nav_panel(
          title = "Diferencias de medias estandarizadas",
          value = "navdif_medias_st",
          icon = icon("chart-line"),
          mod_dm_estandar_ui("dm_estandar_1")
        ), #### Continuo

        bslib::nav_panel(
          title = "Media",
          value = "navmedia",
          icon = icon("chart-line"),
          mod_medias_ui("medias_1")
        ), #### Continuo

      ),

      bslib::nav_menu(  #####
                        "Meta-análisis",
                        value = "metDis", ######
                        icon = icon("chart-bar"),

      bslib::nav_panel(
        title = "Cociente de chance",
        value = "navchance",
        icon = icon("chart-bar"),
        mod_chance_ui("chance_1")
      ), ### Discreto

      bslib::nav_panel(
        title = "Diferencia de arcoseno",
        value = "navarcoseno",
        icon = icon("chart-bar"),
        mod_Arcoseno_ui("Arcoseno_1")
        ), ### Discreto

      bslib::nav_panel(
        title = "Diferencia de riesgo",
        value = "navdifriesgo",
        icon = icon("chart-bar"),
        mod_dif_risk_ui("dif_risk_1")
      ), ### Discreto

      bslib::nav_panel(
        title = "Estimación de una proporción",
        value = "navprop",
        icon = icon("chart-bar"),
        mod_proporcion_ui("proporcion_1")
      ), ### Discreta

      bslib::nav_panel(
        title = "Riesgo relativo",
        value = "navrr",
        icon = icon("chart-bar"),
        mod_risk_rel_ui("risk_rel_1")
      )
      ),

      bslib::nav_menu(  #####
                        "Visualizacion",
                        value = "visu", ######
                        icon = icon("tree"),

      bslib::nav_panel(
        title = "Forestplot",
        value = "navforest",
        icon = icon("tree"),
        mod_forestplot_ui("forestplot_1")
      ),

      bslib::nav_panel(
        title = "Funnelplot",
        value = "navfunel",
        icon = icon("caret-up"),
        mod_funnel_ui("funnel_1")
      )
      ),

      bslib::nav_panel(
        title = "Meta-regresión",
        value = "navmetareg",
        mod_metaregresion_ui("metaregresion_1")
      )


      )
    )

}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function() {
  add_resource_path(
    "www",
    app_sys("app/www")
  )

  tags$head(
    tags$link(rel = "shortcut icon", href = "www/favicon.png"),
    bundle_resources(
      path = app_sys('app/www'),
      app_title = 'MetaStat'
    )
  )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert()

}
