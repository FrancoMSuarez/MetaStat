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
  estimate_total_rows <- function(model) {
    total_rows <- length(model$studlab)
    if (!is.null(model$byvar)) {
      total_rows <- total_rows + length(unique(model$byvar)) * 3
    }
    return(total_rows)
  }
  total_rows <- estimate_total_rows(model)

  total_studies <- length(model$studlab)  # Total de estudios en el meta-análisis

  # Definir las dimensiones del gráfico (por ejemplo, 2 estudios por pulgada de altura)
  height_inches <- min(max(total_rows / studies_per_inch, min_height), max_height)


  # Crear el archivo PNG con las dimensiones ajustadas
  grDevices::png(file = file_name, width = width_inches, height = height_inches,
      units = "in", res = res)

  graphics::par(mar = c(2,2,2,2))

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

#################################################################################
# # ANDA
# save_forest_plot_pdf <- function(model, file_name, studies_per_page = 25) {
#   message("Guardando PDF en: ", file_name)
# browser()
#   # Total de estudios y páginas necesarias
#   #total_studies <- length(model$studlab)
#   #total_pages <- ceiling(total_studies / studies_per_page)
#   is_subgroup <- !is.null(model$byvar)
#   num_subgroups <- if (is_subgroup) length(unique(model$byvar)) else 0
#   extra_lines <- if (is_subgroup) num_subgroups * 4 else 0
#   total_studies <- length(model$studlab)
#
#   plot_height <- max(25, 20 + (total_studies + extra_lines) * 1)
#
#   # Crear el archivo PDFpng
#   grDevices::pdf(file = file_name, width = 12, height = plot_height)  # Ajustar tamaño según sea necesario
#   generate_forest_plot(model)
#   grDevices::dev.off()
#
#   # for (page in 1:total_pages) {
#   #   # Calcular el rango de estudios para esta página
#   #   start_index <- (page - 1) * studies_per_page + 1
#   #   end_index <- min(page * studies_per_page, total_studies)
#   #
#   #   # Asegurarnos de que el rango sea válido
#   #   if (start_index > total_studies || start_index > end_index) next
#   #
#   #   # Crear un submodelo solo con los estudios para esta página
#   #   sub_model <- model
#   #   sub_model$TE <- model$TE[start_index:end_index]
#   #   sub_model$seTE <- model$seTE[start_index:end_index]
#   #   sub_model$studlab <- model$studlab[start_index:end_index]
#   #
#   #   # Verificar la consistencia del submodelo
#   #   if (length(sub_model$TE) != length(sub_model$seTE) ||
#   #       length(sub_model$TE) != length(sub_model$studlab)) {
#   #     warning("Inconsistencia en las longitudes del submodelo para la página ", page)
#   #     next
#   #   }
#   #
#   #   # Configurar el gráfico para esta página
#   #   graphics::par(mar = c(4, 4, 2, 1))  # Ajustar márgenes si es necesario
#   #
#   #   # Generar el forest plot
#   #   # meta::forest(sub_model,
#   #   #              col.diamond = "blue",    # Color del diamante
#   #   #              col.square = "black",    # Color de los cuadrados
#   #   #              col.square.lines = "black")  # Color de las líneas de conexión
#   #   generate_forest_plot(sub_model)
#   #
#   #   #message("Página ", page, " generada con éxito")
#   # }
#
#   # grDevices::dev.off()  # Cerrar el archivo PDF
#   message("PDF guardado exitosamente en: ", file_name)
# }

#################################################333##

save_forest_plot_pdf <- function(model, file_name) {
  library(magick)

  message("Guardando PDF en: ", file_name)

  # Calcular tamaño dinámico del gráfico
  is_subgroup <- !is.null(model$byvar)
  num_subgroups <- if (is_subgroup) length(unique(model$byvar)) else 0
  extra_lines <- if (is_subgroup) num_subgroups * 4 else 0
  total_studies <- length(model$studlab)
  plot_height <- max(25, 20 + (total_studies + extra_lines) * 1)

  # Guardar el plot como imagen PNG grande
  tmp_png <- tempfile(fileext = ".png")
  png(tmp_png, width = 3000, height = plot_height * 50, res = 300) # ancho fijo, alto dinámico
  generate_forest_plot(model)
  dev.off()

  # Leer la imagen con magick
  img <- image_read(tmp_png)

  # Tamaño A4 en píxeles a 300 dpi
  a4_width <- 3000
  a4_height <- 3508

  info <- image_info(img)
  w <- info$width
  h <- info$height

  # Calcular cortes
  cols <- ceiling(w / a4_width)
  rows <- ceiling(h / a4_height)

  partes <- list()
  for (r in 0:(rows-1)) {
    for (c in 0:(cols-1)) {
      x_offset <- c * a4_width
      y_offset <- r * a4_height
      recorte <- image_crop(
        img,
        paste0(a4_width, "x", a4_height, "+", x_offset, "+", y_offset)
      )
      partes <- c(partes, list(recorte))
    }
  }

  # Guardar como PDF
  pdf_final <- image_join(partes)
  image_write(pdf_final, path = file_name, format = "pdf")

  message("PDF recortado y guardado exitosamente en: ", file_name)
}


##### 28/5
generate_forest_plot <- function(model) {
  meta::forest(model,
               col.diamond = "blue",
               col.square = "black",
               col.square.lines = "black")
}






