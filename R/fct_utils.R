#' utils
#'
#' @description A fct function
#'
#' @return The return value, if any, from executing the function.
#'
#' @noRd
#'
find_vars <- function(data, filter) {
  names(data)[vapply(data, filter, logical(1))]
}


# Función para guardar el forest plot en formato PNG con dimensiones ajustadas
save_forest_plot_png <- function(model, file_name, studies_per_inch = 4,
                                 min_height = 10, max_height = 70,
                                 width_inches = 12, res = 300) {

  # browser()
  total_studies <- length(model$studlab)  # Total de estudios en el meta-análisis

  # Definir las dimensiones del gráfico (por ejemplo, 2 estudios por pulgada de altura)
  height_inches <- min(max(total_studies / studies_per_inch, min_height), max_height)


  # Crear el archivo PNG con las dimensiones ajustadas
  grDevices::png(file = file_name, width = width_inches, height = height_inches,
      units = "in", res = res)

  graphics::par(mar = c(2,2,2,2))

  # Generar el forest plot
  # meta::forest(model,
  #              col.diamond = "blue",  # Color del diamante
  #              col.square = "black",  # Color de los cuadrados
  #              col.square.lines = "black")  # Color de las líneas

  generate_forest_plot(model)

  grDevices::dev.off()  # Cerrar el archivo PNG
}


save_funnel_plot_png <- function(model, file_name, show_studlab = TRUE) {

  # Crear el archivo PNG con las dimensiones ajustadas
  grDevices::png(file = file_name, width = 15, height = 15, units = "in", res = 300)

  graphics::par(mar = c(4,4,2,1))

  meta::funnel(model, studlab = show_studlab)

  grDevices::dev.off()
}

save_baujat_plot_png <- function(model, file_name, show_studlab = TRUE) {

  # Crear el archivo PNG con las dimensiones ajustadas
  grDevices::png(file = file_name, width = 15, height = 15, units = "in", res = 300)

  graphics::par(mar = c(4,4,2,1))


  meta::baujat(model, studlab = show_studlab)

  grDevices::dev.off()
}




# save_forest_plot_pdf <- function(model, file_name, studies_per_page = 20) {
#   message("Guardando PDF en: ", file_name)
#   total_studies <- length(model$studlab)  # Total de estudios en el meta-análisis
#   total_pages <- ceiling(total_studies / studies_per_page)  # Calcular el número de páginas
#   #browser()
#
#   # Crear el archivo PDF
#   pdf(file = file_name, width = 10, height = 10)  # Ajustar tamaño del PDF según sea necesario
#
#   # Generar el forest plot en varias páginas
#   for (page in 1:total_pages) {
#     # Calcular el rango de estudios a mostrar en esta página
#     start_index <- (page - 1) * studies_per_page + 1
#     end_index <- min(page * studies_per_page, total_studies)
#
#     if (start_index > end_index || start_index > total_studies) next
#     # Crear una copia del modelo solo con los estudios de esta página
#     sub_model <- model
#     sub_model$TE <- model$TE[start_index:end_index]
#     sub_model$seTE <- model$seTE[start_index:end_index]
#     sub_model$studlab <- model$studlab[start_index:end_index]
#
#     if (!(length(sub_model$TE) == length(sub_model$seTE) &&
#           length(sub_model$TE) == length(sub_model$studlab))) {
#       stop("Las longitudes de las variables en el modelo no coinciden.")
#     }
#
#     # Configurar el gráfico en una página nueva
#     par(mar = c(4, 4, 2, 1))
#
#     # Generar el forest plot para esta página
#     meta::forest(sub_model,
#                  col.diamond = "blue",  # Color del diamante
#                  col.square = "black",  # Color de los cuadrados
#                  col.square.lines = "black")  # Color de las líneas
#
#
#   }
#
#   message("saliendo del for")
#   dev.off()  # Cerrar el archivo PDF
# }

save_forest_plot_pdf <- function(model, file_name, studies_per_page = 25) {
  message("Guardando PDF en: ", file_name)

  # Total de estudios y páginas necesarias
  total_studies <- length(model$studlab)
  total_pages <- ceiling(total_studies / studies_per_page)

  # Crear el archivo PDFpng
  grDevices::pdf(file = file_name, width = 12, height = 8)  # Ajustar tamaño según sea necesario

  for (page in 1:total_pages) {
    # Calcular el rango de estudios para esta página
    start_index <- (page - 1) * studies_per_page + 1
    end_index <- min(page * studies_per_page, total_studies)

    # Asegurarnos de que el rango sea válido
    if (start_index > total_studies || start_index > end_index) next

    # Crear un submodelo solo con los estudios para esta página
    sub_model <- model
    sub_model$TE <- model$TE[start_index:end_index]
    sub_model$seTE <- model$seTE[start_index:end_index]
    sub_model$studlab <- model$studlab[start_index:end_index]

    # Verificar la consistencia del submodelo
    if (length(sub_model$TE) != length(sub_model$seTE) ||
        length(sub_model$TE) != length(sub_model$studlab)) {
      warning("Inconsistencia en las longitudes del submodelo para la página ", page)
      next
    }

    # Configurar el gráfico para esta página
    graphics::par(mar = c(4, 4, 2, 1))  # Ajustar márgenes si es necesario

    # Generar el forest plot
    # meta::forest(sub_model,
    #              col.diamond = "blue",    # Color del diamante
    #              col.square = "black",    # Color de los cuadrados
    #              col.square.lines = "black")  # Color de las líneas de conexión
    generate_forest_plot(sub_model)

    #message("Página ", page, " generada con éxito")
  }

  grDevices::dev.off()  # Cerrar el archivo PDF
  message("PDF guardado exitosamente en: ", file_name)
}





##### 28/5
generate_forest_plot <- function(model) {
  meta::forest(model,
               col.diamond = "blue",
               col.square = "black",
               col.square.lines = "black")
}


