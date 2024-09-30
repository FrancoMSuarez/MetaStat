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
save_forest_plot_png <- function(model, file_name, studies_per_inch = 4) {
  total_studies <- length(model$studlab)  # Total de estudios en el meta-análisis

  # Definir las dimensiones del gráfico (por ejemplo, 2 estudios por pulgada de altura)
  height_inches <- total_studies / studies_per_inch
  width_inches <- 10  # Mantener un ancho fijo

  # Crear el archivo PNG con las dimensiones ajustadas
  png(file = file_name, width = width_inches, height = height_inches, units = "in", res = 300)

  par(mar = c(4,4,2,1))

  # Generar el forest plot
  meta::forest(model,
               col.diamond = "blue",  # Color del diamante
               col.square = "black",  # Color de los cuadrados
               col.square.lines = "black")  # Color de las líneas

  dev.off()  # Cerrar el archivo PNG
}
