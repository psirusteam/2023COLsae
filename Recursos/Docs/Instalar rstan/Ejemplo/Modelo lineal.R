## Ejemplo para validar instalación de rstan
#Librería 
library(rstan)
# Base de ejemplo
datalm <- readRDS(file = "datalm.rds")
fitLm1 <- "7ModeloLm.stan" 
# Preparar insumos 
sample_data <- list(n = nrow(datalm),
                    x = datalm$material_paredes ,
                    y = datalm$Promedio)
# Ejecutar el modelo 
model_fitLm1 <- stan(data = sample_data, 
                     model_code = fitLm1,
                     iter = 10, verbose = FALSE)
# Resultados de stan
summary(model_fitLm1)$summary  

