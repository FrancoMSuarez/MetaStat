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
        title = "Data preparation",
        value = "navdata",
        icon = icon("tasks"),
        #hidden = T,
        bslib::layout_sidebar(
          sidebar = bslib::sidebar(
            mod_fileInput_ui("fileInput_1")
          ),
          bslib::layout_columns(
            fillable = TRUE,
            tableOutput("file_preview")
          )
        )
      ),

      bslib::nav_panel(
        title = "Modelo",
        value = "navmodel",
        icon = icon("chart-line"),
        #hidden = T,
        fluidPage(
          h3("mdodsf")
        )
      ),

      # Cociente de Medias
      bslib::nav_panel(
        title = "Cociente de medias",
        value = "navcociente",
        icon = icon("chart-line"),
        #hidden = T,
        # bslib::layout_sidebar(
          # sidebar = bslib::sidebar(
            mod_cociente_medias_ui("cociente_medias_1")
          # ),
          # bslib::layout_columns(
          # fillable = TRUE,
          # verbatimTextOutput("model_summary"),  # Mostrar el resumen del modelo
          # plotOutput("forest_plot")
          # )

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
    favicon(),
    bundle_resources(
      path = app_sys("app/www"),
      app_title = "MetaStats"
    )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert()
  )
}
