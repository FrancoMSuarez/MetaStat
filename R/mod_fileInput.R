#' fileInput UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
#' @import readxl
#'
mod_fileInput_ui <- function(id) {
  ns <- NS(id)
  tagList(
    fileInput(ns("file1"), "Elige un archivo (csv, Excel, txt)",
              multiple = FALSE,
              accept = c("text/csv",
                         "text/comma-separated-values,text/plain",
                         ".csv", ".xlsx", ".xls", ".txt")),
    tags$hr(),
    checkboxInput(ns("header"), "Encabezado", TRUE),
    tags$hr(),
    radioButtons(ns("sep"), "Separador de columnas",
                 choices = c(Coma = ",",
                             Semicolon = ";",
                             Tab = "\t"),
                 selected = ","),
    tags$hr(),
    radioButtons(ns("decimal"), "Separador decimal",
                 choices = c(Punto = ".",
                             Coma = ","),
                 selected = "."),
    tags$hr()
  )



}

#' fileInput Server Functions
#'
#' @noRd
mod_fileInput_server <- function(id){
  moduleServer(id, function(input, output, session) {
    data <- reactive({
      req(input$file1)
      tryCatch(
        {
          first_row <- readLines(input$file1$datapath, n = 1)
          decimal_sep <- if (grepl(",", first_row)) "," else "."

          if (grepl("\\.csv$", input$file1$name)) {
            df <- utils::read.csv(input$file1$datapath, header = input$header, sep = input$sep)
          } else if (grepl("\\.xlsx$|\\.xls$", input$file1$name)) {
            df <- readxl::read_excel(input$file1$datapath)
          } else if (grepl("\\.txt$", input$file1$name)) {
            df <- utils::read.table(input$file1$datapath, header = input$header, sep = input$sep)
          } else {
            df <- NULL
          }

          if (input$decimal == ",") {
            df <- df  |>
              dplyr::mutate_if(~ all(grepl("^-?[0-9]+(,[0-9]+)?$", .)), ~ as.numeric(gsub(",", ".", .)))
          } else {
            df <- df  |>
              dplyr::mutate_if(~ all(grepl("^-?[0-9]+(\\.[0-9]+)?$", .)), as.numeric)
          }

          return(df)


        },
        error = function(e) {
          stop(safeError(e))
        }
      )
    })

    output$contents <- renderTable({
      df <- data()
      if (input$disp == "head") {
        return(utils::head(df))
      } else {
        return(df)
      }
    })

    return(data)
  })
}

## To be copied in the UI
# mod_fileInput_ui("fileInput_1")

## To be copied in the server
# mod_fileInput_server("fileInput_1")
