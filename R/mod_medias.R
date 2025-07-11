#' medias UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_medias_ui <- function(id) {
  ns <- NS(id)
    tagList(
      bslib::layout_sidebar(
        sidebar = bslib::sidebar(
          selectInput(ns("author"),
                      "Seleccionar autor",
                      choices = c("",NULL),
                      selected = ""),

          selectInput(ns("año"),
                      "Seleccionar año",
                      choices = c("",NULL),
                      selected = ""),

          selectInput(ns("N"),
                      "Seleccionar N",
                      choices = c("",NULL),
                      selected = ""),

          selectInput(ns("Media"),
                      "Seleccionar Media",
                      choices = c("",NULL),
                      selected = ""),

          selectInput(ns("Se"),
                      "Seleccionar Desvio estandar",
                      choices = c("",NULL),
                      selected = ""),

          selectInput(ns("Sub"),
                      "Seleccionar sub-grupos",
                      choices = c("",NULL),
                      selected = ""),

          selectInput(ns("model_type"),
                      "Seleccionar Tipo de Modelo",
                      choices = list(
                        "Efectos Fijos" = "fixed",
                        "Efectos Aleatorios" = "random"),
                      selected = "fixed"),

          selectInput(ns("method_tau"), "Seleccionar método de estimación de heterogeneidad",
                      choices = list("DerSimonian-Laird (DL)" = "DL",
                                     "Paule-Mandel (PM)" = "PM",
                                     "Restricted maximum-likelihood (REML)" = "REML",
                                     "Maximum-likelihood (ML)" = "ML",
                                     "Hunter-Schmidt (HS)" = "HS",
                                     "Sidik-Jonkman (SJ)" = "SJ",
                                     "Hedges (HE)" = "HE",
                                     "Empirical Bayes (EB)" = "EB"),
                      selected = "DL"),

          actionButton(ns("run_model"), "Ajustar modelo",
                       class = "btn-primary")
        ),
        bslib::card(
          uiOutput(ns("tables")),

        )

      )
    )
}

#' medias Server Functions
#'
#' @noRd
mod_medias_server <- function(id, file_data){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

    observe({
      df <- file_data()
      req(df)

      var_num <- find_vars(df, is.numeric)


      updateSelectInput(session, "author", choices = c("",names(df)))
      updateSelectInput(session, "año", choices = c("",names(df)))
      updateSelectInput(session, "N", choices = c("",var_num))
      updateSelectInput(session, "Media", choices = c("",var_num))
      updateSelectInput(session, "Se", choices = c("",var_num))
      updateSelectInput(session, "Sub", choices = c("",names(df)))

    })

    model <- eventReactive(input$run_model, {
      df <- file_data()
      req(df)
      req(input$N, input$Media, input$Se)

      metaanalisis_df <- data.frame(
        N = df[[input$N]],
        Media = df[[input$Media]],
        Se = df[[input$Se]],
        stringsAsFactors = FALSE)

      if (!is.null(input$Sub)) metaanalisis_df$Subgroup = df[[input$Sub]]

      if (!is.null(input$author) && input$author != "") {
        if (!is.null(input$año) && input$año != "") {
          metaanalisis_df$Author = paste(df[[input$author]], df[[input$año]], sep = ", ")  # Autor + año
        } else {
          metaanalisis_df$Author = df[[input$author]]  # Solo autor si año es NULL o vacío
        }
      }
      # else {
      #   NULL  # Si autor también está vacío
      # }
      # )

      cols_to_keep <- setdiff(names(df), c(input$N, input$Media, input$Se, input$Sub, input$author, input$año))

      metaanalisis_df <- cbind(metaanalisis_df, df[, cols_to_keep, drop = FALSE])


      metaanalisis_df <- metaanalisis_df[
        stats::complete.cases(metaanalisis_df[, c("N", "Media", "Se")]), ]

      req(nrow(metaanalisis_df) > 0)

      # Eleccion de efectos
      comb_fixed <- input$model_type == "fixed"
      comb_random <- input$model_type == "random"

      m <- meta::metamean(
        n = N,
        mean = Media,
        sd = Se,
        data = metaanalisis_df,
        sm = "MRAW",
        studlab = Author,
        comb.fixed = comb_fixed,
        comb.random = comb_random,
        #outclab = "Metaanálisis de Efectos Fijos para Cociente de Medias",
        method.tau = input$method_tau,
        backtransf = TRUE,  # Transformación inversa para el cociente
        subgroup = if (!is.null(metaanalisis_df$Subgroup) &&
                       length(unique(metaanalisis_df$Subgroup)) > 1) metaanalisis_df$Subgroup else NULL  # Subgrupo si existe
      )

      return(m)

    })

    res1_data <- reactive({
      m <- model()
      req(m)
      if (m$common == TRUE){
        res1 <- data.frame(summary(m))
        res1$Ponderacion= res1$w.common/sum(res1$w.common)*100
        res1 <- dplyr::select( res1, "n", "mean","sd","studlab", "TE","seTE","lower","upper","w.common", "Ponderacion")
        colnames(res1)=c("N", "Media", "DE", "Estudio", "Efecto estimado", "E.E", "LI[95%]", "LS[95%]", "Ponderación" , "Ponderación (%)")
        return(res1) }

      if (m$common == FALSE){
        res1 <- data.frame(summary(m))
        res1$Ponderacion= res1$w.random/sum(res1$w.random)*100
        res1$ROM=res1$TE
        res1$ROM_se=res1$seTE
        res1$lower_tr=res1$lower
        res1$upper_tr=res1$upper
        res1 <- dplyr::select(res1, "n", "mean","sd","studlab", "TE","seTE","lower","upper","w.random", "Ponderacion")
        colnames(res1)=c("N", "Media", "DE", "Estudio", "Efecto estimado", "E.E", "LI[95%]", "LS[95%]", "Ponderación" , "Ponderación (%)")
        return(res1) }
    })

    res8_data <- reactive({
      m <- model()
      req(m)
      if (m$common == TRUE){
        res8dt <-
          data.frame(
            Subgrupo = m[["subgroup.levels"]],
            Estimación = m[["TE.common.w"]],
            EE = m[["seTE.common.w"]],
            `LI[95%]` = m[["lower.fixed.w"]],
            `LS[95%]` = m[["upper.fixed.w"]],
            `Ponderación` = (m$w.common.w / sum(m$w.common.w)) * 100
          )
        colnames(res8dt) = c("Subgrupo","Estimación", "EE", "LI[95%]", "LS[95%]", "Ponderación")
        return(res8dt)
      }

      if(m$common == FALSE){
        res8dt <-
          data.frame(
            Subgrupo = m[["subgroup.levels"]],
            Estimación = m[["TE.random.w"]],
            EE = m[["seTE.random.w"]],
            `LI[95%]` = m[["lower.random.w"]],
            `LS[95%]` = m[["upper.random.w"]],
            `Ponderación` = (m$w.random.w / sum(m$w.random.w)) * 100
          )
        colnames(res8dt) = c("Subgrupo","Estimación", "EE", "LI[95%]", "LS[95%]", "Ponderación")
        return(res8dt)
      }

    })


    res_3_data <- reactive({
      m <- model()
      req(m)
      if(m$common == TRUE){
        res3 <- as.data.frame(cbind(m$TE.fixed, m$lower.fixed, m$upper.fixed, m$zval.fixed, round(m$pval.fixed, digits=5) ))
        colnames(res3)=c("Media", "LI[95%]", "LS[95%]", "Z", "valor-p")
        return(res3)
      }
      if(m$common == FALSE){
        res3 <- as.data.frame(cbind(m$TE.random, m$lower.random, m$upper.random, m$zval.random, round(m$pval.random, digits=5) ))
        colnames(res3)=c("Media", "LI[95%]", "LS[95%]", "Z", "valor-p")
        return(res3)
      }
    })


    output$tables <-  renderUI({
      req(model())
      m <- model()

      model_summary <- DT::datatable(res1_data(),
                                     rownames = F,
                                     options = list(
                                       dom = "t",
                                       paging = FALSE,
                                       autoWidth = TRUE,
                                       searching = FALSE
                                     ),
                                     style = 'bootstrap5'
      )
      model_summary <- DT::formatRound(
        model_summary,
        columns = c("N", "Media", "DE", "Efecto estimado", "E.E", "LI[95%]", "LS[95%]","Ponderación" , "Ponderación (%)"),
        digits = 2
      )


      m <- model()

      res2 <- as.data.frame(cbind(m$k, sum(m$n.e), sum(m$n.c)))
      colnames(res2)=c("Total de Estudios")
      res2 <- DT::datatable(res2,
                            rownames = F,
                            options = list(
                              dom = "t",
                              paging = FALSE,
                              autoWidth = TRUE,
                              searching = FALSE
                            ),
                            style = 'bootstrap4'
      )



      res3 <- DT::datatable(res_3_data(),
                            rownames = F,
                            options = list(
                              dom = "t",
                              paging = FALSE,
                              autoWidth = TRUE,
                              searching = FALSE
                            ),
                            style = 'bootstrap4')

      res3 <- DT::formatRound(
        res3,
        columns = c("Media", "LI[95%]", "LS[95%]", "Z"),
        digits = 2
      )

      res3 <- DT::formatRound(
        res3,
        columns = c("valor-p"),
        digits = 5
      )

      res4=as.data.frame(cbind(m$tau^2, m$H, m$lower.H, m$upper.H, m$I2*100, m$lower.I2*100, m$upper.I2*100))
      colnames(res4)=c("Tau2", "H", "LI.H[95%]", "LS.H[95%]", "I2(%)", "LI[95%].I2(%)", "LS[95%].I2(%)")

      res4 <- DT::datatable(res4,
                            rownames = F,
                            options = list(
                              dom = "t",
                              paging = FALSE,
                              autoWidth = TRUE,
                              searching = FALSE
                            ),
                            style = 'bootstrap4')

      res4 <- DT::formatRound(
        res4,
        columns = c("Tau2", "H", "LI.H[95%]", "LS.H[95%]",
                    "I2(%)", "LI[95%].I2(%)", "LS[95%].I2(%)"),
        digits = 2
      )




      res5=as.data.frame(cbind(m$Q, m$df.Q, m$pval.Q))
      colnames(res5)=c("Q", "GL.Q", "valor-p")

      res5 <- DT::datatable(res5,
                            rownames = F,
                            options = list(
                              dom = "t",
                              paging = FALSE,
                              autoWidth = TRUE,
                              searching = FALSE
                            ),
                            style = 'bootstrap4')

      res5 <- DT::formatRound(
        res5,
        columns = c("Q", "GL.Q"),
        digits = 2
      )

      res5 <- DT::formatRound(
        res5,
        columns = c("valor-p"),
        digits = 5
      )

      res6=as.data.frame(m$method.tau)
      colnames(res6)=c("Estimación de la varianza")
      rownames(res6)="Método"

      res6 <- DT::datatable(res6,
                            rownames = F,
                            options = list(
                              dom = "t",
                              paging = FALSE,
                              autoWidth = TRUE,
                              searching = FALSE
                            ),
                            style = 'bootstrap4')

      if (!is.null(m$subgroup)){

        res8 <- DT::datatable(res8_data(),
                              rownames = F,
                              options = list(
                                dom = "t",
                                paging = FALSE,
                                autoWidth = TRUE,
                                searching = FALSE
                              ),
                              style = 'bootstrap4')

        res8 <- DT::formatRound(
          res8,
          columns = c("Estimación", "EE", "LI[95%]", "LS[95%]", "Ponderación"),
          digits = 2
        )

        res9 <-
          data.frame(
            Subgrupo = m[["subgroup.levels"]],
            Tau2 = m[["tau.w"]]^ 2,
            Q= m[["Q.w"]],
            I2= m[["I2.w"]] * 100,
            LI= m[["lower.I2.w"]],
            LS = m[["upper.I2.w"]]
          )
        colnames(res9) = c("Subgrupo",
                           "Tau2",
                           "Q",
                           "I2[%]",
                           "LI:I2[95%]",
                           "LS:I2[95%]")

        res9 <- DT::datatable(res9,
                              rownames = F,
                              options = list(
                                dom = "t",
                                paging = FALSE,
                                autoWidth = TRUE,
                                searching = FALSE
                              ),
                              style = 'bootstrap4')

        res9 <- DT::formatRound(
          res9,
          columns = c("Tau2",
                      "Q",
                      "I2[%]",
                      "LI:I2[95%]",
                      "LS:I2[95%]"),
          digits = 2
        )


        res10 <- data.frame(
          "Dentro Subgrupos",
          m$Q.w.common,
          m$df.Q.w,
          m$pval.Q.w.common
        )

        colnames(res10) = c("Diferencias",
                            "Q",
                            "d.f",
                            "p-value")


        res11 <- data.frame(
          "Entre Subgrupos",
          m$Q.b.common,
          m$df.Q.b,
          m$pval.Q.b.common
        )

        colnames(res11) = c("Diferencias",
                            "Q",
                            "d.f",
                            "p-value")



        res12 <-data.frame(rbind(res11,res10))

        res12 <- DT::datatable(res12,
                               rownames = F,
                               options = list(
                                 dom = "t",
                                 paging = FALSE,
                                 autoWidth = TRUE,
                                 searching = FALSE
                               ),
                               style = 'bootstrap4')

        res12 <- DT::formatRound(
          res12,
          columns = c("Q",
                      "d.f"),
          digits = 2
        )

        res12 <- DT::formatRound(
          res12,
          columns = c("p.value"),
          digits = 5
        )



        tagList(
          h3(if(m$common == TRUE)
          {"Tabla 1. Estimación de Medias con Efectos Fijos"}
          else {"Tabla 1. Estimación de Medias con Efectos Aleatorios"}
          ),
          downloadButton(ns("download_res1"), "Descargar Tabla 1"),
          model_summary,
          h3("Tabla 2. Cantidad de Estudios Combinados e Individuales"),
          res2,
          h3(if(m$common == T)
          {"Tabla 3. Modelo de Efectos Fijos"}
          else {"Tabla 3. Modelo de Efectos Aleatorios"}),
          res3,
          h3("Tabla 4. Cuantificación de Heterogeneidad"),
          res4,
          h3("Tabla 5. Prueba de Heterogeneidad"),
          res5,
          h3("Tabla 6. Método"),
          res6,
          h3("Tabla 7. Resultados por Subgrupos"),
          downloadButton(ns("download_res7"), "Descargar Tabla 7"),
          res8,
          h3("Tabla 8. Cuantificación Heterogeneidad por Subgrupo"),
          res9,
          h3("Tabla 9. Prueba para la diferencias de subgrupos"),
          res12)
      } else {
        tagList(
          h3(if(m$common == TRUE)
          {"Tabla 1. Estimación de Medias con Efectos Fijos"}
          else {"Tabla 1. Estimación de Medias con Efectos Aleatorios"}
          ),
          downloadButton(ns("download_res1"), "Descargar Tabla 1"),
          model_summary,
          h3("Tabla 2. Cantidad de Estudios Combinados e Individuales"),
          res2,
          h3(if(m$common == T)
          {"Tabla 3. Modelo de Efectos Fijos"}
          else {"Tabla 3. Modelo de Efectos Aleatorios"}),
          res3,
          h3("Tabla 4. Cuantificación de Heterogeneidad"),
          res4,
          h3("Tabla 5. Prueba de Heterogeneidad"),
          res5,
          h3("Tabla 6. Método"),
          res6)
      }


    })

    output$forest_plot <- renderPlot({
      req(model())  # Requerimos el modelo ajustado
      meta::forest(model())  # Gráfico forest para el metaanálisis
    })

    # Descargar Tabla 1
    output$download_res1 <- downloadHandler(
      filename = function() {
        paste("tabla_medias_", Sys.Date(), ".csv", sep = "")
      },
      content = function(file) {
        res1 <- res1_data()
        utils::write.csv(res1, file, row.names = FALSE)
      }
    )


    # Descargar Tabla 7
    output$download_res7 <- downloadHandler(
      filename = function() {
        paste("tabla_resultados_grupos", Sys.Date(), ".csv", sep = "")
      },
      content = function(file) {
        res8 <- res8_data()
        utils::write.csv(res8, file, row.names = FALSE)
      }
    )



    return(model)


  })
}

## To be copied in the UI
# mod_medias_ui("medias_1")

## To be copied in the server
# mod_medias_server("medias_1")
