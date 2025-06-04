# app.R

# if (!requireNamespace("devtools", quietly = TRUE)) {
#   install.packages("devtools")
# }
if (!requireNamespace("MetaStats", quietly = TRUE)) {
  stop("The MetaStats package is not installed. Please install it before running the app.")
}

#devtools::install_github("FrancoMSuarez/MetaStats")
pak::pkg_install("FrancoMSuarez/MetaStats")

pkgload::load_all(export_all = FALSE, helpers = FALSE, attach_testthat = FALSE)


options( "golem.app.prod" = TRUE) # Activa el modo producción

MetaStats::run_app(host = "0.0.0.0", port =3838) # Cambia MetaStat por el nombre de tu paquete

#
# # shiny::runApp()
# rsconnect::setAccountInfo(name = 'francosuarez',
#                           token = '1597AF5C7B823B6FD37ACD9B6FDF82D4',
#                           secret = 'HG/fL5HVBsSvPKS4A2I6sjDhewb44mtoZ6VTzKrw')
# #
# rsconnect::deployApp(appDir = "C:/Users/franm/Desktop/MetaStats")
