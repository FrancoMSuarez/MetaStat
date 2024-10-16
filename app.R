# app.R
pkgload::load_all(export_all = FALSE, helpers = FALSE, attach_testthat = FALSE)
options( "golem.app.prod" = TRUE) # Activa el modo producción
MetaStats::run_app() # Cambia MetaStat por el nombre de tu paquete

