#' metaregresion UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_metaregresion_ui <- function(id) {
  ns <- NS(id)
  tagList(
    bslib::layout_sidebar(
      sidebar = bslib::sidebar(
        selectInput(ns("covar"),
                    "Seleccionar covariable",
                    choices = c("", NULL),
                    selected = ""),

        actionButton(ns("metaregresion"), "Ajustar Metaregresion",
                     class = "btn-primary")
      ),

      bslib::card(
        div(style = "height: 800px; overflow-y: scroll;",
        uiOutput(ns("tablas2")),
        plotOutput(ns("graficoburbujas"),height = "600px", width = "100%")
        )
      )
    )

  )
}

#' metaregresion Server Functions
#'
#' @noRd
mod_metaregresion_server <- function(id, model, file_data){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

    observe({
      df <- file_data()
      req(df)

      print(colnames(df))

      updateSelectInput(session, "covar", choices = c("",names(df)))

    })

    observeEvent(input$metaregresion, {

      req(input$covar)

      print(input$covar)
      req(model())
      # browser()
      model <- model()


      #browser()
      metaregres <- meta::metareg(model, as.formula(paste("~", input$covar)))

      resultado1 <- data.frame(t(metaregres$fit.stats$REML))
      colnames(resultado1) <- c("logLik","deviance","AIC","BIC","AICc")

      res1 <-  DT::datatable(resultado1,rownames = F,
                             options = list(
                               dom = "t",
                               paging = FALSE,
                               autoWidth = TRUE,
                               searching = FALSE
                             ),
                             style = 'bootstrap4')

      res1 <- DT::formatRound(
        res1,
        columns = c("logLik","deviance","AIC","BIC","AICc"),
        digits = 2
      )

      res2 <- as.data.frame(cbind(metaregres$tau2, metaregres$se.tau2, metaregres$I2,
                                  metaregres$H2, metaregres$R2))
      colnames(res2) <- c("tau2", "D.E tau2", "I2", "H2", "R2")

      res2 <- DT::datatable(
        res2,
        rownames = F,
        options = list(
          dom = "t",
          paging = F,
          autoWidth = T,
          searching = F
        ),
        style = "bootstrap4"
      )

      res2 <- DT::formatRound(
        res2,
        columns = c("tau2", "D.E tau2", "I2", "H2", "R2"),
        digits = 2
      )

      res3 <- data.frame(cbind("QE" = metaregres$QE,
                               "p-val" = metaregres$QEp))

      res3 <- DT::datatable(
        res3,
        rownames = F,
        options = list(
          dom = "t",
          paging = F,
          autoWidth = T,
          searching = F
        ),
        style = "bootstrap4"
      )

      res3 <- DT::formatRound(
        res3,
        columns = c("QE"),
        digits = 2
      )

      res3 <- DT::formatRound(
        res3,
        columns = c("p.val"),
        digits = 5
      )

      res4 <- data.frame(cbind(
        "fv"= rownames(metaregres$beta),
        "Estimate" = metaregres$beta,
        "se"=metaregres$se,
        "p.valor" = metaregres$pval,
        "LI[95%]" = metaregres$ci.lb,
        "LS[95%]"=metaregres$ci.ub))

      colnames(res4) <- c(" ","Estimate","SE","p.valor","LI[95%]","LS[95%]")

      res4 <- DT::datatable(
        res4,
        rownames = F,
        options = list(
          dom = "t",
          paging = F,
          autoWidth = T,
          searching = F
        ),
        style = "bootstrap4"
      )

      res4 <- DT::formatRound(
        res4,
        columns = c("p.valor"),
        digits = 5
      )

      res4 <- DT::formatRound(
        res4,
        columns = c("Estimate","SE","LI[95%]","LS[95%]"),
        digits = 2
      )

      output$tablas2 <- renderUI({
        tagList(
          h4(cat("Mixed-Effects Model (k =",metaregres$k.all,")")),
          h4("Tabla 1: Estadísticas del modelo"),
          dataTableOutput(ns("tabla1")),
          h4("Tabla 2: Cuantificación de heterogeneidad"),
          dataTableOutput(ns("tabla2")),
          h4("Tabla 3: Test de Heterogeneidad Residual"),
          dataTableOutput(ns("tabla3")),
          h4("Tabla 4: Coeficientes de la Metarregresión"),
          dataTableOutput(ns("tabla4"))
        )
      })

      output$tabla1 <- DT::renderDT({ res1 })
      output$tabla2 <- DT::renderDT({ res2 })
      output$tabla3 <- DT::renderDT({ res3 })
      output$tabla4 <- DT::renderDT({ res4 })

      output$graficoburbujas <- renderPlot({
        bubble(metaregres, studlab = TRUE)
      })

    })

  })
}

## To be copied in the UI
# mod_metaregresion_ui("metaregresion_1")

## To be copied in the server
# mod_metaregresion_server("metaregresion_1")
